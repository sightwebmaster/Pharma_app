import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../data/models/auth_response_model.dart';
import '../data/models/api_response_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;
  final StorageService _storage = StorageService();

  // ===== LOGIN =====

  Future<ApiResponse<AuthResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.loginEndpoint,
        data: {'email': email, 'motDePasse': password},
      );

      // Parser la réponse
      final authResponse = AuthResponseModel.fromJson(response.data);

      // Sauvegarder les tokens et infos user
      await _storage.saveAccessToken(authResponse.accessToken);
      if (authResponse.refreshToken != null) {
        await _storage.saveRefreshToken(authResponse.refreshToken!);
      }
      await _storage.saveUserId(authResponse.user.id);
      await _storage.saveUserEmail(authResponse.user.email?? '');
      await _storage.saveUserRole(authResponse.user.role);
      await _storage.saveUserName(authResponse.user.fullName);
      await _storage.saveIsLoggedIn(true);

      return ApiResponse.success(
        data: authResponse,
        message: authResponse.message,
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur de connexion',
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

  // ===== SIGNUP =====

  Future<ApiResponse<AuthResponseModel>> signup({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String telephone,
    required String adresse,
    required String role, // "Patient" ou "Pharmacien"
    String? pharmacyName,
    String? licenseNumber,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.signupEndpoint,
        data: {
          'nom': nom,
          'prenom': prenom,
          'email': email,
          'motDePasse': password,
          'telephone': telephone,
          'adresse': adresse,
          'role': role,
          'pharmacyName': ?pharmacyName,
          'licenseNumber': ?licenseNumber,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);

      // Sauvegarder les tokens
      await _storage.saveAccessToken(authResponse.accessToken);
      if (authResponse.refreshToken != null) {
        await _storage.saveRefreshToken(authResponse.refreshToken!);
      }
      await _storage.saveUserId(authResponse.user.id);
      await _storage.saveUserEmail(authResponse.user.email?? '');
      await _storage.saveUserRole(authResponse.user.role);
      await _storage.saveUserName(authResponse.user.fullName);
      await _storage.saveIsLoggedIn(true);

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

  // ===== LOGOUT =====

  Future<ApiResponse<void>> logout() async {
    try {
      await _dio.post(ApiConfig.logoutEndpoint);

      // Supprimer tous les tokens localement
      await _storage.clearAll();

      return ApiResponse.success(data: null, message: 'Déconnexion réussie');
    } on DioException {
      // Même si erreur backend, on supprime localement
      await _storage.clearAll();

      return ApiResponse.success(
        data: null,
        message: 'Déconnexion locale réussie',
      );
    } catch (_) {
      await _storage.clearAll();

      return ApiResponse.success(
        data: null,
        message: 'Déconnexion locale réussie',
      );
    }
  }

  // ===== CHECK IF LOGGED IN =====

  Future<bool> isLoggedIn() async {
    final token = await _storage.getAccessToken();
    final isLogged = _storage.getIsLoggedIn();
    return token != null && token.isNotEmpty && isLogged;
  }

  // ===== GET USER ROLE =====

  String? getUserRole() {
    return _storage.getUserRole();
  }

  // ===== GET USER ID =====

  String? getUserId() {
    return _storage.getUserId();
  }

  // ===== REFRESH TOKEN =====

  Future<ApiResponse<String>> refreshToken() async {
    try {
      final refreshToken = await _storage.getRefreshToken();

      if (refreshToken == null) {
        return ApiResponse.error(message: 'Aucun refresh token disponible');
      }

      final response = await _dio.post(
        ApiConfig.refreshTokenEndpoint,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String;
      await _storage.saveAccessToken(newAccessToken);

      return ApiResponse.success(
        data: newAccessToken,
        message: 'Token rafraîchi',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur de rafraîchissement du token',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur inconnue', error: e);
    }
  }
}
