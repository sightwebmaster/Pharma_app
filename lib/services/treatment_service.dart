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

  Future<ApiResponse<List<PrisePlanifiee>>> getTodayPrises(
    String patientId,
    String token,
  ) async {
    try {
      final response = await _dio.get(
        ApiConfig.prisesAujourdhui(patientId),
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
        message: e.message ?? 'Erreur chargement prises',
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }

  Future<ApiResponse<PrisePlanifiee>> confirmerPrise(
    String priseId,
    String token,
  ) async {
    try {
      final response = await _dio.post(
        ApiConfig.confirmerPrise(priseId),
      );

      final prise = PrisePlanifiee.fromJson(
        response.data as Map<String, dynamic>,
      );
      return ApiResponse.success(
        data: prise,
        statusCode: response.statusCode,
        message: 'Prise confirmée',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur confirmation prise',
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
        message: e.message ?? 'Erreur création traitement',
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
        message: e.message ?? 'Erreur chargement rapport',
        statusCode: e.response?.statusCode,
        error: e,
      );
    }
  }
}
