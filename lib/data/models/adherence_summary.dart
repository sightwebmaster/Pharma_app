class AdherenceSummary {
  final String? traitementId;
  final String? patientUserId;
  final String? pharmacienUserId;
  final double tauxGlobal;
  final double taux7Jours;
  final double taux30Jours;
  final double taux90Jours;
  final int consecutiveMissed;
  final int prisesConfirmees;
  final int prisesManquees;
  final int prisesPrevues;
  final bool alerteCritique;
  final String? messageAlerte;
  final String? niveauObservance;

  AdherenceSummary({
    this.traitementId,
    this.patientUserId,
    this.pharmacienUserId,
    required this.tauxGlobal,
    required this.taux7Jours,
    required this.taux30Jours,
    required this.taux90Jours,
    required this.consecutiveMissed,
    required this.prisesConfirmees,
    required this.prisesManquees,
    required this.prisesPrevues,
    required this.alerteCritique,
    this.messageAlerte,
    this.niveauObservance,
  });

  factory AdherenceSummary.empty([String? patientId]) => AdherenceSummary(
    patientUserId: patientId,
    tauxGlobal: 0,
    taux7Jours: 0,
    taux30Jours: 0,
    taux90Jours: 0,
    consecutiveMissed: 0,
    prisesConfirmees: 0,
    prisesManquees: 0,
    prisesPrevues: 0,
    alerteCritique: false,
    messageAlerte: 'Aucune donnee d\'observance',
    niveauObservance: 'AUCUNE_DONNEE',
  );

  factory AdherenceSummary.fromJson(Map<String, dynamic> json) {
    final prisesConfirmees = (json['prisesConfirmees'] as num?)?.toInt() ?? 0;
    final prisesManquees = (json['prisesManquees'] as num?)?.toInt() ?? 0;
    final totalPrises = (json['totalPrises'] as num?)?.toInt() ??
        (json['prisesPrevues'] as num?)?.toInt() ??
        (prisesConfirmees + prisesManquees);

    return AdherenceSummary(
      traitementId: json['traitementId'] as String?,
      patientUserId: json['patientUserId'] as String?,
      pharmacienUserId: json['pharmacienUserId'] as String?,
      tauxGlobal: ((json['tauxGlobal'] as num?)?.toDouble() ?? 0) / 100,
      taux7Jours: ((json['taux7j'] as num?)?.toDouble() ??
              (json['taux7Jours'] as num?)?.toDouble() ??
              0) /
          100,
      taux30Jours: ((json['taux30j'] as num?)?.toDouble() ?? 0) / 100,
      taux90Jours: ((json['taux90j'] as num?)?.toDouble() ?? 0) / 100,
      consecutiveMissed: (json['consecutiveMissed'] as num?)?.toInt() ?? 0,
      prisesConfirmees: prisesConfirmees,
      prisesManquees: prisesManquees,
      prisesPrevues: totalPrises,
      alerteCritique: (json['alerteEnvoyee'] as bool?) ?? false,
      messageAlerte: json['messageAlerte'] as String?,
      niveauObservance: json['niveauObservance'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'traitementId': traitementId,
    'patientUserId': patientUserId,
    'pharmacienUserId': pharmacienUserId,
    'tauxGlobal': tauxGlobal,
    'taux7Jours': taux7Jours,
    'taux30Jours': taux30Jours,
    'taux90Jours': taux90Jours,
    'consecutiveMissed': consecutiveMissed,
    'prisesConfirmees': prisesConfirmees,
    'prisesManquees': prisesManquees,
    'prisesPrevues': prisesPrevues,
    'alerteCritique': alerteCritique,
    'messageAlerte': messageAlerte,
    'niveauObservance': niveauObservance,
  };

  int get pourcentageGlobal => (tauxGlobal * 100).round();
  int get pourcentage7Jours => (taux7Jours * 100).round();
}
