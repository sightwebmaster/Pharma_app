import 'package:flutter/material.dart';

class ProcheModel {
  final String id;
  final String nom;
  final String prenom;
  final String relation;
  final String? qrCode;
  final String? status;
  final String? nextMed;
  final String? avatarEmoji;
  final String
  userId; // ID of the linked patient account (procheUserId from backend)
  final String? patientUserId; // moi (from list endpoint)
  final String? telephone;
  final String? email;
  final String? groupeSanguin;
  final List<String>? allergies;
  final List<String>? maladiesChroniques;
  final String? dateNaissance;

  ProcheModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.relation,
    this.qrCode,
    this.status,
    this.nextMed,
    this.avatarEmoji,
    required this.userId,
    this.patientUserId,
    this.telephone,
    this.email,
    this.groupeSanguin,
    this.allergies,
    this.maladiesChroniques,
    this.dateNaissance,
  });

  String get fullName => '$prenom $nom';

  factory ProcheModel.fromJson(Map<String, dynamic> json) {
    // Handle both list response and profile response
    final allergiesList = json['allergies'] as List?;
    final maladieList = json['maladiesChroniques'] as List?;

    return ProcheModel(
      id: json['id'] as String? ?? '',
      nom: json['nom'] as String? ?? '',
      prenom: json['prenom'] as String? ?? '',
      relation: json['relation'] as String? ?? '',
      qrCode: json['qrCode'] as String?,
      status: json['status'] as String?,
      nextMed:
          json['nextMed'] as String? ?? json['prochainMedicament'] as String?,
      avatarEmoji: json['avatarEmoji'] as String? ?? json['avatar'] as String?,
      // Backend returns either 'userId' (profil endpoint) or 'procheUserId' (list endpoint)
      userId:
          json['userId'] as String? ?? json['procheUserId'] as String? ?? '',
      patientUserId: json['patientUserId'] as String?,
      telephone: json['telephone'] as String?,
      email: json['email'] as String?,
      groupeSanguin: json['groupeSanguin'] as String?,
      allergies: allergiesList?.map((e) => e.toString()).toList(),
      maladiesChroniques: maladieList?.map((e) => e.toString()).toList(),
      dateNaissance: json['dateNaissance'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'prenom': prenom,
      'relation': relation,
      'qrCode': qrCode,
      'status': status,
      'nextMed': nextMed,
      'avatarEmoji': avatarEmoji,
      'userId': userId,
      'patientUserId': patientUserId,
      'telephone': telephone,
      'email': email,
      'groupeSanguin': groupeSanguin,
      'allergies': allergies,
      'maladiesChroniques': maladiesChroniques,
      'dateNaissance': dateNaissance,
    };
  }

  /// Converts to Map<String, dynamic> for backward compatibility with existing UI widgets
  /// that expect fields like 'name', 'role', 'avatar', 'color'
  Map<String, dynamic> toMap() {
    // Determine color based on status
    Color statusColor;
    switch (status?.toLowerCase()) {
      case 'observant':
        statusColor = const Color(0xFF06D6A0); // Green
        break;
      case 'à surveiller':
        statusColor = const Color(0xFFFFA726); // Orange
        break;
      case 'rappel nécessaire':
        statusColor = const Color(0xFFEF476F); // Red
        break;
      default:
        statusColor = const Color(0xFF4361EE); // Blue
    }

    // Auto-assign emoji based on relation if not provided
    String emoji = avatarEmoji ?? _getDefaultEmoji(relation);

    return {
      'id': id,
      'name': fullName,
      'role': relation,
      'avatar': emoji,
      'status': status ?? 'Non défini',
      'nextMed': nextMed ?? 'Aucun médicament',
      'color': statusColor,
      'qrCode': qrCode,
      'userId': userId,
      'patientUserId': patientUserId,
      'telephone': telephone,
      'email': email,
      'groupeSanguin': groupeSanguin,
      'allergies': allergies,
      'maladiesChroniques': maladiesChroniques,
      'dateNaissance': dateNaissance,
    };
  }

  /// Returns a default emoji based on the relation type
  static String _getDefaultEmoji(String relation) {
    switch (relation.toLowerCase()) {
      case 'père':
        return '👴';
      case 'mère':
        return '👵';
      case 'grand-père':
        return '👴';
      case 'grand-mère':
        return '👵';
      case 'enfant':
        return '👶';
      case 'conjoint':
        return '👫';
      default:
        return '👤';
    }
  }

  ProcheModel copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? relation,
    String? qrCode,
    String? status,
    String? nextMed,
    String? avatarEmoji,
    String? userId,
  }) {
    return ProcheModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      relation: relation ?? this.relation,
      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,
      nextMed: nextMed ?? this.nextMed,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      userId: userId ?? this.userId,
    );
  }
}
