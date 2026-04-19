import 'package:dio/dio.dart';
import '../data/models/api_response_model.dart';
import '../data/models/proche_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

/// ProcheService — gestion des proches d'un patient
///
/// Endpoints réels (PatientController.java) :
///   GET    /api/v1/patients/{userId}/proches
///   POST   /api/v1/patients/{userId}/proches/by-email
///   POST   /api/v1/patients/{userId}/proches/by-qrcode
///   GET    /api/v1/patients/{userId}/proches/{procheId}/profil
///   DELETE /api/v1/patients/{userId}/proches/{procheId}
class ProcheService {
<<<<<<< HEAD
  final Dio _dio = ApiClient().dio; // Gateway — JWT requis
=======
  final Dio _dio = ApiClient().userDio; // user-service direct — JWT requis
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  final StorageService _storage = StorageService();

  // ═══════════════════════════════════════════════════════════════
  // GET — tous les proches du patient connecté
  // ✅ GET /api/v1/patients/{userId}/proches
  // ❌ ÉTAIT : /patients/{userId}/proches (sans /api/v1)
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<List<ProcheModel>>> getMyProches() async {
    try {
      final userId = _storage.getUserId();
      if (userId == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      final response = await _dio.get('/api/v1/patients/$userId/proches');

      final List<dynamic> data = response.data as List<dynamic>;
      final proches = data
          .map((e) => ProcheModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(
        data: proches,
        statusCode: response.statusCode,
        message: 'Proches chargés avec succès',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur chargement proches',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ADD PROCHE PAR EMAIL
  // ✅ POST /api/v1/patients/{userId}/proches/by-email
  // Body : { email, relation }
  // ❌ ÉTAIT : patientProchesEndpoint → /api/v1/patient/proches (fantôme)
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<ProcheModel>> addProcheByEmail({
    required String email,
    required String relation,
  }) async {
    try {
      final userId = _storage.getUserId();
      if (userId == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      final response = await _dio.post(
        '/api/v1/patients/$userId/proches/by-email',
        data: {
          'email': email,
          'relation': relation,
        },
      );

      final proche = ProcheModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      return ApiResponse.success(
        data: proche,
        statusCode: response.statusCode,
        message: 'Proche ajouté avec succès',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur ajout proche',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // ADD PROCHE PAR QR CODE
  // ✅ POST /api/v1/patients/{userId}/proches/by-qrcode
  // Body : { qrCodeContent, relation }
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<ProcheModel>> addProcheByQrCode({
    required String qrCodeContent, // UUID Keycloak lu par la caméra
    required String relation,
  }) async {
    try {
      final userId = _storage.getUserId();
      if (userId == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      final response = await _dio.post(
        '/api/v1/patients/$userId/proches/by-qrcode',
        data: {
<<<<<<< HEAD
          'qrCodeContent': qrCodeContent,
=======
          'procheUserId': qrCodeContent,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
          'relation': relation,
        },
      );

      final proche = ProcheModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      return ApiResponse.success(
        data: proche,
        statusCode: response.statusCode,
        message: 'Proche ajouté via QR Code',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur ajout proche par QR',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // GET PROFIL D'UN PROCHE
  // ✅ GET /api/v1/patients/{userId}/proches/{procheId}/profil
  // ❌ ÉTAIT : patientProcheDetailEndpoint → /api/v1/patient/proches/ (fantôme)
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<ProcheModel>> getProcheById(String procheId) async {
    try {
      final userId = _storage.getUserId();
      if (userId == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      final response = await _dio.get(
        '/api/v1/patients/$userId/proches/$procheId/profil',
      );

      final proche = ProcheModel.fromJson(
        response.data as Map<String, dynamic>,
      );

      return ApiResponse.success(
        data: proche,
        statusCode: response.statusCode,
        message: 'Détails du proche chargés',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur chargement proche',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // DELETE PROCHE
  // ✅ DELETE /api/v1/patients/{userId}/proches/{procheId}
  // ❌ ÉTAIT : patientProcheDetailEndpoint → /api/v1/patient/proches/ (fantôme)
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<void>> deleteProche(String procheId) async {
    try {
      final userId = _storage.getUserId();
      if (userId == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      await _dio.delete('/api/v1/patients/$userId/proches/$procheId');

      return ApiResponse.success(
        data: null,
        statusCode: 204,
        message: 'Proche supprimé avec succès',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur suppression proche',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }
<<<<<<< HEAD
}
=======
}
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
