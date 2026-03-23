// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pharmacien_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PharmacienModel _$PharmacienModelFromJson(Map<String, dynamic> json) =>
    PharmacienModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      telephone: json['telephone'] as String,
      numeroOrdre: json['numeroOrdre'] as String,
      specialite: json['specialite'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PharmacienModelToJson(PharmacienModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'nom': instance.nom,
      'prenom': instance.prenom,
      'email': instance.email,
      'telephone': instance.telephone,
      'numeroOrdre': instance.numeroOrdre,
      'specialite': instance.specialite,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
