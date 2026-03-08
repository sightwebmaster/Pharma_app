import 'package:flutter/foundation.dart';
import '../../services/proche_service.dart';

class ProcheViewModel extends ChangeNotifier {
  final ProcheService _service = ProcheService();

  // Stored as Map for direct compatibility with existing UI widget builders
  List<Map<String, dynamic>> _proches = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get proches => _proches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all proches (family members) from the API
  Future<void> loadProches() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _service.getMyProches();

    if (response.success && response.data != null) {
      _proches = response.data!.map((p) => p.toMap()).toList();
      _error = null;
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Add a new proche (link to an existing patient account)
  ///
  /// Returns true if successful, false otherwise
  Future<bool> addProche({
    required String patientId,
    required String relation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _service.addProche(
      patientId: patientId,
      relation: relation,
    );

    if (response.success && response.data != null) {
      // Add the newly created proche to the list
      _proches.add(response.data!.toMap());
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a proche (unlink the patient relationship)
  ///
  /// Returns true if successful, false otherwise
  Future<bool> deleteProche(String procheId) async {
    final response = await _service.deleteProche(procheId);

    if (response.success) {
      // Remove from local list
      _proches.removeWhere((p) => p['id'] == procheId);
      _error = null;
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      notifyListeners();
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh proches list (alias for loadProches for clarity)
  Future<void> refresh() async {
    await loadProches();
  }
}
