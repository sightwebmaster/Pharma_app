import 'package:dio/dio.dart';
<<<<<<< HEAD
=======

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
import '../core/config/api_config.dart';
import '../data/models/api_response_model.dart';
import '../data/models/user_model.dart';
import 'api_client.dart';
import 'storage_service.dart';

class PatientProfileService {
<<<<<<< HEAD
  final Dio _dio = ApiClient().dio; // ✅ Gateway — JWT requis
  final StorageService _storage = StorageService();

  // ═══════════════════════════════════════════════════════════════
  // GET PROFIL PATIENT
  // ✅ Endpoint réel : GET /api/v1/pharmaciens/patients/{patientId}/profile
  // ❌ ÉTAIT : /api/v1/patient/profile → n'existe pas
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<UserModel>> getPatientProfile(String patientId) async {
    try {
      // ✅ Endpoint correct du backend
      final response = await _dio.get(
        ApiConfig.patientProfileByPharmacien(patientId),
        queryParameters: {
          // Le pharmacienUserId vient du token via Gateway (X-User-Id)
          // Mais si nécessaire côté Flutter, on peut l'envoyer en query param
          'pharmacienUserId': _storage.getUserId(),
        },
      );

      final userData = response.data['data'] ?? response.data;
      final userModel = UserModel.fromJson(userData as Map<String, dynamic>);

      return ApiResponse.success(
        data: userModel,
        message: 'Profil patient récupéré',
=======
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
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
<<<<<<< HEAD
        message: e.message ?? 'Erreur récupération profil patient',
=======
        message: e.message ?? 'Erreur recuperation profil patient',
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
<<<<<<< HEAD
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // GET PROFIL DU PATIENT CONNECTÉ (son propre profil)
  // ✅ Utilise le userId stocké localement
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<UserModel>> getMyProfile() async {
    try {
      final userId = _storage.getUserId();
      final role = _storage.getUserRole();

      if (userId == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      // ✅ Route selon le rôle
      final endpoint = role == 'PHARMACIEN'
          ? ApiConfig.pharmacienProfile(userId)
          : ApiConfig.patientProfileByPharmacien(userId);

      final response = await _dio.get(endpoint);

      final userData = response.data['data'] ?? response.data;
      final userModel = UserModel.fromJson(userData as Map<String, dynamic>);

      return ApiResponse.success(
        data: userModel,
        message: 'Profil récupéré',
=======
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
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
<<<<<<< HEAD
        message: e.message ?? 'Erreur récupération profil',
=======
        message: e.message ?? 'Erreur recuperation profil',
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
<<<<<<< HEAD
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // UPDATE PROFIL
  // ❌ Endpoint /api/v1/users/profile n'existe pas dans le backend
  // ✅ À implémenter dans le backend si nécessaire
  // Pour l'instant → retourne succès local
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<UserModel>> updatePatientProfile(
    UserModel userModel,
  ) async {
    // TODO: implémenter PUT /api/v1/patients/{userId}/profile dans user-service
    return ApiResponse.error(
      message: 'Mise à jour profil non disponible pour le moment',
      statusCode: 501,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // QR CODE — récupère le QR Code du patient connecté
  // Le QR Code est stocké dans patientProfile.qrCode (base64)
  // ═══════════════════════════════════════════════════════════════

  Future<ApiResponse<String>> getMyQrCode() async {
    try {
      final userId = _storage.getUserId();
      if (userId == null) {
        return ApiResponse.error(message: 'Utilisateur non connecté');
      }

      final response = await _dio.get(
        ApiConfig.patientProfileByPharmacien(userId),
      );

      final userData = response.data['data'] ?? response.data;
      final qrCode = userData['qrCode'] as String?;

      if (qrCode == null || qrCode.isEmpty) {
        return ApiResponse.error(message: 'QR Code non disponible');
      }

      return ApiResponse.success(
        data: qrCode,
        message: 'QR Code récupéré',
=======
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
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return ApiResponse.error(
<<<<<<< HEAD
        message: e.message ?? 'Erreur récupération QR Code',
=======
        message: e.message ?? 'Erreur recuperation QR Code',
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        statusCode: e.response?.statusCode,
        error: e,
      );
    } catch (e) {
<<<<<<< HEAD
      return ApiResponse.error(message: 'Erreur: ${e.toString()}', error: e);
    }
  }
}
=======
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
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
