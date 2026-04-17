import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../data/models/api_response_model.dart';
import '../data/models/user_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class PatientProfileService {
  final Dio _dio = ApiClient().dio; // ✅ Gateway — JWT requis
  final StorageService _storage = StorageService();

  // ═══════════════════════════════════════════════════════════════
  // GET PROFIL PATIENT
  // ✅ Endpoint réel : GET /api/v1/pharmaciens/patients/{patientId}/profile
  // ❌ ÉTAIT : /api/v1/patient/profile → n'existe pas
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<UserModel>> getPatientProfile(String patientId) async {
    try {
      // ✅ Endpoint correct du backend
      final response = await _dio.get(
        ApiConfig.patientProfileByPharmacien(patientId),
        queryParameters: {
          // Le pharmacienUserId vient du token via Gateway (X-User-Id)
          // Mais si nécessaire côté Flutter, on peut l'envoyer en query param
          'pharmacienUserId': _storage.getUserId(),
        },
      );

      final userData = response.data['data'] ?? response.data;
      final userModel = UserModel.fromJson(userData as Map<String, dynamic>);

      return ApiResponse.success(
        data: userModel,
        message: 'Profil patient récupéré',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur récupération profil patient',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // GET PROFIL DU PATIENT CONNECTÉ (son propre profil)
  // ✅ Utilise le userId stocké localement
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<UserModel>> getMyProfile() async {
    try {
      final userId = _storage.getUserId();
      final role = _storage.getUserRole();

      if (userId == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      // ✅ Route selon le rôle
      final endpoint = role == 'PHARMACIEN'
          ? ApiConfig.pharmacienProfile(userId)
          : ApiConfig.patientProfileByPharmacien(userId);

      final response = await _dio.get(endpoint);

      final userData = response.data['data'] ?? response.data;
      final userModel = UserModel.fromJson(userData as Map<String, dynamic>);

      return ApiResponse.success(
        data: userModel,
        message: 'Profil récupéré',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur récupération profil',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // UPDATE PROFIL
  // ❌ Endpoint /api/v1/users/profile n'existe pas dans le backend
  // ✅ À implémenter dans le backend si nécessaire
  // Pour l'instant → retourne succès local
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<UserModel>> updatePatientProfile(
    UserModel userModel,
  ) async {
    // TODO: implémenter PUT /api/v1/patients/{userId}/profile dans user-service
    return ApiResponse.error(
      message: 'Mise à jour profil non disponible pour le moment',
      statusCode: 501,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // QR CODE — récupère le QR Code du patient connecté
  // Le QR Code est stocké dans patientProfile.qrCode (base64)
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<String>> getMyQrCode() async {
    try {
      final userId = _storage.getUserId();
      if (userId == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      final response = await _dio.get(
        ApiConfig.patientProfileByPharmacien(userId),
      );

      final userData = response.data['data'] ?? response.data;
      final qrCode = userData['qrCode'] as String?;

      if (qrCode == null || qrCode.isEmpty) {
        return ApiResponse.error(message: 'QR Code non disponible');
      }

      return ApiResponse.success(
        data: qrCode,
        message: 'QR Code récupéré',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur récupération QR Code',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }
}