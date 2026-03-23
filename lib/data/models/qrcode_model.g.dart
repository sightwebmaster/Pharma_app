// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qrcode_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QRCodeModel _$QRCodeModelFromJson(Map<String, dynamic> json) => QRCodeModel(
  id: json['id'] as String,
  nom: json['nom'] as String,
  prenom: json['prenom'] as String,
  email: json['email'] as String,
  telephone: json['telephone'] as String?,
  adresse: json['adresse'] as String?,
  groupeSanguin: json['groupeSanguin'] as String?,
  allergies:
      (json['allergies'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  maladiesChroniques:
      (json['maladiesChroniques'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  dateNaissance: json['dateNaissance'] == null
      ? null
      : DateTime.parse(json['dateNaissance'] as String),
);

Map<String, dynamic> _$QRCodeModelToJson(QRCodeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'email': instance.email,
      'telephone': instance.telephone,
      'adresse': instance.adresse,
      'groupeSanguin': instance.groupeSanguin,
      'allergies': instance.allergies,
      'maladiesChroniques': instance.maladiesChroniques,
      'dateNaissance': instance.dateNaissance?.toIso8601String(),
    };
