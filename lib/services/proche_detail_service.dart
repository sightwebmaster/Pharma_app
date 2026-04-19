import 'package:dio/dio.dart';

import '../core/config/api_config.dart';
import '../data/models/api_response_model.dart';
import '../data/models/historique_model.dart';
import '../data/models/prise_planifiee.dart';
import '../data/models/traitement_model.dart';
import 'api_client.dart';

class ProcheDetailService {
  final Dio _userDio = ApiClient().userDio;
  final Dio _gatewayDio = ApiClient().dio;

  Future<ApiResponse<Map<String, dynamic>>> getProcheDetails(
    String userId,
    String procheId,
  ) async {
    try {
      final response = await _userDio.get(
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
    try {
      final detailsResponse = await getProcheDetails(userId, procheId);
      final procheUserId = detailsResponse.data?['userId']?.toString();
      if (procheUserId == null || procheUserId.isEmpty) {
        return ApiResponse.success(
          data: const [],
          message: 'Aucun historique disponible',
          statusCode: 200,
        );
      }

      final response = await _gatewayDio.get(
        ApiConfig.toutesLesPrises(procheUserId),
        options: Options(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final prises = (response.data as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PrisePlanifiee.fromJson)
          .toList();

      final items = prises.map((prise) {
        return HistoriqueModel(
          id: prise.id,
          date: prise.heurePrevue ?? '',
          type: 'prise',
          detail: prise.statut == 'CONFIRMEE'
              ? 'Prise confirmee'
              : prise.statut == 'MANQUEE'
                  ? 'Prise manquee'
                  : 'Prise en attente',
          diagnostic: prise.medicamentNom,
          traitement: prise.dosage ?? prise.type,
        );
      }).toList();

      return ApiResponse.success(
        data: items,
        message: 'Historique charge',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur lors du chargement de l historique',
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

  Future<ApiResponse<List<TraitementModel>>> getProcheTraitements(
    String userId,
    String procheId,
  ) async {
    try {
      final detailsResponse = await getProcheDetails(userId, procheId);
      final procheUserId = detailsResponse.data?['userId']?.toString();
      if (procheUserId == null || procheUserId.isEmpty) {
        return ApiResponse.success(
          data: const [],
          message: 'Aucun traitement disponible',
          statusCode: 200,
        );
      }

      final response = await _gatewayDio.get(
        ApiConfig.toutesLesPrises(procheUserId),
        options: Options(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final prises = (response.data as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(PrisePlanifiee.fromJson)
          .toList();

      final Map<String, List<PrisePlanifiee>> grouped = {};
      for (final prise in prises) {
        final key = prise.traitementId.isNotEmpty ? prise.traitementId : prise.id;
        grouped.putIfAbsent(key, () => []).add(prise);
      }

      final items = grouped.entries.map((entry) {
        final first = entry.value.first;
        final heures = entry.value
            .map((item) => item.heurePrevueDateTime)
            .whereType<DateTime>()
            .toList()
          ..sort();
        final isAllConfirmed = entry.value.every((item) => item.statut == 'CONFIRMEE');
        final hasMissed = entry.value.any((item) => item.statut == 'MANQUEE');

        return TraitementModel(
          id: entry.key,
          medicament: first.medicamentNom,
          dosage: first.dosage ?? 'N/A',
          frequence: entry.value.map((item) => _formatHeure(item.heurePrevue)).join(' - '),
          dateDebut: heures.isEmpty ? null : heures.first.toIso8601String(),
          dateFin: heures.isEmpty ? null : heures.last.toIso8601String(),
          statut: isAllConfirmed
              ? 'termine'
              : hasMissed
                  ? 'a surveiller'
                  : 'en cours',
          notes: first.instruction,
        );
      }).toList();

      return ApiResponse.success(
        data: items,
        message: 'Traitements charges',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur lors du chargement des traitements',
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

  String _formatHeure(String? raw) {
    final date = raw == null ? null : DateTime.tryParse(raw);
    if (date == null) {
      return raw ?? 'N/A';
    }
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
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
