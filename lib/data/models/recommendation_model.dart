class RecommendationMedication {
  const RecommendationMedication({
    required this.name,
    this.dci,
    this.dosage,
    this.frequency,
    this.description,
    this.disease,
    this.finalScore,
    this.scoreLabel,
    this.priceTnd,
    this.contraindications = const [],
    this.sideEffects = const [],
  });

  final String name;
  final String? dci;
  final String? dosage;
  final String? frequency;
  final String? description;
  final String? disease;
  final double? finalScore;
  final String? scoreLabel;
  final double? priceTnd;
  final List<String> contraindications;
  final List<String> sideEffects;

  factory RecommendationMedication.fromJson(Map<String, dynamic> json) {
    return RecommendationMedication(
      name: (json['name'] ?? '').toString(),
      dci: _string(json['dci']),
      dosage: _string(json['dosage']),
      frequency: _string(json['frequency']),
      description: _string(json['description']),
      disease: _string(json['disease']),
      finalScore: _double(json['final_score']),
      scoreLabel: _string(json['score_label']),
      priceTnd: _double(json['price_tnd']),
      contraindications: _list(json['contraindications']),
      sideEffects: _list(json['side_effects']),
    );
  }
}

class RecommendationModel {
  const RecommendationModel({
    required this.id,
    required this.patientId,
    required this.symptoms,
    required this.primaryDisease,
    required this.status,
    required this.recommendedMedications,
    this.topScore,
    this.confidenceLabel,
    this.doctorAdvice,
    this.patientAdvice,
    this.pharmacistAlerts = const [],
    this.warnings = const [],
    this.createdAt,
  });

  final String id;
  final String patientId;
  final String symptoms;
  final String primaryDisease;
  final String status;
  final List<RecommendationMedication> recommendedMedications;
  final double? topScore;
  final String? confidenceLabel;
  final String? doctorAdvice;
  final String? patientAdvice;
  final List<String> pharmacistAlerts;
  final List<String> warnings;
  final DateTime? createdAt;

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      patientId: (json['patient_id'] ?? '').toString(),
      symptoms: (json['symptoms'] ?? '').toString(),
      primaryDisease: (json['primary_disease'] ?? 'indéterminée').toString(),
      status: (json['status'] ?? 'PENDING').toString(),
      recommendedMedications: (json['recommended_medications'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RecommendationMedication.fromJson)
          .toList(),
      topScore: _double(json['top_score']),
      confidenceLabel: _string(json['confidence_label']),
      doctorAdvice: _string(json['doctor_advice']),
      patientAdvice: _string(json['patient_advice']),
      pharmacistAlerts: _list(json['pharmacist_alerts']),
      warnings: _list(json['warnings'].runtimeType == Null
          ? json['mandatory_warnings']
          : json['warnings']),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
    );
  }
}

String? _string(dynamic value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

double? _double(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

List<String> _list(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).where((item) => item.trim().isNotEmpty).toList();
  }
  return const [];
}
