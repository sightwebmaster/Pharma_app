class UserModel {
  const UserModel({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.role,
    this.email,
    this.dateNaissance,
    this.telephone,
    this.adresse,
    this.groupeSanguin,
    this.allergies = const [],
    this.maladiesChroniques = const [],
    this.numeroOrdre,
    this.specialite,
    this.enceinte,
    this.photoBase64,
    this.qrCode,
  });

  final String id;
  final String nom;
  final String prenom;
  final String role;
  final String? email;
  final DateTime? dateNaissance;
  final String? telephone;
  final String? adresse;
  final String? groupeSanguin;
  final List<String> allergies;
  final List<String> maladiesChroniques;
  final String? numeroOrdre;
  final String? specialite;
  final bool? enceinte;
  final String? photoBase64;
  final String? qrCode;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawRole =
        (json['role'] ?? json['userRole'] ?? _inferRoleFromPayload(json) ?? 'PATIENT')
            .toString();

    return UserModel(
      id: (json['userId'] ?? json['id'] ?? '').toString(),
      nom: (json['nom'] ?? '').toString(),
      prenom: (json['prenom'] ?? '').toString(),
      email: _nullableString(json['email']),
      dateNaissance: _parseDate(json['dateNaissance']),
      telephone: _nullableString(json['telephone']),
      adresse: _nullableString(json['adresse']),
      role: rawRole,
      groupeSanguin: _nullableString(json['groupeSanguin']),
      allergies: _stringList(json['allergies']),
      maladiesChroniques: _stringList(json['maladiesChroniques']),
      numeroOrdre: _nullableString(json['numeroOrdre']),
      specialite: _nullableString(json['specialite']),
      enceinte: json['enceinte'] is bool ? json['enceinte'] as bool : null,
      photoBase64: _nullableString(json['photoBase64']),
      qrCode: _nullableString(json['qrCode']),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'userId': id,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'dateNaissance': dateNaissance?.toIso8601String(),
      'telephone': telephone,
      'adresse': adresse,
      'role': role,
      'groupeSanguin': groupeSanguin,
      'allergies': allergies,
      'maladiesChroniques': maladiesChroniques,
      'numeroOrdre': numeroOrdre,
      'specialite': specialite,
      'enceinte': enceinte,
      'photoBase64': photoBase64,
      'qrCode': qrCode,
    };

    map.removeWhere((key, value) => value == null);
    return map;
  }

  String get fullName => '$prenom $nom'.trim();
  bool get isPatient => role.toUpperCase() == 'PATIENT';
  bool get isPharmacien => role.toUpperCase() == 'PHARMACIEN';
  String get initials {
    final parts = [prenom, nom].where((value) => value.trim().isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    return parts.map((value) => value.trim()[0]).take(2).join().toUpperCase();
  }

  UserModel copyWith({
    String? id,
    String? nom,
    String? prenom,
    String? email,
    DateTime? dateNaissance,
    String? telephone,
    String? adresse,
    String? role,
    String? groupeSanguin,
    List<String>? allergies,
    List<String>? maladiesChroniques,
    String? numeroOrdre,
    String? specialite,
    bool? enceinte,
    String? photoBase64,
    String? qrCode,
  }) {
    return UserModel(
      id: id ?? this.id,
      nom: nom ?? this.nom,
      prenom: prenom ?? this.prenom,
      email: email ?? this.email,
      dateNaissance: dateNaissance ?? this.dateNaissance,
      telephone: telephone ?? this.telephone,
      adresse: adresse ?? this.adresse,
      role: role ?? this.role,
      groupeSanguin: groupeSanguin ?? this.groupeSanguin,
      allergies: allergies ?? this.allergies,
      maladiesChroniques: maladiesChroniques ?? this.maladiesChroniques,
      numeroOrdre: numeroOrdre ?? this.numeroOrdre,
      specialite: specialite ?? this.specialite,
      enceinte: enceinte ?? this.enceinte,
      photoBase64: photoBase64 ?? this.photoBase64,
      qrCode: qrCode ?? this.qrCode,
    );
  }

  static String? _inferRoleFromPayload(Map<String, dynamic> json) {
    if (json.containsKey('numeroOrdre') || json.containsKey('specialite')) {
      return 'PHARMACIEN';
    }
    if (json.containsKey('groupeSanguin') ||
        json.containsKey('maladiesChroniques') ||
        json.containsKey('allergies')) {
      return 'PATIENT';
    }
    return null;
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }

  static List<String> _stringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }
}
