import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../core/config/api_config.dart';
import '../../services/api_client.dart';
import '../../services/storage_service.dart';

class PharmacienViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient().userDio;
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _patients.isEmpty && !_isLoading;
  int get pendingCount =>
      _patients.where((patient) => (patient['observance'] as double? ?? 0) < 0.5).length;

  Future<void> loadPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pharmacienId = _storage.getUserId();
      if (pharmacienId == null) {
        throw Exception('Pharmacien non connecte');
      }

      final response = await _dio.get(ApiConfig.pharmacienMesPatients(pharmacienId));
      final List<dynamic> data = response.data as List<dynamic>;

      _patients = data.map((item) {
        final json = item as Map<String, dynamic>;
        final patientUserId = (json['userId'] ?? json['id'] ?? '').toString();
        final allergiesList = _stringList(json['allergies']);
        final maladiesList = _stringList(json['maladiesChroniques']);
        final dateNaissance = _nullableString(json['dateNaissance']);
        final derivedAge = _deriveAge(json['age'] as int?, dateNaissance);

        return <String, dynamic>{
          'id': patientUserId,
          'dbId': (json['id'] ?? '').toString(),
          'name': '${json['prenom'] ?? ''} ${json['nom'] ?? ''}'.trim(),
          'prenom': (json['prenom'] ?? '').toString(),
          'nom': (json['nom'] ?? '').toString(),
          'age': derivedAge,
          'dateNaissance': dateNaissance,
          'maladie': maladiesList.join(', '),
          'maladiesChroniques': maladiesList,
          'sex': (json['sexe'] ?? json['genre'] ?? 'Male').toString(),
          'allergies': allergiesList.join(', '),
          'allergiesList': allergiesList,
          'pregnant': json['enceinte'] as bool? ?? false,
          'observance': (json['observance'] as num?)?.toDouble() ?? 0.0,
          'qrCode': (json['qrCode'] ?? '').toString(),
          'telephone': (json['telephone'] ?? '').toString(),
          'groupeSanguin': (json['groupeSanguin'] ?? '').toString(),
          'photoBase64': _nullableString(json['photoBase64']) ?? '',
          'email': _nullableString(json['email']) ?? '',
          'meds': <Map<String, dynamic>>[],
        };
      }).toList();

      _error = null;
    } on DioException catch (e) {
      final data = e.response?.data;
      _error = (data is Map ? data['message']?.toString() : null) ??
          'Erreur chargement patients';
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> scanQrCode(String patientUserId) async {
    try {
      final pharmacienId = _storage.getUserId();
      if (pharmacienId == null) {
        throw Exception('Pharmacien non connecte');
      }

      await _dio.post(
        ApiConfig.pharmacienScanQr(pharmacienId),
        data: {'patientUserId': patientUserId},
      );

      await loadPatients();
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      _error =
          (data is Map ? data['message']?.toString() : null) ?? 'Erreur scan QR';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erreur scan QR : ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  Future<bool> linkPatientByEmail(String email) async {
    try {
      final pharmacienId = _storage.getUserId();
      if (pharmacienId == null) {
        throw Exception('Pharmacien non connecte');
      }

      await _dio.get(
        ApiConfig.patientProfileByEmailByPharmacien,
        queryParameters: {
          'pharmacienUserId': pharmacienId,
          'email': email,
        },
      );

      await loadPatients();
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      _error = (data is Map ? data['message']?.toString() : null) ??
          'Erreur recherche patient';
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Erreur recherche patient : ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() => loadPatients();

  String? getPatientUserId(Map<String, dynamic> patient) {
    return patient['id'] as String?;
  }

  List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  int _deriveAge(int? age, String? dateNaissance) {
    if (age != null && age > 0) {
      return age;
    }
    if (dateNaissance == null || dateNaissance.isEmpty) {
      return 0;
    }
    final parsed = DateTime.tryParse(dateNaissance);
    if (parsed == null) {
      return 0;
    }
    final now = DateTime.now();
    var years = now.year - parsed.year;
    if (DateTime(now.year, parsed.month, parsed.day).isAfter(now)) {
      years -= 1;
    }
    return years < 0 ? 0 : years;
  }
}
