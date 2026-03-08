import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../core/config/api_config.dart';
import '../../services/api_client.dart';

class PharmacienViewModel extends ChangeNotifier {
  final Dio _dio = ApiClient().dio;

  // Stored as Map for direct compatibility with existing UI widget builders
  List<Map<String, dynamic>> _patients = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get patients => _patients;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get pendingCount =>
      _patients.where((p) => (p['observance'] as double) < 0.5).length;

  Future<void> loadPatients() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get(ApiConfig.pharmacienPatientsEndpoint);
      final List<dynamic> data = response.data as List<dynamic>;
      _patients = data.map((e) {
        final json = e as Map<String, dynamic>;
        return {
          'id': json['id'] as String? ?? '',
          'name': '${json['prenom'] ?? ''} ${json['nom'] ?? ''}'.trim(),
          'age': json['age'] as int? ?? 0,
          'maladie': json['maladie'] as String? ?? '',
          'observance': (json['observance'] as num?)?.toDouble() ?? 0.0,
          'qrCode': json['qrCode'] as String? ?? 'N/A',
          'meds': (json['medicaments'] as List<dynamic>? ?? [])
              .map(
                (m) => {
                  'name': (m as Map<String, dynamic>)['nom'] as String? ?? '',
                  'dose': m['dosage'] as String? ?? '',
                },
              )
              .toList(),
        };
      }).toList();
      _error = null;
    } on DioException catch (e) {
      final data = e.response?.data;
      _error =
          (data is Map ? data['message']?.toString() : null) ??
          'Erreur chargement patients';
    } catch (e) {
      _error = 'Erreur: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }
}
