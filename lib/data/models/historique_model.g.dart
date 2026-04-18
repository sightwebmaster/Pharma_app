// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'historique_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HistoriqueModel _$HistoriqueModelFromJson(Map<String, dynamic> json) =>
    HistoriqueModel(
      id: json['id'] as String,
      date: json['date'] as String,
      type: json['type'] as String,
      detail: json['detail'] as String,
      diagnostic: json['diagnostic'] as String?,
      traitement: json['traitement'] as String?,
    );

Map<String, dynamic> _$HistoriqueModelToJson(HistoriqueModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'type': instance.type,
      'detail': instance.detail,
      'diagnostic': instance.diagnostic,
      'traitement': instance.traitement,
    };
