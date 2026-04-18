import 'package:flutter/foundation.dart';
import '../../services/medication_service.dart';

class MedicationViewModel extends ChangeNotifier {
  final MedicationService _service = MedicationService();

  // Stored as Map for direct compatibility with existing UI widget builders
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get medications => _medications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Map<String, dynamic>> get todayMedications {
    final now = DateTime.now();
    return _medications.where((m) {
      final date = m['date'] as DateTime;
      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).toList();
  }

  Future<void> loadMedications() async {
    _isLoading = true;
    notifyListeners();

    final response = await _service.getPrisesAujourdhui();

    if (response.success && response.data != null) {
      _medications = response.data!.map((m) => m.toMap()).toList();
      _error = null;
    } else {
      _error = response.message;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> confirmTaken(String medicationId) async {
    final response = await _service.confirmerPrise(medicationId);
    if (response.success) {
      final idx = _medications.indexWhere((m) => m['id'] == medicationId);
      if (idx != -1) {
        _medications[idx] = {..._medications[idx], 'taken': true};
        notifyListeners();
      }
    }
  }
}
