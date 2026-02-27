import 'package:dio/dio.dart';
import 'auth_service.dart';

class ApiService {
  // localhost → navigateur web
  // 10.0.2.2  → émulateur Android
  // 192.168.x.x → vrai téléphone (remplacer par ton IP)
  static const String _baseUrl = 'http://10.0.2.2:8000';

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  // ── HEADERS AVEC TOKEN JWT ────────────────────────────────────────────────
  static Future<Options> _authOptions() async {
    final token = await AuthService.getAccessToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ── SYNC PROFIL (à appeler après chaque login/inscription) ───────────────
  // Crée le profil dans MySQL si premier login, sinon retourne l'existant
  static Future<Map<String, dynamic>?> syncProfile() async {
    try {
      final response = await _dio.post(
        '/api/users/sync',
        options: await _authOptions(),
      );
      return response.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      print('syncProfile error: ${e.response?.statusCode} ${e.message}');
      return null;
    }
  }

  // ── MON PROFIL ────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getMyProfile() async {
    try {
      final response = await _dio.get(
        '/api/users/me',
        options: await _authOptions(),
      );
      return response.data as Map<String, dynamic>?;
    } on DioException catch (e) {
      print('getMyProfile error: ${e.response?.statusCode} ${e.message}');
      return null;
    }
  }

  static Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? dateOfBirth, // format: "YYYY-MM-DD"
  }) async {
    try {
      await _dio.put(
        '/api/users/me',
        data: {
          if (firstName != null) 'firstName': firstName,
          if (lastName != null) 'lastName': lastName,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
          if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        },
        options: await _authOptions(),
      );
      return true;
    } on DioException catch (e) {
      print('updateProfile error: ${e.response?.statusCode} ${e.message}');
      return false;
    }
  }

  // ── LISTE PATIENTS (pour le pharmacien) ──────────────────────────────────
  static Future<List<dynamic>> getPatients() async {
    try {
      final response = await _dio.get(
        '/api/users/patients',
        options: await _authOptions(),
      );
      return response.data as List<dynamic>? ?? [];
    } on DioException catch (e) {
      print('getPatients error: ${e.response?.statusCode} ${e.message}');
      return [];
    }
  }

  // ── ALLERGIES ─────────────────────────────────────────────────────────────
  static Future<List<dynamic>> getAllergies() async {
    try {
      final response = await _dio.get(
        '/api/users/me/allergies',
        options: await _authOptions(),
      );
      return response.data as List<dynamic>? ?? [];
    } on DioException catch (e) {
      print('getAllergies error: ${e.response?.statusCode} ${e.message}');
      return [];
    }
  }

  static Future<bool> addAllergy({
    required String substanceName,
    String severity = 'MILD', // MILD, MODERATE, SEVERE
    String? description,
  }) async {
    try {
      await _dio.post(
        '/api/users/me/allergies',
        data: {
          'substanceName': substanceName,
          'severity': severity,
          if (description != null) 'description': description,
        },
        options: await _authOptions(),
      );
      return true;
    } on DioException catch (e) {
      print('addAllergy error: ${e.response?.statusCode} ${e.message}');
      return false;
    }
  }

  static Future<bool> deleteAllergy(String allergyId) async {
    try {
      await _dio.delete(
        '/api/users/me/allergies/$allergyId',
        options: await _authOptions(),
      );
      return true;
    } on DioException catch (e) {
      print('deleteAllergy error: ${e.response?.statusCode} ${e.message}');
      return false;
    }
  }

  // ── FCM TOKEN ─────────────────────────────────────────────────────────────
  static Future<void> updateFcmToken(String fcmToken) async {
    try {
      await _dio.put(
        '/api/users/me/fcm-token',
        data: {'fcmToken': fcmToken},
        options: await _authOptions(),
      );
    } on DioException catch (e) {
      print('updateFcmToken error: ${e.message}');
    }
  }

  // ── DÉCONNEXION ───────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await AuthService.logout();
  }
}