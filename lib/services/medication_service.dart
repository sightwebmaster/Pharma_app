import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../data/models/api_response_model.dart';
import '../data/models/medication_model.dart';
import 'api_client.dart';

class MedicationService {
  final Dio _dio = ApiClient().dio;

  Future<ApiResponse<List<MedicationModel>>> getMyMedications() async {
    try {
      final response = await _dio.get(ApiConfig.patientMedicationsEndpoint);
      final List<dynamic> data = response.data as List<dynamic>;
      final meds = data
          .map((e) => MedicationModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return ApiResponse.success(
        data: meds, 
        statusCode: response.statusCode,
        message: 'Médicaments chargés avec succès',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data?['message'] ?? 'Erreur chargement médicaments',
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }

  Future<ApiResponse<void>> confirmTaken(String medicationId) async {
    try {
      await _dio.post('/patient/medications/$medicationId/confirm');
      return ApiResponse.success(
        data: null,  // ✅ REQUIS - data: null pour les réponses void
        statusCode: 200,
        message: 'Prise confirmée avec succès',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data?['message'] ?? 'Erreur lors de la confirmation',
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }

  // Autres méthodes possibles...
  
  Future<ApiResponse<void>> skipMedication(String medicationId) async {
    try {
      await _dio.post('/patient/medications/$medicationId/skip');
      return ApiResponse.success(
        data: null,  // ✅ data: null pour void
        statusCode: 200,
        message: 'Médicament reporté',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur',
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }
}