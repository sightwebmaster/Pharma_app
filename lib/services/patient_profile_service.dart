import 'package:dio/dio.dart';

import '../core/config/api_config.dart';
import '../data/models/api_response_model.dart';
import '../data/models/user_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class PatientProfileService {
  PatientProfileService();

  final Dio _dio = ApiClient().userDio;
  final StorageService _storage = StorageService();

  Future<ApiResponse<UserModel>> getPatientProfile(String patientId) async {
    try {
      final pharmacienUserId = _storage.getUserId();
      final response = await _dio.get(
        ApiConfig.patientProfileByPharmacien(patientId),
        queryParameters: pharmacienUserId == null
            ? null
            : {'pharmacienUserId': pharmacienUserId},
      );

      return ApiResponse.success(
        data: UserModel.fromJson(_extractPayload(response.data)),
        message: 'Profil patient recupere',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur recuperation profil patient',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: $e', error: e);
    }
  }

  Future<ApiResponse<UserModel>> getMyProfile() async {
    try {
      final userId = _storage.getUserId();
      final role = (_storage.getUserRole() ?? 'PATIENT').toUpperCase();

      if (userId == null || userId.isEmpty) {
        return ApiResponse.error(message: 'Utilisateur non connecte');
      }

      final endpoint = role == 'PHARMACIEN'
          ? ApiConfig.pharmacienProfile(userId)
          : ApiConfig.patientGetProfile(userId);

      final response = await _dio.get(endpoint);
      final profile = UserModel.fromJson({
        ..._extractPayload(response.data),
        'role': role,
      });

      return ApiResponse.success(
        data: profile,
        message: 'Profil recupere',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur recuperation profil',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: $e', error: e);
    }
  }

  Future<ApiResponse<UserModel>> updateProfile(UserModel userModel) async {
    try {
      final role = (_storage.getUserRole() ?? userModel.role).toUpperCase();
      final endpoint = role == 'PHARMACIEN'
          ? ApiConfig.pharmacienUpdateProfile(userModel.id)
          : ApiConfig.patientUpdateProfile(userModel.id);

      final response = await _dio.put(
        endpoint,
        data: _buildUpdatePayload(userModel),
      );

      final updated = UserModel.fromJson({
        ..._extractPayload(response.data),
        'role': role,
      });

      return ApiResponse.success(
        data: updated,
        message: 'Profil mis a jour',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur mise a jour profil',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: $e', error: e);
    }
  }

  Future<ApiResponse<String>> getMyQrCode() async {
    try {
      final userId = _storage.getUserId();
      final role = (_storage.getUserRole() ?? 'PATIENT').toUpperCase();
      if (userId == null || userId.isEmpty) {
        return ApiResponse.error(message: 'Utilisateur non connecte');
      }

      if (role == 'PHARMACIEN') {
        final response = await _dio.get(ApiConfig.pharmacienProfile(userId));
        final qrValue = _extractQrCode(_extractPayload(response.data));

        if (qrValue == null || qrValue.isEmpty) {
          return ApiResponse.error(message: 'QR Code introuvable');
        }

        return ApiResponse.success(
          data: qrValue,
          message: 'QR Code recupere',
          statusCode: response.statusCode,
        );
      }

      final response = await _dio.get(ApiConfig.patientQrCode(userId));
      final qrValue = _extractQrCode(response.data);

      if (qrValue == null || qrValue.isEmpty) {
        return ApiResponse.error(message: 'QR Code introuvable');
      }

      return ApiResponse.success(
        data: qrValue,
        message: 'QR Code recupere',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.message ?? 'Erreur recuperation QR Code',
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
      return ApiResponse.error(message: 'Erreur: $e', error: e);
    }
  }

  Map<String, dynamic> _buildUpdatePayload(UserModel userModel) {
    final payload = <String, dynamic>{
      'nom': userModel.nom,
      'prenom': userModel.prenom,
      'telephone': userModel.telephone,
      'dateNaissance': userModel.dateNaissance?.toIso8601String().split('T').first,
      'groupeSanguin': userModel.groupeSanguin,
      'allergies': userModel.allergies,
      'maladiesChroniques': userModel.maladiesChroniques,
      'enceinte': userModel.enceinte,
      'photoBase64': userModel.photoBase64,
    };

    if (userModel.isPharmacien) {
      payload['numeroOrdre'] = userModel.numeroOrdre;
      payload['specialite'] = userModel.specialite;
    }

    payload.removeWhere((key, value) => value == null);
    return payload;
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
}
