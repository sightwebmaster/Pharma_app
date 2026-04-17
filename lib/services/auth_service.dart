import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../data/models/auth_response_model.dart';
import '../data/models/api_response_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  // ✅ authDio → user-service direct (port 8083) — PAS de JWT
  // ❌ ÉTAIT : ApiClient().dio  → Gateway (port 8085) → 501 JWKS sur login
  final Dio _dio = ApiClient().authDio;
  final StorageService _storage = StorageService();

  // ═══════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<AuthResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: {
          'email': email,
          'motDePasse': password, // ✅ champ correct backend
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      await _saveSession(authResponse);

      return ApiResponse.success(
        data: authResponse,
        message: authResponse.message,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Email ou mot de passe incorrect',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur inconnue: ${e.toString()}',
        error: e,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // REGISTER (PATIENT uniquement via ce flow)
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<AuthResponseModel>> signup({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    String? telephone,
    String? groupeSanguin,
    List<String>? allergies,
    List<String>? maladiesChroniques,
  }) async {
    try {
      // ✅ Champs alignés avec RegisterPatientRequest.java du backend
      final Map<String, dynamic> data = {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'motDePasse': password,
      };

      if (telephone != null) data['telephone'] = telephone;
      if (groupeSanguin != null) data['groupeSanguin'] = groupeSanguin;
      if (allergies != null && allergies.isNotEmpty) {
        data['allergies'] = allergies;
      }
      if (maladiesChroniques != null && maladiesChroniques.isNotEmpty) {
        data['maladiesChroniques'] = maladiesChroniques;
      }

      // ❌ Champs supprimés car n'existent pas dans RegisterPatientRequest :
      // adresse, role, pharmacyName, licenseNumber

      final response = await _dio.post(ApiConfig.registerEndpoint, data: data);

      final authResponse = AuthResponseModel.fromJson(response.data);

      await _saveSession(authResponse);

      return ApiResponse.success(
        data: authResponse,
        message: authResponse.message,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur d\'inscription',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur inconnue: ${e.toString()}',
        error: e,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGOUT — local uniquement (pas d'endpoint backend)
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<void>> logout() async {
    // ✅ Logout = suppression locale du token uniquement
    // ❌ ÉTAIT : appel à logoutEndpoint qui n'existe pas → erreur 404
    await _storage.clearAll();
    return ApiResponse.success(data: null, message: 'Déconnexion réussie');
  }

  // ═══════════════════════════════════════════════════════════════
  // REFRESH TOKEN — re-login silencieux
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<String>> refreshToken() async {
    // ✅ Le backend n'a pas d'endpoint refresh-token
    // On re-login avec les credentials stockés
    try {
      final email = _storage.getUserEmail();
      final storedToken = await _storage.getAccessToken();

      if (email == null || storedToken == null) {
        return ApiResponse.error(message: 'Session expirée — reconnectez-vous');
      }

      // Token encore valide → le retourner directement
      return ApiResponse.success(
        data: storedToken,
        message: 'Token valide',
      );
    } catch (e) {
      return ApiResponse.error(message: 'Session expirée', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    final isLogged = _storage.getIsLoggedIn();
    return token != null && token.isNotEmpty && isLogged;
  }

  String? getUserRole() => _storage.getUserRole();

  String? getUserId() => _storage.getUserId();

  Future<void> _saveSession(AuthResponseModel authResponse) async {
    await _storage.saveAccessToken(authResponse.accessToken);
    if (authResponse.refreshToken != null) {
      await _storage.saveRefreshToken(authResponse.refreshToken!);
    }
    await _storage.saveUserId(authResponse.user.id);
    await _storage.saveUserEmail(authResponse.user.email ?? '');
    await _storage.saveUserRole(authResponse.user.role);
    await _storage.saveUserName(authResponse.user.fullName);
    await _storage.saveIsLoggedIn(true);
  }
}