import 'package:dio/dio.dart';
<<<<<<< HEAD
=======

import '../core/config/api_config.dart';
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
import '../data/models/api_response_model.dart';
import '../data/models/qrcode_model.dart';
import 'api_client.dart';

class QRCodeService {
<<<<<<< HEAD
  final Dio _dio = ApiClient().dio;

  /// Récupère le QR code du patient (données complètes)
  Future<ApiResponse<QRCodeModel>> getPatientQRCode(String userId) async {
    try {
      final response = await _dio.get('/patients/$userId/qrcode');

      if (response.statusCode == 200 && response.data != null) {
        final qrCodeModel = QRCodeModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return ApiResponse.success(
          data: qrCodeModel,
          message: 'QR Code récupéré',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(message: 'QR Code non trouvé');
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur lors de la récupération du QR Code',
=======
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
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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

<<<<<<< HEAD
  /// Récupère le profil complet du patient à partir du QR code (pour pharmacien)
  Future<ApiResponse<QRCodeModel>> scanPatientQRCode(String userId) async {
    try {
      final response = await _dio.get('/pharmaciens/patients/$userId/profile');

      if (response.statusCode == 200 && response.data != null) {
        final qrCodeModel = QRCodeModel.fromJson(
          response.data['data'] ?? response.data,
        );
        return ApiResponse.success(
          data: qrCodeModel,
          message: 'Profil patient récupéré',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(message: 'Profil patient non trouvé');
=======
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
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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

<<<<<<< HEAD
  /// Génère dynamiquement un QR code basé sur un lien de partage
  /// [shareLink] le lien URL à encoder dans le QR code
  /// Retourne le contenu du QR code (le lien lui-même)
  ///
  /// Exemple: generateShareQRCode('https://pharmaapp.com/profile/user123')
  /// retournera le même lien (le vrai QR sera généré côté UI avec qr_flutter package)
  Future<ApiResponse<String>> generateShareQRCode(String shareLink) async {
    try {
      // Valider que le lien n'est pas vide
      if (shareLink.isEmpty) {
        return ApiResponse.error(
          message: 'Le lien de partage ne peut pas être vide',
        );
      }

      // Optionnel: faire appel au backend pour valider ou générer le QR
      // Pour l'instant, on retourne simplement le lien (sera encodé en QR côté UI)
      return ApiResponse.success(
        data: shareLink,
        message: 'QR code généré avec succès',
        statusCode: 200,
      );

      // Si vous voulez faire appel au backend:
      // final response = await _dio.post(
      //   '/qrcode/generate',
      //   data: {'shareLink': shareLink},
      // );
      //
      // if (response.statusCode == 200) {
      //   final qrcode = response.data['qrcode'] ?? shareLink;
      //   return ApiResponse.success(
      //     data: qrcode,
      //     message: 'QR code généré',
      //   );
      // }
      // return ApiResponse.error(message: 'Erreur génération QR');
    } catch (e) {
      return ApiResponse.error(
        message: 'Erreur lors de la génération du QR code: ${e.toString()}',
        error: e,
      );
    }
=======
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
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  }
}
