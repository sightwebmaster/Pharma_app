import 'package:dio/dio.dart';
import '../core/config/api_config.dart';
import '../data/models/api_response_model.dart';
import '../data/models/user_model.dart';
import 'api_client.dart';

class PatientProfileService {
  final Dio _dio = ApiClient().dio;

  /// Récupère le profil complet du patient connecté
  /// Retourne: nom, prenom, email, telephone, adresse,
  /// groupeSanguin, allergies, maladiesChroniques
  Future<ApiResponse<UserModel>> getPatientProfile(String userId) async {
    try {
      final response = await _dio.get(ApiConfig.patientProfileEndpoint);

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['data'] ?? response.data;
        final userModel = UserModel.fromJson(userData as Map<String, dynamic>);

        return ApiResponse.success(
          data: userModel,
          message: 'Profil patient récupéré avec succès',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(message: 'Profil non trouvé');
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur lors de la récupération du profil',
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

  /// Récupère le profil complet du patient connecté (endpoint alternatif)
  /// Utilise le endpoint du profil utilisateur général
  Future<ApiResponse<UserModel>> getUserProfile() async {
    try {
      final response = await _dio.get(ApiConfig.profileEndpoint);

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['data'] ?? response.data;
        final userModel = UserModel.fromJson(userData as Map<String, dynamic>);

        return ApiResponse.success(
          data: userModel,
          message: 'Profil utilisateur récupéré avec succès',
          statusCode: response.statusCode,
        );
      }

      return ApiResponse.error(message: 'Profil non trouvé');
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur lors de la récupération du profil',
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
