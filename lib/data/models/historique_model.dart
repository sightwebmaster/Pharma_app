import 'package:json_annotation/json_annotation.dart';

part 'historique_model.g.dart';

@JsonSerializable()
class HistoriqueModel {
  final String id;
  final String date;
  final String type; // 'consultation', 'hospitalisation', 'visite', etc.
  final String detail;
  final String? diagnostic;
  final String? traitement;

  HistoriqueModel({
    required this.id,
    required this.date,
    required this.type,
    required this.detail,
    this.diagnostic,
    this.traitement,
  });

  factory HistoriqueModel.fromJson(Map<String, dynamic> json) =>
      _$HistoriqueModelFromJson(json);

  Map<String, dynamic> toJson() => _$HistoriqueModelToJson(this);

  HistoriqueModel copyWith({
    String? id,
    String? date,
    String? type,
    String? detail,
    String? diagnostic,
    String? traitement,
  }) {
    return HistoriqueModel(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      detail: detail ?? this.detail,
      diagnostic: diagnostic ?? this.diagnostic,
      traitement: traitement ?? this.traitement,
    );
  }
}
