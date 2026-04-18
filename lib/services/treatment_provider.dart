import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pharma_app/data/models/adherence_summary.dart';
import 'package:pharma_app/data/models/prise_planifiee.dart';
import 'package:pharma_app/data/models/traitement.dart';
import 'package:pharma_app/services/storage_service.dart';
import 'package:pharma_app/services/treatment_service.dart';

class TreatmentProvider extends ChangeNotifier {
  final TreatmentService _treatmentService = TreatmentService();
  final StorageService _storageService = StorageService();

  List<PrisePlanifiee> _todayPrises = [];
  List<PrisePlanifiee> _allPrises = [];
  AdherenceSummary? _adherenceSummary;
  Traitement? _lastCreatedTraitement;
  bool _isLoading = false;
  String? _error;

  List<PrisePlanifiee> get todayPrises => _todayPrises;
  List<PrisePlanifiee> get allPrises => _allPrises;
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

  Future<void> loadAllPrises(String patientId) async {
    try {
      final token = await _storageService.getAccessToken() ?? '';
      final response = await _treatmentService.getAllPrises(patientId, token);

      if (response.success && response.data != null) {
        _allPrises = response.data!;
        _error = null;
      } else {
        _error = response.message ?? 'Erreur chargement historique des prises';
        _allPrises = [];
      }
    } catch (e) {
      _error = 'Erreur: $e';
      _allPrises = [];
    }

    notifyListeners();
  }

  Future<bool> confirmerPrise(PrisePlanifiee prise) async {
    try {
      final token = await _storageService.getAccessToken() ?? '';
      final response = await _treatmentService.confirmerPrise(prise, token);

      if (response.success && response.data != null) {
        final confirmed = response.data!;
        final idx = _todayPrises.indexWhere((p) => p.id == prise.id);
        if (idx != -1) {
          _todayPrises[idx] = confirmed;
        }
        final allIdx = _allPrises.indexWhere((p) => p.id == prise.id);
        if (allIdx != -1) {
          _allPrises[allIdx] = confirmed;
        }
        if (prise.patientUserId.isNotEmpty) {
          unawaited(loadTodayPrises(prise.patientUserId));
          unawaited(loadAllPrises(prise.patientUserId));
          unawaited(loadAdherenceSummary(prise.patientUserId));
        }
        notifyListeners();
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
          unawaited(loadTodayPrises(patientUserId));
          unawaited(loadAllPrises(patientUserId));
          unawaited(loadAdherenceSummary(patientUserId));
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
      } else {
        _adherenceSummary ??= AdherenceSummary.empty(patientId);
      }
    } catch (e) {
      _adherenceSummary ??= AdherenceSummary.empty(patientId);
    }
    notifyListeners();
  }

  void clearData() {
    _todayPrises = [];
    _allPrises = [];
    _adherenceSummary = null;
    _lastCreatedTraitement = null;
    _error = null;
    notifyListeners();
  }
}
