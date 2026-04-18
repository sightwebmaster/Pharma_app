import 'package:dio/dio.dart';

import '../core/config/api_config.dart';
import '../data/models/api_response_model.dart';
import '../data/models/historique_model.dart';
import '../data/models/traitement_model.dart';
import 'api_client.dart';

class ProcheDetailService {
  final Dio _dio = ApiClient().userDio;

  Future<ApiResponse<Map<String, dynamic>>> getProcheDetails(
    String userId,
    String procheId,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.patientGetProfile(userId).replaceFirst('/profile', '')}/proches/$procheId/profil',
      );

      if (response.statusCode == 200 && response.data != null) {
        final payload = _extractPayload(response.data);
        return ApiResponse.success(
          data: payload,
          message: 'Details du proche recuperes',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(message: 'Proche non trouve');
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur lors de la recuperation des details',
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

  Future<ApiResponse<List<HistoriqueModel>>> getProcheHistorique(
    String userId,
    String procheId,
  ) async {
    return ApiResponse.success(
      data: const [],
      message: 'Historique bientot disponible',
      statusCode: 200,
    );
  }

  Future<ApiResponse<List<TraitementModel>>> getProcheTraitements(
    String userId,
    String procheId,
  ) async {
    return ApiResponse.success(
      data: const [],
      message: 'Traitements bientot disponibles',
      statusCode: 200,
    );
  }

  Map<String, dynamic> _extractPayload(dynamic body) {
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return body;
    }
    return const {};
  }
}
