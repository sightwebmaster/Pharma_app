import 'package:flutter/foundation.dart';
import 'package:pharma_app/data/models/prise_planifiee.dart';
import 'package:pharma_app/data/models/adherence_summary.dart';
import 'package:pharma_app/data/models/traitement.dart';
import 'package:pharma_app/services/treatment_service.dart';
import 'package:pharma_app/services/storage_service.dart';

class TreatmentProvider extends ChangeNotifier {
  final TreatmentService _treatmentService = TreatmentService();
  final StorageService _storageService = StorageService();

  List<PrisePlanifiee> _todayPrises = [];
  AdherenceSummary? _adherenceSummary;
  Traitement? _lastCreatedTraitement;
  bool _isLoading = false;
  String? _error;

  List<PrisePlanifiee> get todayPrises => _todayPrises;
  AdherenceSummary? get adherenceSummary => _adherenceSummary;
  Traitement? get lastCreatedTraitement => _lastCreatedTraitement;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTodayPrises(String patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _storageService.getAccessToken() ?? '';
      final response = await _treatmentService.getTodayPrises(patientId, token);

      if (response.success && response.data != null) {
        _todayPrises = response.data!;
        _error = null;
      } else {
        _error = response.message ?? 'Erreur chargement prises';
        _todayPrises = [];
      }
    } catch (e) {
      _error = 'Erreur: $e';
      _todayPrises = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> confirmerPrise(String priseId) async {
    try {
      final token = await _storageService.getAccessToken() ?? '';
      final response = await _treatmentService.confirmerPrise(priseId, token);

      if (response.success) {
        final idx = _todayPrises.indexWhere((p) => p.id == priseId);
        if (idx != -1) {
          _todayPrises[idx] = _todayPrises[idx].copyWith(statut: 'CONFIRMEE');
          notifyListeners();
        }
        return true;
      } else {
        _error = response.message ?? 'Erreur confirmation';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Erreur: $e';
      notifyListeners();
      return false;
    }
  }

  Future<Traitement?> creerTraitement(
    Map<String, dynamic> body,
    String token,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _treatmentService.creerTraitement(body, token);

      if (response.success && response.data != null) {
        _lastCreatedTraitement = response.data;
        _error = null;

        final patientUserId = body['patientUserId'] as String?;
        if (patientUserId != null) {
          await loadTodayPrises(patientUserId);
        }

        _isLoading = false;
        notifyListeners();
        return response.data;
      } else {
        _error = response.message ?? 'Erreur création traitement';
        _isLoading = false;
        notifyListeners();
        return null;
      }
    } catch (e) {
      _error = 'Erreur: $e';
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> loadAdherenceSummary(String patientId) async {
    try {
      final token = await _storageService.getAccessToken() ?? '';
      final response = await _treatmentService.getAdherenceSummary(
        patientId,
        token,
      );

      if (response.success && response.data != null) {
        _adherenceSummary = response.data;
        _error = null;
      } else {
        _error = response.message;
      }
    } catch (e) {
      _error = 'Erreur: $e';
    }
    notifyListeners();
  }

  void clearData() {
    _todayPrises = [];
    _adherenceSummary = null;
    _lastCreatedTraitement = null;
    _error = null;
    notifyListeners();
  }
}
