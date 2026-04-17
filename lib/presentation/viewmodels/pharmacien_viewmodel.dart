import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../services/api_client.dart';
import '../../services/storage_service.dart';

class PharmacienViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient().dio;
  final StorageService _storage = StorageService();

  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _patients.isEmpty && !_isLoading;

  // ✅ Fix — observance n'est pas retourné par /mes-patients
  // À connecter à adherence-service (GET /api/adherence/{patientId}/summary)
  int get pendingCount => 0;

  // ═══════════════════════════════════════════════════════════════
  // LOAD PATIENTS
  // ✅ GET /api/v1/pharmaciens/{pharmacienId}/mes-patients
  // ═══════════════════════════════════════════════════════════════

  Future<void> loadPatients() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final pharmacienId = _storage.getUserId();
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
        };
      }).toList();

      _error = null;
    } on DioException catch (e) {
      final data = e.response?.data;
      _error = (data is Map ? data['message']?.toString() : null)
          ?? 'Erreur chargement patients';
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

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
      );

      await loadPatients();
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      _error = (data is Map ? data['message']?.toString() : null)
          ?? 'Erreur scan QR';
      notifyListeners();
      return false;
    } catch (e) {
      // ✅ Fix : était '\${e.toString()}' (mauvaise interpolation)
      _error = 'Erreur scan QR : ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> refresh() => loadPatients();

  /// Retourne le patientUserId (UUID Keycloak) depuis un patient Map
  /// Utiliser pour créer un traitement
  String? getPatientUserId(Map<String, dynamic> patient) {
    return patient['id'] as String?;
  }
}