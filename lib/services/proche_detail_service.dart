import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../data/models/api_response_model.dart';
import '../data/models/historique_model.dart';
import '../data/models/traitement_model.dart';
import 'api_client.dart';

class ProcheDetailService {
  final Dio _dio = ApiClient().dio;

  /// Récupère les détails complets d'un proche (profil + historique + traitements)
  Future<ApiResponse<Map<String, dynamic>>> getProcheDetails(
    String userId,
    String procheId,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.patientProchesEndpoint}/$procheId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] ?? response.data;
        return ApiResponse.success(
          data: data as Map<String, dynamic>,
          message: 'Détails du proche récupérés',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(message: 'Proche non trouvé');
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur lors de la récupération des détails',
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

  /// Récupère l'historique médical d'un proche
  Future<ApiResponse<List<HistoriqueModel>>> getProcheHistorique(
    String userId,
    String procheId,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.patientProchesEndpoint}/$procheId/historique',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final historique = data
            .map(
              (item) => HistoriqueModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        return ApiResponse.success(
          data: historique,
          message: 'Historique récupéré',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(message: 'Historique non trouvé');
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur lors de la récupération de l\'historique',
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

  /// Récupère les traitements courants d'un proche
  Future<ApiResponse<List<TraitementModel>>> getProcheTraitements(
    String userId,
    String procheId,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.patientProchesEndpoint}/$procheId/traitements',
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> data = response.data['data'] ?? response.data;
        final traitements = data
            .map(
              (item) => TraitementModel.fromJson(item as Map<String, dynamic>),
            )
            .toList();
        return ApiResponse.success(
          data: traitements,
          message: 'Traitements récupérés',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(message: 'Traitements non trouvés');
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur lors de la récupération des traitements',
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
}
