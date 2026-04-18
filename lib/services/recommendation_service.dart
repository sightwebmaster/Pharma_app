import 'package:dio/dio.dart';

import '../data/models/api_response_model.dart';
import '../data/models/recommendation_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class RecommendationService {
  RecommendationService();

  final Dio _dio = ApiClient().dio;
  final StorageService _storage = StorageService();

  Future<ApiResponse<RecommendationModel>> analyze({
    required String symptoms,
    required String patientId,
    Map<String, dynamic>? patientProfile,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/recommendations/analyze',
        data: {
          'symptoms': symptoms,
          'patient_id': patientId,
          'patient_profile': patientProfile,
        },
        options: Options(
          connectTimeout: const Duration(seconds: 180),
          receiveTimeout: const Duration(seconds: 300),
          sendTimeout: const Duration(seconds: 180),
        ),
      );

      return ApiResponse.success(
        data: RecommendationModel.fromJson(response.data as Map<String, dynamic>),
        message: 'Recommandation générée',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur génération recommandation',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: $e', error: e);
    }
  }

  Future<ApiResponse<RecommendationModel>> validate({
    required String recommendationId,
    required String action,
    String? note,
    List<Map<String, dynamic>>? modifiedMedications,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/recommendations/$recommendationId/validate',
        data: {
          'pharmacist_id': _storage.getUserId() ?? 'unknown-pharmacist',
          'action': action,
          'pharmacist_note': note,
          'modified_medications': modifiedMedications,
        },
        options: Options(
          connectTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 180),
          sendTimeout: const Duration(seconds: 120),
        ),
      );

      return ApiResponse.success(
        data: RecommendationModel.fromJson(response.data as Map<String, dynamic>),
        message: 'Recommandation mise à jour',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur validation recommandation',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: $e', error: e);
    }
  }

  Future<ApiResponse<List<RecommendationModel>>> getPatientHistory(String patientId) async {
    try {
      final response = await _dio.get(
        '/api/v1/recommendations/patient/$patientId',
        options: Options(
          connectTimeout: const Duration(seconds: 90),
          receiveTimeout: const Duration(seconds: 120),
        ),
      );
      final raw = response.data;
      final List<dynamic> payload;
      if (raw is List<dynamic>) {
        payload = raw;
      } else if (raw is Map<String, dynamic>) {
        payload = [raw];
      } else {
        payload = const [];
      }

      final items = payload
          .whereType<Map<String, dynamic>>()
          .map(RecommendationModel.fromJson)
          .toList();

      return ApiResponse.success(
        data: items,
        message: 'Historique chargé',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur chargement historique recommandations',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: $e', error: e);
    }
  }
}
