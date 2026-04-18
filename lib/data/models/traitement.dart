class Traitement {
  final String id;
  final String patientUserId;
  final String pharmacienUserId;
  final String? role;
  final String statut;       // ACTIF | SUSPENDU | TERMINE
  final String dateDebut;
  final String dateFin;
  final String? motif;
  final List<dynamic> lignes;
  final Set<dynamic> prises; // PrisePlanifiee générées automatiquement

  Traitement({
    required this.id,
    required this.patientUserId,
    required this.pharmacienUserId,
    required this.role,
    required this.statut,
    required this.dateDebut,
    required this.dateFin,
    this.motif,
    required this.lignes,
    required this.prises,
  });

  factory Traitement.fromJson(Map<String, dynamic> json) {
    return Traitement(
      id:               json['id'] as String? ?? '',
      patientUserId:    json['patientUserId'] as String? ?? '',
      pharmacienUserId: json['pharmacienUserId'] as String? ?? '',
      role:             json['role'] as String?,
      statut:           json['statut'] as String? ?? 'ACTIF',
      dateDebut:        json['dateDebut'] as String? ?? '',
      dateFin:          json['dateFin'] as String? ?? '',
      motif:            json['motif'] as String?,
      lignes:           json['lignes'] as List<dynamic>? ?? [],
      prises:           json['prises'] as Set<dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() => {
    'id':               id,
    'patientUserId':    patientUserId,
    'pharmacienUserId': pharmacienUserId,
    'role':             role,
    'statut':           statut,
    'dateDebut':        dateDebut,
    'dateFin':          dateFin,
    'motif':            motif,
    'lignes':           lignes,
    'prises':           prises,
  };
}
