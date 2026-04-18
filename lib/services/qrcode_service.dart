import 'package:dio/dio.dart';

import '../core/config/api_config.dart';
import '../data/models/api_response_model.dart';
import '../data/models/qrcode_model.dart';
import 'api_client.dart';

class QRCodeService {
  final Dio _dio = ApiClient().userDio;

  Future<ApiResponse<String>> getPatientQRCode(String userId) async {
    try {
      final response = await _dio.get(ApiConfig.patientQrCode(userId));
      final qrCode = _extractQrCode(response.data);

      if (qrCode == null || qrCode.isEmpty) {
        return ApiResponse.error(message: 'QR Code non trouve');
      }

      return ApiResponse.success(
        data: qrCode,
        message: 'QR Code recupere',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur lors de la recuperation du QR Code',
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

  Future<ApiResponse<QRCodeModel>> scanPatientQRCode(String userId) async {
    try {
      final response = await _dio.get(ApiConfig.patientProfileByPharmacien(userId));
      final payload = _extractPayload(response.data);

      if (payload.isEmpty) {
        return ApiResponse.error(message: 'Profil patient non trouve');
      }

      final qrCodeModel = QRCodeModel(
        id: (payload['userId'] ?? payload['id'] ?? '').toString(),
        nom: (payload['nom'] ?? '').toString(),
        prenom: (payload['prenom'] ?? '').toString(),
        email: (payload['email'] ?? '').toString(),
        telephone: payload['telephone']?.toString(),
        adresse: payload['adresse']?.toString(),
        groupeSanguin: payload['groupeSanguin']?.toString(),
        allergies: _stringList(payload['allergies']),
        maladiesChroniques: _stringList(payload['maladiesChroniques']),
        dateNaissance: DateTime.tryParse(payload['dateNaissance']?.toString() ?? ''),
      );

      return ApiResponse.success(
        data: qrCodeModel,
        message: 'Profil patient recupere',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur lors de la lecture du QR Code',
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

  Future<ApiResponse<String>> generateShareQRCode(String shareLink) async {
    if (shareLink.isEmpty) {
      return ApiResponse.error(
        message: 'Le lien de partage ne peut pas etre vide',
      );
    }

    return ApiResponse.success(
      data: shareLink,
      message: 'QR code genere avec succes',
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

  String? _extractQrCode(dynamic body) {
    if (body == null) {
      return null;
    }
    if (body is String) {
      return body.trim().replaceAll('"', '');
    }
    if (body is Map<String, dynamic>) {
      final nested = body['data'] ?? body['qrCode'] ?? body['value'];
      if (nested is String) {
        return nested.trim().replaceAll('"', '');
      }
    }
    return body.toString().trim().replaceAll('"', '');
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return const [];
  }
}
