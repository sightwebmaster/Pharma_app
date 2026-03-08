import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String nom;
  final String prenom;
  final String? email;  // NULLABLE car votre backend peut renvoyer null
  final String? telephone;
  final String? adresse;
  final String role;
  final String? pharmacyName;
  final String? licenseNumber;
  
  UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    this.email,
    this.telephone,
    this.adresse,
    required this.role,
    this.pharmacyName,
    this.licenseNumber,
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
    String? telephone,
    String? adresse,
    String? role,
    String? pharmacyName,
    String? licenseNumber,
  }) {
    return UserModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      role: role ?? this.role,
      pharmacyName: pharmacyName ?? this.pharmacyName,
      licenseNumber: licenseNumber ?? this.licenseNumber,
    );
  }
}