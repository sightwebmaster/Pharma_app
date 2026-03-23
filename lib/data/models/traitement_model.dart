import 'package:json_annotation/json_annotation.dart';

part 'traitement_model.g.dart';

@JsonSerializable()
class TraitementModel {
  final String id;
  final String medicament;
  final String dosage;
  final String frequence;
  final String? dateDebut;
  final String? dateFin;
  final String statut; // 'en cours', 'terminé', 'suspendu'
  final String? notes;

  TraitementModel({
    required this.id,
    required this.medicament,
    required this.dosage,
    required this.frequence,
    this.dateDebut,
    this.dateFin,
    required this.statut,
    this.notes,
  });

  factory TraitementModel.fromJson(Map<String, dynamic> json) =>
      _$TraitementModelFromJson(json);

  Map<String, dynamic> toJson() => _$TraitementModelToJson(this);

  TraitementModel copyWith({
    String? id,
    String? medicament,
    String? dosage,
    String? frequence,
    String? dateDebut,
    String? dateFin,
    String? statut,
    String? notes,
  }) {
    return TraitementModel(
      id: id ?? this.id,
      medicament: medicament ?? this.medicament,
      dosage: dosage ?? this.dosage,
      frequence: frequence ?? this.frequence,
      dateDebut: dateDebut ?? this.dateDebut,
      dateFin: dateFin ?? this.dateFin,
      statut: statut ?? this.statut,
      notes: notes ?? this.notes,
    );
  }
}
