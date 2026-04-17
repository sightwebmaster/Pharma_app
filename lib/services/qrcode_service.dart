import 'package:dio/dio.dart';
import '../data/models/api_response_model.dart';
import '../data/models/qrcode_model.dart';
import 'api_client.dart';

class QRCodeService {
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
  }
}
