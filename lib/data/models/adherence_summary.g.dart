// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adherence_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdherenceSummary _$AdherenceSummaryFromJson(Map<String, dynamic> json) =>
    AdherenceSummary(
      tauxGlobal: (json['tauxGlobal'] as num).toDouble(),
      taux7Jours: (json['taux7Jours'] as num).toDouble(),
      prisesConfirmees: (json['prisesConfirmees'] as num).toInt(),
      prisesManquees: (json['prisesManquees'] as num).toInt(),
      prisesPrevues: (json['prisesPrevues'] as num).toInt(),
      alerteCritique: json['alerteCritique'] as bool,
      messageAlerte: json['messageAlerte'] as String?,
    );

Map<String, dynamic> _$AdherenceSummaryToJson(AdherenceSummary instance) =>
    <String, dynamic>{
      'tauxGlobal': instance.tauxGlobal,
      'taux7Jours': instance.taux7Jours,
      'prisesConfirmees': instance.prisesConfirmees,
      'prisesManquees': instance.prisesManquees,
      'prisesPrevues': instance.prisesPrevues,
      'alerteCritique': instance.alerteCritique,
      'messageAlerte': instance.messageAlerte,
    };
