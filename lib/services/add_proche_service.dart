import 'package:dio/dio.dart';
import '../data/models/api_response_model.dart';
import '../data/models/proche_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class AddProcheService {
<<<<<<< HEAD
  final Dio _dio = ApiClient().dio;
=======
  final Dio _dio = ApiClient().userDio;
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  final StorageService _storage = StorageService();

  /// Ajouter un proche par email (le proche doit être un patient existant)
  /// Le backend cherche le patient par email et récupère ses infos
  Future<ApiResponse<ProcheModel>> addProcheByEmail({
    required String email,
    required String relation,
  }) async {
    try {
      // Récupérer l'userId depuis le storage
      final userId = _storage.getUserId();
      if (userId == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      final response = await _dio.post(
<<<<<<< HEAD
        '/patients/$userId/proches/by-email',
=======
        '/api/v1/patients/$userId/proches/by-email',
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        data: {
          'email': email,
          'relation': relation,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data['data'] ?? response.data;
        final proche = ProcheModel.fromJson(responseData as Map<String, dynamic>);
        return ApiResponse.success(
          data: proche,
          message: 'Proche ajouté avec succès',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(message: 'Erreur lors de l\'ajout du proche');
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ??
                 e.message ??
                 'Erreur lors de l\'ajout du proche par email',
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

  /// Ajouter un proche par QR code (scan du QR qui contient procheUserId)
  /// Le backend cherche le patient par userId et récupère ses infos
  Future<ApiResponse<ProcheModel>> addProcheByQRCode({
    required String procheUserId,
    required String relation,
  }) async {
    try {
      // Récupérer l'userId depuis le storage
      final userId = _storage.getUserId();
      if (userId == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      final response = await _dio.post(
<<<<<<< HEAD
        '/patients/$userId/proches/by-qrcode',
=======
        '/api/v1/patients/$userId/proches/by-qrcode',
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        data: {
          'procheUserId': procheUserId,
          'relation': relation,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data['data'] ?? response.data;
        final proche = ProcheModel.fromJson(responseData as Map<String, dynamic>);
        return ApiResponse.success(
          data: proche,
          message: 'Proche ajouté avec succès',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(message: 'Erreur lors de l\'ajout du proche');
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ??
                 e.message ??
                 'Erreur lors de l\'ajout du proche par QR code',
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
