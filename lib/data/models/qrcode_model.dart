import 'package:json_annotation/json_annotation.dart';

part 'qrcode_model.g.dart';

@JsonSerializable()
class QRCodeModel {
  final String id;
  final String nom;
  final String prenom;
  final String email;
  final String? telephone;
  final String? adresse;
  final String? groupeSanguin;
  final List<String> allergies;
  final List<String> maladiesChroniques;
  final DateTime? dateNaissance;

  QRCodeModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    this.telephone,
    this.adresse,
    this.groupeSanguin,
    this.allergies = const [],
    this.maladiesChroniques = const [],
    this.dateNaissance,
  });

  factory QRCodeModel.fromJson(Map<String, dynamic> json) =>
      _$QRCodeModelFromJson(json);

  Map<String, dynamic> toJson() => _$QRCodeModelToJson(this);

  String get fullName => '$prenom $nom';

  /// Encode le model en JSON pour le générer en QR code
  String toQRString() => toJson().toString();

  /// Decode une chaîne JSON pour récupérer le model
  factory QRCodeModel.fromQRString(String qrString) {
    final json = qrString as Map<String, dynamic>;
    return QRCodeModel.fromJson(json);
  }
}
