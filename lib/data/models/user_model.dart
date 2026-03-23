import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String nom;
  final String prenom;
  final String? email;
  final DateTime?
  dateNaissance; // NULLABLE car votre backend peut renvoyer null
  final String? telephone;
  final String? adresse;
  final String role;
  final String? groupeSanguin;
  final List<String> allergies;
  final List<String> maladiesChroniques;

  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.email,
    this.dateNaissance,
    this.telephone,
    this.adresse,
    required this.role,
    this.groupeSanguin,
    this.allergies = const [],
    this.maladiesChroniques = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  String get fullName => '$prenom $nom';

  bool get isPatient => role.toUpperCase() == 'PATIENT';

  bool get isPharmacien => role.toUpperCase() == 'PHARMACIEN';

  UserModel copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    DateTime? dateNaissance,
    String? telephone,
    String? adresse,
    String? role,
    String? groupeSanguin,
    List<String>? allergies,
    List<String>? maladiesChroniques,
  }) {
    return UserModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      role: role ?? this.role,
      groupeSanguin: groupeSanguin ?? this.groupeSanguin,
      allergies: allergies ?? this.allergies,
      maladiesChroniques: maladiesChroniques ?? this.maladiesChroniques,
    );
  }
}
