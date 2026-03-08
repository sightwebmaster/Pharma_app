import 'package:flutter/material.dart';

class MedicationModel {
  final String id;
  final String name;
  final String dose;
  final String time;
  final bool taken;
  final DateTime date;

  MedicationModel({
    required this.id,
    required this.name,
    required this.dose,
    required this.time,
    required this.taken,
    required this.date,
  });

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      id: json['id'] as String? ?? '',
      name: json['nom'] as String? ?? json['name'] as String? ?? '',
      dose: json['dosage'] as String? ?? json['dose'] as String? ?? '',
      time: json['heurePrise'] as String? ?? json['time'] as String? ?? '',
      taken: json['prise'] as bool? ?? json['taken'] as bool? ?? false,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Converts to Map<String, dynamic> for backward compatibility with existing UI widgets
  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'dose': dose,
        'time': time,
        'icon': Icons.medication_outlined,
        'color': const Color(0xFF4361EE),
        'taken': taken,
        'date': date,
      };
}