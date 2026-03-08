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
  telephone: json['telephone'] as String?,
  adresse: json['adresse'] as String?,
  role: json['role'] as String,
  pharmacyName: json['pharmacyName'] as String?,
  licenseNumber: json['licenseNumber'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'nom': instance.nom,
  'prenom': instance.prenom,
  'email': instance.email,
  'telephone': instance.telephone,
  'adresse': instance.adresse,
  'role': instance.role,
  'pharmacyName': instance.pharmacyName,
  'licenseNumber': instance.licenseNumber,
};
