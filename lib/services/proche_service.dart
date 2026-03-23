import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../data/models/api_response_model.dart';
import '../data/models/proche_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class ProcheService {
  final Dio _dio = ApiClient().dio;
  final StorageService _storage = StorageService();

  /// Get all family members (proches) for the current patient
  Future<ApiResponse<List<ProcheModel>>> getMyProches() async {
    try {
      // Récupérer l'userId depuis le storage (comme dans AddProcheService)
      final userId = _storage.getUserId();
      if (userId == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      // Utiliser le bon endpoint avec l'userId
      final response = await _dio.get('/patients/$userId/proches');
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
        message: e.response?.data?['message'] ?? 'Erreur chargement proches',
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }

  /// Add a new proche (link to an existing patient account)
  ///
  /// [patientId] - The ID or email of the patient to link as a proche
  /// [relation] - The relationship type (Père, Mère, Grand-père, etc.)
  Future<ApiResponse<ProcheModel>> addProche({
    required String patientId,
    required String relation,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.patientProchesEndpoint,
        data: {'patientId': patientId, 'relation': relation},
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
        message:
            e.response?.data?['message'] ?? 'Erreur lors de l\'ajout du proche',
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }

  /// Delete a proche (unlink the patient relationship)
  ///
  /// [procheId] - The ID of the proche relationship to delete
  Future<ApiResponse<void>> deleteProche(String procheId) async {
    try {
      await _dio.delete('${ApiConfig.patientProcheDetailEndpoint}$procheId');
      return ApiResponse.success(
        data: null,
        statusCode: 200,
        message: 'Proche supprimé avec succès',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message:
            e.response?.data?['message'] ?? 'Erreur lors de la suppression',
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }

  /// Get details of a specific proche
  ///
  /// [procheId] - The ID of the proche to fetch
  Future<ApiResponse<ProcheModel>> getProcheById(String procheId) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.patientProcheDetailEndpoint}$procheId',
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
        message: e.response?.data?['message'] ?? 'Erreur chargement détails',
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }
}
