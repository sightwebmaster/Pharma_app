import 'package:flutter/foundation.dart';

import '../../data/models/recommendation_model.dart';
import '../../services/recommendation_service.dart';
import '../../services/storage_service.dart';

class RecommendationViewModel extends ChangeNotifier {
  RecommendationViewModel();

  final RecommendationService _service = RecommendationService();
  final StorageService _storage = StorageService();

  bool _isLoading = false;
  String? _errorMessage;
  RecommendationModel? _currentRecommendation;
  List<RecommendationModel> _history = const [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  RecommendationModel? get currentRecommendation => _currentRecommendation;
  List<RecommendationModel> get history => _history;

  Future<bool> analyze({
    required String symptoms,
    String? patientId,
    Map<String, dynamic>? patientProfile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final effectivePatientId = patientId ?? _storage.getUserId() ?? 'anonymous';
    final response = await _service.analyze(
      symptoms: symptoms,
      patientId: effectivePatientId,
      patientProfile: patientProfile,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _currentRecommendation = response.data;
      notifyListeners();
      loadHistory(effectivePatientId);
      return true;
    }

    _errorMessage = response.message ?? 'Erreur de recommandation';
    notifyListeners();
    return false;
  }

  Future<void> loadHistory([String? patientId]) async {
    final effectivePatientId = patientId ?? _storage.getUserId();
    if (effectivePatientId == null || effectivePatientId.isEmpty) {
      return;
    }
    final response = await _service.getPatientHistory(effectivePatientId);
    if (response.success && response.data != null) {
      _history = response.data!;
      notifyListeners();
    }
  }

  Future<bool> processRecommendation({
    required String action,
    String? note,
    List<Map<String, dynamic>>? modifiedMedications,
  }) async {
    final recommendation = _currentRecommendation;
    if (recommendation == null) {
      _errorMessage = 'Aucune recommandation active';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _service.validate(
      recommendationId: recommendation.id,
      action: action,
      note: note,
      modifiedMedications: modifiedMedications,
    );

    _isLoading = false;
    if (response.success && response.data != null) {
      _currentRecommendation = response.data;
      notifyListeners();
      loadHistory(response.data!.patientId);
      return true;
    }

    _errorMessage = response.message ?? 'Impossible de traiter la recommandation';
    notifyListeners();
    return false;
  }

  void clear() {
    _currentRecommendation = null;
    _errorMessage = null;
    notifyListeners();
  }
}
