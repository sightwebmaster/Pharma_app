<<<<<<< HEAD
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
=======
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
import '../../core/config/api_config.dart';
import '../../services/api_client.dart';
import '../../services/storage_service.dart';

class PharmacienViewModel extends ChangeNotifier {
<<<<<<< HEAD
  final Dio _dio = ApiClient().dio;
=======
  final Dio _dio = ApiClient().userDio;
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _patients.isEmpty && !_isLoading;
<<<<<<< HEAD

  // ✅ Fix — observance n'est pas retourné par /mes-patients
  // À connecter à adherence-service (GET /api/adherence/{patientId}/summary)
  int get pendingCount => 0;

  // ═══════════════════════════════════════════════════════════════
  // LOAD PATIENTS
  // ✅ GET /api/v1/pharmaciens/{pharmacienId}/mes-patients
  // ═══════════════════════════════════════════════════════════════
=======
  int get pendingCount =>
      _patients.where((patient) => (patient['observance'] as double? ?? 0) < 0.5).length;
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

  Future<void> loadPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pharmacienId = _storage.getUserId();
<<<<<<< HEAD
      if (pharmacienId == null) throw Exception('Pharmacien non connecté');

      final response = await _dio.get(
        ApiConfig.pharmacienMesPatients(pharmacienId),
      );

      final List<dynamic> data = response.data as List<dynamic>;

      _patients = data.map((e) {
        final json = e as Map<String, dynamic>;

        // ✅ userId = UUID Keycloak (pour créer un traitement)
        // ❌ ÉTAIT : 'id' en priorité → c'est l'UUID DB, pas Keycloak
        final String patientUserId =
            json['userId'] as String? ?? json['id'] as String? ?? '';

        // ✅ allergies est une List<String> dans le backend, pas un String
        final allergiesList = json['allergies'];
        final String allergiesStr = allergiesList is List
            ? (allergiesList as List).join(', ')
            : allergiesList as String? ?? 'Aucune';

        // ✅ maladiesChroniques → maladie
        final maladiesList = json['maladiesChroniques'];
        final String maladiesStr = maladiesList is List
            ? (maladiesList as List).join(', ')
            : maladiesList as String? ?? '';

        return {
          // ✅ userId Keycloak — utilisé pour créer un traitement
          'id':        patientUserId,
          // ✅ id DB — conservé si besoin
          'dbId':      json['id'] as String? ?? '',
          'name':      '${json['prenom'] ?? ''} ${json['nom'] ?? ''}'.trim(),
          'prenom':    json['prenom'] as String? ?? '',
          'nom':       json['nom'] as String? ?? '',
          'age':       json['age'] as int? ?? 0,
          'maladie':   maladiesStr,
          'sex':       json['sexe'] as String? ?? json['genre'] as String? ?? 'Male',
          'allergies': allergiesStr,
          'pregnant':  json['enceinte'] as bool? ?? false,
          // ✅ observance à 0.0 par défaut — adherence-service à connecter
          'observance': 0.0,
          'qrCode':    json['qrCode'] as String? ?? '',
          'telephone': json['telephone'] as String? ?? '',
          'groupeSanguin': json['groupeSanguin'] as String? ?? '',
          // meds vide — à charger depuis treatment-service si besoin
          'meds':      <Map<String, dynamic>>[],
=======
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
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
        };
      }).toList();

      _error = null;
    } on DioException catch (e) {
      final data = e.response?.data;
<<<<<<< HEAD
      _error = (data is Map ? data['message']?.toString() : null)
          ?? 'Erreur chargement patients';
=======
      _error = (data is Map ? data['message']?.toString() : null) ??
          'Erreur chargement patients';
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

<<<<<<< HEAD
  // ═══════════════════════════════════════════════════════════════
  // SCAN QR CODE
  // ✅ POST /api/v1/pharmaciens/{pharmacienId}/scan-qr
  // ═══════════════════════════════════════════════════════════════

  Future<bool> scanQrCode(String patientUserId) async {
    try {
      final pharmacienId = _storage.getUserId();
      if (pharmacienId == null) throw Exception('Pharmacien non connecté');

      await _dio.post(
        ApiConfig.pharmacienScanQr(pharmacienId),
        data: {"patientUserId": patientUserId},
=======
  Future<bool> scanQrCode(String patientUserId) async {
    try {
      final pharmacienId = _storage.getUserId();
      if (pharmacienId == null) {
        throw Exception('Pharmacien non connecte');
      }

      await _dio.post(
        ApiConfig.pharmacienScanQr(pharmacienId),
        data: {'patientUserId': patientUserId},
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      );

      await loadPatients();
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
<<<<<<< HEAD
      _error = (data is Map ? data['message']?.toString() : null)
          ?? 'Erreur scan QR';
      notifyListeners();
      return false;
    } catch (e) {
      // ✅ Fix : était '\${e.toString()}' (mauvaise interpolation)
=======
      _error =
          (data is Map ? data['message']?.toString() : null) ?? 'Erreur scan QR';
      notifyListeners();
      return false;
    } catch (e) {
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      _error = 'Erreur scan QR : ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

<<<<<<< HEAD
  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
=======
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
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() => loadPatients();

<<<<<<< HEAD
  /// Retourne le patientUserId (UUID Keycloak) depuis un patient Map
  /// Utiliser pour créer un traitement
  String? getPatientUserId(Map<String, dynamic> patient) {
    return patient['id'] as String?;
  }
}
=======
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
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
