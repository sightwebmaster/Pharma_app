import 'package:dio/dio.dart';
import '../data/models/api_response_model.dart';
import '../data/models/historique_model.dart';
import '../data/models/traitement_model.dart';
import 'api_client.dart';

class ProcheDetailService {
  final Dio _dio = ApiClient().dio;

  /// Récupère les détails complets d'un proche (profil médical)
  /// Endpoint: GET /patients/{userId}/proches/{procheId}/profil
  Future<ApiResponse<Map<String, dynamic>>> getProcheDetails(
    String userId,
    String procheId,
  ) async {
    try {
      final response = await _dio.get(
        '/patients/$userId/proches/$procheId/profil',
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
  /// NOTE: Pas encore implémenté dans le backend
  /// Sera disponible via prescription-service
  Future<ApiResponse<List<HistoriqueModel>>> getProcheHistorique(
    String userId,
    String procheId,
  ) async {
    try {
      // Pour maintenant, retourner une liste vide avec un message
      // Quand prescription-service est prêt: GET /api/v1/ordonnances/patient/{procheUserId}
      return ApiResponse.success(
        data: [],
        message: 'Historique - Bientôt disponible',
        statusCode: 200,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur inconnue: ${e.toString()}',
        error: e,
      );
    }
  }

  /// Récupère les traitements courants d'un proche
  /// NOTE: Pas encore implémenté dans le backend
  /// Sera disponible via prescription-service
  Future<ApiResponse<List<TraitementModel>>> getProcheTraitements(
    String userId,
    String procheId,
  ) async {
    try {
      // Pour maintenant, retourner une liste vide avec un message
      // Quand prescription-service est prêt: GET /api/v1/prescriptions/patient/{procheUserId}
      return ApiResponse.success(
        data: [],
        message: 'Traitements - Bientôt disponible',
        statusCode: 200,
      );
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur inconnue: ${e.toString()}',
        error: e,
      );
    }
  }
}
