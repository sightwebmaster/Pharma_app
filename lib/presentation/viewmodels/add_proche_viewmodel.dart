import 'package:flutter/foundation.dart';
import '../../data/models/proche_model.dart';
import '../../services/add_proche_service.dart';

class AddProcheViewModel extends ChangeNotifier {
  final AddProcheService _service = AddProcheService();

  bool _isLoading = false;
  String? _error;
  ProcheModel? _addedProche;

  bool get isLoading => _isLoading;
  String? get error => _error;
  ProcheModel? get addedProche => _addedProche;

  /// Ajouter un proche par email (le proche est un patient existant)
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

    if (response.success && response.data != null) {
      _addedProche = response.data;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      _addedProche = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Ajouter un proche par QR code (scan du QR → procheUserId)
  Future<bool> addProcheByQRCode({
    required String procheUserId,
    required String relation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final response = await _service.addProcheByQRCode(
      procheUserId: procheUserId,
      relation: relation,
    );

    if (response.success && response.data != null) {
      _addedProche = response.data;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _error = response.message;
      _addedProche = null;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Efface l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Réinitialise l'état
  void reset() {
    _isLoading = false;
    _error = null;
    _addedProche = null;
    notifyListeners();
  }
}
