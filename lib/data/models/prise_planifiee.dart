class PrisePlanifiee {
  final String id;
  final String traitementId;
  final String patientUserId;
  final String medicamentNom;
  final String type;
  final String? dosage;
  final int? duration; // NOUVEAU: duration
  final String? instruction; // NOUVEAU: instruction (depuis isntruction)
  final String? heurePrevue; // format "2026-04-06T08:00:00"
  final String? heureReelle;
  final String statut; // "PLANIFIEE" | "CONFIRMEE" | "MANQUEE"

  PrisePlanifiee({
    required this.id,
    this.traitementId = '',
    this.patientUserId = '',
    required this.medicamentNom,
    this.type = 'Inconnu',
    this.dosage,
    this.duration,
    this.instruction,
    this.heurePrevue,
    this.heureReelle,
    required this.statut,
  });

  PrisePlanifiee copyWith({String? statut}) => PrisePlanifiee(
    id: id,
    traitementId: traitementId,
    patientUserId: patientUserId,
    medicamentNom: medicamentNom,
    type: type,
    dosage: dosage,
    duration: duration,
    instruction: instruction,
    heurePrevue: heurePrevue,
    heureReelle: heureReelle,
    statut: statut ?? this.statut,
  );

  factory PrisePlanifiee.fromJson(Map<String, dynamic> json) => PrisePlanifiee(
    id: json['id'] as String? ?? '',
    traitementId: json['traitementId'] as String? ?? '',
    patientUserId: json['patientUserId'] as String? ?? '',
    medicamentNom: json['medicamentNom'] as String? ?? 'Médicament',
    type: json['type'] as String? ?? 'Inconnu',
    dosage: json['dosage'] as String?,
    duration: json['duration'] as int?,
    instruction:
        json['isntruction']
            as String?, // Mappé sur "isntruction" (DTO orthographe)
    heurePrevue: json['heurePrevue'] as String?,
    heureReelle: json['heureReelle'] as String?,
    statut: json['statut'] as String? ?? 'PLANIFIEE',
  );

  DateTime? get heurePrevueDateTime =>
      heurePrevue == null ? null : DateTime.tryParse(heurePrevue!);

  bool get isConfirmed => statut == 'CONFIRMEE';
  bool get isMissed => statut == 'MANQUEE';
  bool get isScheduled => statut == 'PLANIFIEE';
}
