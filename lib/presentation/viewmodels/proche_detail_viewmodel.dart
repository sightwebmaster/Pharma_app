import 'package:flutter/foundation.dart';
import '../../data/models/historique_model.dart';
import '../../data/models/traitement_model.dart';
import '../../services/proche_detail_service.dart';

class ProcheDetailViewModel extends ChangeNotifier {
  final ProcheDetailService _service = ProcheDetailService();

  List<HistoriqueModel> _historique = [];
  List<TraitementModel> _traitements = [];
  Map<String, dynamic>? _procheDetails;
  bool _isLoading = false;
  String? _error;

  List<HistoriqueModel> get historique => _historique;
  List<TraitementModel> get traitements => _traitements;
  Map<String, dynamic>? get procheDetails => _procheDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Charge les détails complets du proche
  Future<void> loadProcheDetails(String userId, String procheId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _service.getProcheDetails(userId, procheId);

    if (response.success && response.data != null) {
      _procheDetails = response.data;
      _error = null;
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Charge l'historique médical du proche
  Future<void> loadHistorique(String userId, String procheId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _service.getProcheHistorique(userId, procheId);

    if (response.success && response.data != null) {
      _historique = response.data!;
      _error = null;
    } else {
      _error = response.message;
      _historique = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Charge les traitements courants du proche
  Future<void> loadTraitements(String userId, String procheId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _service.getProcheTraitements(userId, procheId);

    if (response.success && response.data != null) {
      _traitements = response.data!;
      _error = null;
    } else {
      _error = response.message;
      _traitements = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Charge toutes les données du proche
  Future<void> loadAllProcheData(String userId, String procheId) async {
    await Future.wait([
      loadProcheDetails(userId, procheId),
      loadHistorique(userId, procheId),
      loadTraitements(userId, procheId),
    ]);
  }

  /// Efface l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Rafraîchit les données
  Future<void> refresh(String userId, String procheId) async {
    await loadAllProcheData(userId, procheId);
  }
}
