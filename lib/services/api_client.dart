import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import 'storage_service.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  late Dio _dio;
  final StorageService _storage = StorageService();

  Dio get dio => _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: ApiConfig.defaultHeaders,
      ),
    );

    // Ajouter les intercepteurs
    _dio.interceptors.add(_authInterceptor());
    _dio.interceptors.add(_loggingInterceptor());
    _dio.interceptors.add(_errorInterceptor());
  }

  // ===== INTERCEPTEUR D'AUTHENTIFICATION =====
  // Ajoute automatiquement le token JWT à chaque requête

  Interceptor _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Récupérer le token
        final token = await _storage.getAccessToken();

        // Ajouter dans le header si existe
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        return handler.next(options);
      },
      onError: (DioException error, handler) async {
        // Si erreur 401 (Unauthorized), essayer de rafraîchir le token
        if (error.response?.statusCode == 401) {
          // TODO: Implémenter la logique de refresh token
          // Pour l'instant, on laisse passer l'erreur
        }
        return handler.next(error);
      },
    );
  }

  // ===== INTERCEPTEUR DE LOGGING =====
  // Affiche les requêtes/réponses dans la console (debug)

  Interceptor _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        print('🔵 REQUEST[${options.method}] => PATH: ${options.path}');
        print('🔵 Headers: ${options.headers}');
        if (options.data != null) {
          print('🔵 Body: ${options.data}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print(
          '🟢 RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}',
        );
        print('🟢 Data: ${response.data}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print(
          '🔴 ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}',
        );
        print('🔴 Message: ${error.message}');
        if (error.response?.data != null) {
          print('🔴 Response: ${error.response?.data}');
        }
        return handler.next(error);
      },
    );
  }

  // ===== INTERCEPTEUR DE GESTION D'ERREURS =====

  Interceptor _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (DioException error, handler) {
        String errorMessage = 'Une erreur est survenue';

        if (error.type == DioExceptionType.connectionTimeout) {
          errorMessage =
              'Connexion timeout - Vérifiez votre connexion internet';
        } else if (error.type == DioExceptionType.receiveTimeout) {
          errorMessage =
              'Réception timeout - Le serveur met trop de temps à répondre';
        } else if (error.type == DioExceptionType.badResponse) {
          // Erreur de réponse HTTP
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;

          if (statusCode == 400) {
            errorMessage =
                responseData is Map && responseData['message'] != null
                ? responseData['message']
                : 'Données invalides';
          } else if (statusCode == 401) {
            errorMessage = 'Non autorisé - Veuillez vous reconnecter';
          } else if (statusCode == 403) {
            errorMessage = 'Accès interdit';
          } else if (statusCode == 404) {
            errorMessage = 'Ressource non trouvée';
          } else if (statusCode == 500) {
            errorMessage = 'Erreur serveur - Veuillez réessayer plus tard';
          } else {
            errorMessage =
                responseData is Map && responseData['message'] != null
                ? responseData['message']
                : 'Erreur serveur (${statusCode ?? 'unknown'})';
          }
        } else if (error.type == DioExceptionType.cancel) {
          errorMessage = 'Requête annulée';
        } else if (error.type == DioExceptionType.unknown) {
          errorMessage = 'Pas de connexion internet';
        }

        // Créer une erreur personnalisée avec le message
        final customError = error.copyWith(message: errorMessage);

        return handler.next(customError);
      },
    );
  }
}
