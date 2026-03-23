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
  dateNaissance: json['dateNaissance'] as DateTime,
  telephone: json['telephone'] as String?,
  adresse: json['adresse'] as String?,
  role: json['role'] as String,
  groupeSanguin: json['groupeSanguin'] as String,
  allergies: json['allergies'] as List<String>,
  maladiesChroniques: json['maladiesChroniques'] as List<String>,
  

);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'prenom': instance.prenom,
  'dateNaissance': instance.dateNaissance,
  'email': instance.email,
  'telephone': instance.telephone,
  'adresse': instance.adresse,
  'role': instance.role,
  'groupeSanguin': instance.groupeSanguin,
  'allergies': instance.allergies,
  'maladiesChroniques': instance.maladiesChroniques


  
};
