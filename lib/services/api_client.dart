import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import 'storage_service.dart';
import 'auth_service.dart';

/// ApiClient — singleton Dio avec deux instances :
///
/// [dio]     → Gateway (port 8085) — JWT injecté automatiquement
///             Utiliser pour TOUS les endpoints métier
///
/// [authDio] → user-service direct (port 8083) — PAS de JWT
///             Utiliser UNIQUEMENT pour login et register
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  Dio? _dio;
  Dio? _authDio;
  Dio? _userDio;

  final StorageService _storage = StorageService();

  /// Dio principal — Gateway port 8085 — JWT requis
  Dio get dio {
    _ensureInitialized();
    return _dio!;
  }

  /// Dio auth — user-service port 8083 — PAS de JWT
  /// Utiliser pour : loginEndpoint, registerEndpoint
  Dio get authDio {
    _ensureInitialized();
    return _authDio!;
  }

  /// Dio user-service direct (port 8083) — JWT requis
  /// Utiliser pour les endpoints user-service protégés:
  /// profil, QR code, proches, etc.
  Dio get userDio {
    _ensureInitialized();
    return _userDio!;
  }

  void init() {
    // ── Dio principal (Gateway) ──────────────────────────────────
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl, // http://localhost:8085
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );
    _dio!.interceptors.add(_authInterceptor());
    _dio!.interceptors.add(_loggingInterceptor());
    _dio!.interceptors.add(_errorInterceptor());

    // ── Dio auth (user-service direct) ──────────────────────────
    // PAS d'intercepteur JWT — login/register n'ont pas de token
    _authDio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.authBaseUrl, // http://localhost:8083
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );
    _authDio!.interceptors.add(_loggingInterceptor());
    _authDio!.interceptors.add(_errorInterceptor());

    // ── Dio user-service direct sécurisé ────────────────────────
    _userDio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.authBaseUrl,
        // Les écrans profil / proches / QR sont souvent appelés juste après login
        // sur mobile, donc on laisse un peu plus de marge réseau.
        connectTimeout: const Duration(seconds: 25),
        receiveTimeout: const Duration(seconds: 25),
        headers: ApiConfig.defaultHeaders,
      ),
    );
    _userDio!.interceptors.add(_authInterceptor());
    _userDio!.interceptors.add(_loggingInterceptor());
    _userDio!.interceptors.add(_errorInterceptor());
  }

  // ═══════════════════════════════════════════════════════════════
  // INTERCEPTEUR JWT — injecte le token dans chaque requête
  // ═══════════════════════════════════════════════════════════════

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.getAccessToken();

        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        // NE PAS ajouter X-User-Id manuellement
        // Le Gateway extrait sub + roles du JWT et les propage automatiquement

        return handler.next(options);
      },

      onError: (DioException error, handler) async {
        // Token expiré → ré-authentification automatique
        if (error.response?.statusCode == 401 && error.requestOptions.extra['isRetry'] != true) {
          error.requestOptions.extra['isRetry'] = true;
          try {
            final authService = AuthService();
            final result = await authService.refreshToken();

            if (result.success) {
              final newToken = await _storage.getAccessToken();
              if (newToken != null && newToken.isNotEmpty) {
                // Rejouer la requête originale avec le nouveau token
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $newToken';
                final response = await dio.fetch(opts);
                return handler.resolve(response);
              }
            }
          } catch (e) {
            // Refresh échoué → laisser l'erreur 401 remonter
            // L'UI doit rediriger vers l'écran de login
          }
        }
        return handler.next(error);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // INTERCEPTEUR LOGGING — debug console
  // ═══════════════════════════════════════════════════════════════

  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🔵 [${options.method}] ${options.baseUrl}${options.path}');
        if (options.data != null) {
          print('🔵 Body: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print(
          '🟢 [${response.statusCode}] ${response.requestOptions.path}',
        );
        return handler.next(response);
      },
      onError: (error, handler) {
        print(
          '🔴 [${error.response?.statusCode}] ${error.requestOptions.path}',
        );
        print('🔴 Message: ${error.message}');
        if (error.response?.data != null) {
          print('🔴 Response: ${error.response?.data}');
        }
        return handler.next(error);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // INTERCEPTEUR ERREURS — messages lisibles
  // ═══════════════════════════════════════════════════════════════

  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (DioException error, handler) {
        String message;

        switch (error.type) {
          case DioExceptionType.connectionTimeout:
            message = 'Timeout de connexion — vérifiez votre réseau';
            break;
          case DioExceptionType.receiveTimeout:
            message = 'Le serveur met trop de temps à répondre';
            break;
          case DioExceptionType.cancel:
            message = 'Requête annulée';
            break;
          case DioExceptionType.unknown:
            message = 'Pas de connexion internet';
            break;
          case DioExceptionType.badResponse:
            final status = error.response?.statusCode;
            final data = error.response?.data;
            final serverMsg = data is Map ? data['message'] : null;

            switch (status) {
              case 400:
                message = serverMsg ?? 'Données invalides';
                break;
              case 401:
                message = 'Session expirée — reconnectez-vous';
                break;
              case 403:
                message = 'Accès refusé — rôle insuffisant';
                break;
              case 404:
                message = serverMsg ?? 'Ressource introuvable';
                break;
              case 409:
                message = serverMsg ?? 'Conflit — données existantes';
                break;
              case 500:
                message = 'Erreur serveur — réessayez plus tard';
                break;
              default:
                message = serverMsg ?? 'Erreur ($status)';
            }
            break;
          default:
            message = 'Erreur inconnue';
        }

        return handler.next(error.copyWith(message: message));
      },
    );
  }

  void _ensureInitialized() {
    if (_dio == null || _authDio == null || _userDio == null) {
      init();
    }
  }
}
