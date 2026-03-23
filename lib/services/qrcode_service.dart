import 'package:dio/dio.dart';
import '../data/models/api_response_model.dart';
import '../data/models/qrcode_model.dart';
import 'api_client.dart';

class QRCodeService {
  final Dio _dio = ApiClient().dio;

  /// Récupère le QR code du patient (données complètes)
  Future<ApiResponse<QRCodeModel>> getPatientQRCode(String userId) async {
    try {
      final response = await _dio.get('/api/v1/patients/$userId/qrcode');

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
      final response = await _dio.get(
        '/api/v1/pharmaciens/patients/$userId/profile',
      );

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
}
