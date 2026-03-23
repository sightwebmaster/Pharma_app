// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'traitement_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TraitementModel _$TraitementModelFromJson(Map<String, dynamic> json) =>
    TraitementModel(
      id: json['id'] as String,
      medicament: json['medicament'] as String,
      dosage: json['dosage'] as String,
      frequence: json['frequence'] as String,
      dateDebut: json['dateDebut'] as String?,
      dateFin: json['dateFin'] as String?,
      statut: json['statut'] as String,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$TraitementModelToJson(TraitementModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'medicament': instance.medicament,
      'dosage': instance.dosage,
      'frequence': instance.frequence,
      'dateDebut': instance.dateDebut,
      'dateFin': instance.dateFin,
      'statut': instance.statut,
      'notes': instance.notes,
    };
