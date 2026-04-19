import 'package:dio/dio.dart';
import 'package:pharma_app/core/config/api_config.dart';
import 'package:pharma_app/data/models/api_response_model.dart';
import 'package:pharma_app/data/models/traitement.dart';
import 'package:pharma_app/data/models/prise_planifiee.dart';
import 'package:pharma_app/data/models/adherence_summary.dart';
import 'package:pharma_app/services/api_client.dart';
import 'dart:convert';
import 'package:logger/logger.dart';



class TreatmentService {
  final Dio _dio = ApiClient().dio;
  final Logger log = Logger();

<<<<<<< HEAD
=======
  String _extractErrorMessage(
    DioException error,
    String fallback,
  ) {
    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      final message =
          data['message'] ??
          data['error'] ??
          data['details'] ??
          data['path'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      return data;
    }

    return error.message ?? fallback;
  }

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  Future<ApiResponse<List<PrisePlanifiee>>> getTodayPrises(
    String patientId,
    String token,
  ) async {
    try {
      final response = await _dio.get(
        ApiConfig.prisesAujourdhui(patientId),
<<<<<<< HEAD
=======
        options: Options(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      );

      if (response.data is List) {
    // Afficher le JSON brut dans la console
    log.i('JSON brut reçu: ${response.data}');
    // Ou pour un affichage plus lisible
    log.i('JSON brut (formaté): ${JsonEncoder.withIndent('  ').convert(response.data)}');
    
    final prises = (response.data as List)
        .map((json) => PrisePlanifiee.fromJson(json as Map<String, dynamic>))
        .toList();
    log.i('Prises du jour chargées: ${prises.length}');
    return ApiResponse.success(
      data: prises,
      statusCode: response.statusCode,
      message: 'Prises chargées avec succès',
    );
}
      return ApiResponse.error(message: 'Format invalide', statusCode: response.statusCode);
    } on DioException catch (e) {
      return ApiResponse.error(
<<<<<<< HEAD
        message: e.message ?? 'Erreur chargement prises',
=======
        message: _extractErrorMessage(e, 'Erreur chargement prises'),
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }

  Future<ApiResponse<List<PrisePlanifiee>>> getAllPrises(
    String patientId,
    String token,
  ) async {
    try {
      final response = await _dio.get(
        ApiConfig.toutesLesPrises(patientId),
        options: Options(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.data is List) {
        final prises = (response.data as List)
            .map((json) => PrisePlanifiee.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResponse.success(
          data: prises,
          statusCode: response.statusCode,
          message: 'Toutes les prises chargées avec succès',
        );
      }

      return ApiResponse.error(
        message: 'Format invalide',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: _extractErrorMessage(e, 'Erreur chargement prises'),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }

  Future<ApiResponse<PrisePlanifiee>> confirmerPrise(
<<<<<<< HEAD
    String priseId,
=======
    PrisePlanifiee prise,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    String token,
  ) async {
    try {
      final response = await _dio.post(
<<<<<<< HEAD
        ApiConfig.confirmerPrise(priseId),
      );

      final prise = PrisePlanifiee.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiResponse.success(
        data: prise,
=======
        ApiConfig.confirmerPrise(prise.traitementId, prise.id),
        options: Options(
          connectTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      final confirmedPrise = PrisePlanifiee.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiResponse.success(
        data: confirmedPrise,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        statusCode: response.statusCode,
        message: 'Prise confirmée',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
<<<<<<< HEAD
        message: e.message ?? 'Erreur confirmation prise',
=======
        message: _extractErrorMessage(e, 'Erreur confirmation prise'),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }

  Future<ApiResponse<Traitement>> creerTraitement(
    Map<String, dynamic> body,
    String token,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.creerTraitement,
        data: body,
<<<<<<< HEAD
=======
        options: Options(
          connectTimeout: const Duration(seconds: 120),
          receiveTimeout: const Duration(seconds: 180),
          sendTimeout: const Duration(seconds: 120),
        ),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      );

      final traitement = Traitement.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiResponse.success(
        data: traitement,
        statusCode: response.statusCode,
        message: 'Traitement créé avec succès',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
<<<<<<< HEAD
        message: e.message ?? 'Erreur création traitement',
=======
        message: _extractErrorMessage(e, 'Erreur création traitement'),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }

  Future<ApiResponse<AdherenceSummary>> getAdherenceSummary(
    String patientId,
    String token,
  ) async {
    try {
      final response = await _dio.get(
        ApiConfig.adherenceSummary(patientId),
<<<<<<< HEAD
=======
        options: Options(
          connectTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(seconds: 45),
        ),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      );

      final summary = AdherenceSummary.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiResponse.success(
        data: summary,
        statusCode: response.statusCode,
        message: 'Rapport d''observance chargé',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
<<<<<<< HEAD
        message: e.message ?? 'Erreur chargement rapport',
=======
        message: _extractErrorMessage(e, 'Erreur chargement rapport'),
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }
}
