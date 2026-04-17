import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../data/models/api_response_model.dart';
import '../data/models/medication_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class MedicationService {
  final Dio _dio = ApiClient().dio; // ✅ Gateway — JWT requis
  final StorageService _storage = StorageService();

  // ═══════════════════════════════════════════════════════════════
  // PRISES DU JOUR (remplace getMyMedications)
  // ✅ Endpoint réel : GET /api/treatments/patient/{patientId}/prises/today
  // ❌ ÉTAIT : /api/v1/patient/medications → n'existe pas
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<List<MedicationModel>>> getPrisesAujourdhui() async {
    try {
      final patientId = _storage.getUserId();
      if (patientId == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      final response = await _dio.get(
        ApiConfig.prisesAujourdhui(patientId),
      );

      final List<dynamic> data = response.data as List<dynamic>;
      final prises = data
          .map((e) => MedicationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(
        data: prises,
        message: 'Prises du jour chargées',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur chargement prises',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // CONFIRMER UNE PRISE
  // ✅ Endpoint réel : POST /api/treatments/prises/{priseId}/confirmer
  // ❌ ÉTAIT : /patient/medications/{id}/confirm → n'existe pas
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<void>> confirmerPrise(String priseId) async {
    try {
      // ✅ Pas de body requis — le Gateway propage X-User-Id pour vérifier
      await _dio.post(ApiConfig.confirmerPrise(priseId));

      return ApiResponse.success(
        data: null,
        statusCode: 200,
        message: 'Prise confirmée avec succès',
      );
    } on DioException catch (e) {
      final msg = e.response?.data is Map
          ? e.response?.data['message'] ?? e.message
          : e.message;
      return ApiResponse.error(
        message: msg ?? 'Erreur confirmation prise',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // RECHERCHE MÉDICAMENT PAR NOM
  // ✅ Endpoint réel : GET /api/v1/medications/search?q=doliprane
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<List<MedicationModel>>> searchMedications(
    String query,
  ) async {
    try {
      final response = await _dio.get(
        ApiConfig.medicamentSearch,
        queryParameters: {'q': query},
      );

      final List<dynamic> data = response.data as List<dynamic>;
      final meds = data
          .map((e) => MedicationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(
        data: meds,
        message: '${meds.length} médicament(s) trouvé(s)',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur recherche médicament',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // RECHERCHE PAR SYMPTÔMES
  // ✅ Endpoint réel : POST /api/v1/medications/search/symptoms
  // Body : ["maux de tête", "fièvre"]
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<List<MedicationModel>>> searchBySymptomes(
    List<String> symptomes,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.medicamentSearchSymptoms,
        data: symptomes,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      final meds = data
          .map((e) => MedicationModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ApiResponse.success(
        data: meds,
        message: '${meds.length} médicament(s) recommandé(s)',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur recherche par symptômes',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // VÉRIFIER CONTRE-INDICATIONS
  // ✅ Endpoint réel : POST /api/v1/medications/check-contre-indications
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<Map<String, dynamic>>> checkContreIndications({
    required String medicamentId,
    List<String>? allergies,
    List<String>? maladiesChroniques,
    int? age,
    bool enceinte = false,
    bool allaitement = false,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.checkContreIndications,
        data: {
          'medicamentId': medicamentId,
          if (allergies != null) 'allergies': allergies,
          if (maladiesChroniques != null)
            'maladiesChroniques': maladiesChroniques,
          if (age != null) 'age': age,
          'enceinte': enceinte,
          'allaitement': allaitement,
        },
      );

      // Réponse : { safe, medicamentNom, alertes[], avertissements[] }
      return ApiResponse.success(
        data: response.data as Map<String, dynamic>,
        message: response.data['safe'] == true
            ? 'Aucune contre-indication détectée'
            : '⚠️ Contre-indications détectées',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur vérification contre-indications',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // SKIP — non implémenté dans le backend
  // Une prise "manquée" est détectée automatiquement par le Scheduler
  // après 30 minutes — pas besoin de skip manuel
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<void>> skipMedication(String priseId) async {
    // ❌ /patient/medications/{id}/skip n'existe pas dans le backend
    // Le Scheduler détecte automatiquement les prises manquées
    return ApiResponse.error(
      message: 'Skip non disponible — les prises manquées sont détectées automatiquement',
      statusCode: 501,
    );
  }
}