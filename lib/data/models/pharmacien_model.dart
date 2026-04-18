import 'package:json_annotation/json_annotation.dart';

part 'pharmacien_model.g.dart';

@JsonSerializable()
class PharmacienModel {
  final String id;
  final String userId;
  final String nom;
  final String prenom;
  final String email;
  final String telephone;
  final String numeroOrdre;
  final String? specialite;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PharmacienModel({
    required this.id,
    required this.userId,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
    required this.numeroOrdre,
    this.specialite,
    this.createdAt,
    this.updatedAt,
  });

  factory PharmacienModel.fromJson(Map<String, dynamic> json) =>
      _$PharmacienModelFromJson(json);

  Map<String, dynamic> toJson() => _$PharmacienModelToJson(this);

  String get fullName => '$prenom $nom';

  PharmacienModel copyWith({
    String? id,
    String? userId,
    String? nom,
    String? prenom,
    String? email,
    String? telephone,
    String? numeroOrdre,
    String? specialite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PharmacienModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      numeroOrdre: numeroOrdre ?? this.numeroOrdre,
      specialite: specialite ?? this.specialite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
