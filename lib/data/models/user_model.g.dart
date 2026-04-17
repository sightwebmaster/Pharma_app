// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  nom: json['nom'] as String,
  prenom: json['prenom'] as String,
  email: json['email'] as String?,
  dateNaissance: json['dateNaissance'] == null
      ? null
      : DateTime.parse(json['dateNaissance'] as String),
  telephone: json['telephone'] as String?,
  adresse: json['adresse'] as String?,
  role: json['role'] as String,
  groupeSanguin: json['groupeSanguin'] as String?,
  allergies:
      (json['allergies'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  maladiesChroniques:
      (json['maladiesChroniques'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'prenom': instance.prenom,
  'email': instance.email,
  'dateNaissance': instance.dateNaissance?.toIso8601String(),
  'telephone': instance.telephone,
  'adresse': instance.adresse,
  'role': instance.role,
  'groupeSanguin': instance.groupeSanguin,
  'allergies': instance.allergies,
  'maladiesChroniques': instance.maladiesChroniques,
};
