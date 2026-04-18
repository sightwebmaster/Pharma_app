import 'package:json_annotation/json_annotation.dart';

part 'adherence_summary.g.dart';

/// AdherenceSummary - Résumé de l'observance du patient
@JsonSerializable()
class AdherenceSummary {
  final double tauxGlobal; // 0.0 - 1.0
  final double taux7Jours; // 0.0 - 1.0
  final int prisesConfirmees;
  final int prisesManquees;
  final int prisesPrevues;
  final bool alerteCritique;
  final String? messageAlerte;

  AdherenceSummary({
    required this.tauxGlobal,
    required this.taux7Jours,
    required this.prisesConfirmees,
    required this.prisesManquees,
    required this.prisesPrevues,
    required this.alerteCritique,
    this.messageAlerte,
  });

  factory AdherenceSummary.fromJson(Map<String, dynamic> json) =>
      _$AdherenceSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$AdherenceSummaryToJson(this);

  int get pourcentageGlobal => (tauxGlobal * 100).toInt();
  int get pourcentage7Jours => (taux7Jours * 100).toInt();
}
