
// ─────────────────────────────────────────────────────────────
// FICHIER 2 : proche_viewmodel.dart
// ─────────────────────────────────────────────────────────────
 
import 'package:flutter/foundation.dart';
import '../../data/models/proche_model.dart';
import '../../services/proche_service.dart';
 
class ProcheViewModel extends ChangeNotifier {
  final ProcheService _service = ProcheService();
 
  List<ProcheModel> _proches = [];  // ✅ ProcheModel au lieu de Map
  bool _isLoading = false;
  String? _error;
 
  List<ProcheModel> get proches => _proches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasError => _error != null;
  bool get isEmpty => _proches.isEmpty && !_isLoading;
 
  // ═══════════════════════════════════════════════════════════════
  // LOAD
  // ═══════════════════════════════════════════════════════════════
 
  Future<void> loadProches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
 
    final response = await _service.getMyProches();
 
    if (response.success && response.data != null) {
      _proches = response.data!;
      _error = null;
    } else {
      _error = response.message ?? 'Erreur chargement proches';
    }
 
    _isLoading = false;
    notifyListeners();
  }
 
  // ═══════════════════════════════════════════════════════════════
  // ADD PAR EMAIL
  // ✅ Utilise addProcheByEmail (endpoint correct)
  // ❌ ÉTAIT : addProche(patientId, relation) → mauvais endpoint
  // ═══════════════════════════════════════════════════════════════
 
  Future<bool> addProcheByEmail({
    required String email,
    required String relation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
 
    final response = await _service.addProcheByEmail(
      email: email,
      relation: relation,
    );
 
    _isLoading = false;
 
    if (response.success && response.data != null) {
      _proches.add(response.data!);
      _error = null;
      notifyListeners();
      return true;
    } else {
      _error = response.message ?? 'Erreur ajout proche';
      notifyListeners();
      return false;
    }
  }
 
  // ═══════════════════════════════════════════════════════════════
  // ADD PAR QR CODE
  // ✅ Nouveau — utilise addProcheByQrCode
  // ═══════════════════════════════════════════════════════════════
 
  Future<bool> addProcheByQrCode({
    required String qrCodeContent,
    required String relation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
 
    final response = await _service.addProcheByQrCode(
      qrCodeContent: qrCodeContent,
      relation: relation,
    );
 
    _isLoading = false;
 
    if (response.success && response.data != null) {
      _proches.add(response.data!);
      _error = null;
      notifyListeners();
      return true;
    } else {
      _error = response.message ?? 'Erreur ajout proche par QR';
      notifyListeners();
      return false;
    }
  }
 
  // ═══════════════════════════════════════════════════════════════
  // DELETE
  // ═══════════════════════════════════════════════════════════════
 
  Future<bool> deleteProche(String procheId) async {
    final response = await _service.deleteProche(procheId);
 
    if (response.success) {
      // ✅ Supprime par id depuis la liste de ProcheModel
      _proches.removeWhere((p) => p.id == procheId);
      _error = null;
      notifyListeners();
      return true;
    } else {
      _error = response.message ?? 'Erreur suppression proche';
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
 
  Future<void> refresh() => loadProches();
}