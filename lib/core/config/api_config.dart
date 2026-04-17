class ApiConfig {
  // ══════════════════════════════════════════════════════════════
  // BASE URLs
  // ══════════════════════════════════════════════════════════════

  /// Gateway — pour TOUS les endpoints authentifiés (JWT requis)
  static const String baseUrl = 'http://localhost:8085';

  /// User-service direct — pour login/register UNIQUEMENT (pas de JWT)
  static const String authBaseUrl = 'http://localhost:8083';

  // ══════════════════════════════════════════════════════════════
  // TIMEOUTS
  // ══════════════════════════════════════════════════════════════

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ══════════════════════════════════════════════════════════════
  // HEADERS
  // ══════════════════════════════════════════════════════════════

  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ══════════════════════════════════════════════════════════════
  // AUTH — appels directs sur user-service (port 8083)
  // Pas de JWT requis — utiliser authDio
  // ══════════════════════════════════════════════════════════════

  /// POST { email, motDePasse } → AuthResponse
  static const String loginEndpoint = '/api/v1/auth/login';

  /// POST { nom, prenom, email, motDePasse, telephone, ... } → AuthResponse
  static const String registerEndpoint = '/api/v1/auth/register';

  // Note : refresh-token, logout, reset-password n'existent PAS dans le backend.
  // Gérer le logout côté Flutter (supprimer le token local).
  // Gérer le refresh en rappelant loginEndpoint.

  // ══════════════════════════════════════════════════════════════
  // PHARMACIEN — via Gateway (port 8085) — JWT requis
  // ══════════════════════════════════════════════════════════════

  /// GET → PharmacienProfileResponse
  static String pharmacienProfile(String pharmacienId) =>
      '/api/v1/pharmaciens/$pharmacienId/profile';

  /// GET → List<PatientProfileResponse>
  /// Tous les patients liés à ce pharmacien (scannés ou créés)
  static String pharmacienMesPatients(String pharmacienId) =>
      '/api/v1/pharmaciens/$pharmacienId/mes-patients';

  /// POST { patientUserId: "uuid" } → PatientProfileResponse
  /// Scan QR Code → lie le patient au pharmacien
  static String pharmacienScanQr(String pharmacienId) =>
      '/api/v1/pharmaciens/$pharmacienId/scan-qr';

  /// POST { nom, prenom, email, motDePasse, telephone, ... } → PatientProfileResponse
  /// Pharmacien crée un compte patient complet
  static String pharmacienCreatePatient(String pharmacienId) =>
      '/api/v1/pharmaciens/$pharmacienId/create-patient';

  /// GET ?pharmacienUserId={id} → PatientProfileResponse
  static String patientProfileByPharmacien(String patientId) =>
      '/api/v1/pharmaciens/patients/$patientId/profile';

  /// GET ?pharmacienUserId={id} → List<ProcheResponse>
  static String patientProches(String patientId) =>
      '/api/v1/pharmaciens/patients/$patientId/proches';

  // ══════════════════════════════════════════════════════════════
  // TRAITEMENTS — treatment-service via Gateway
  // ══════════════════════════════════════════════════════════════

  /// POST body traitement → TraitementResponse (PHARMACIEN uniquement)
  /// Body: { patientUserId, pharmacienUserId, dateDebut, dateFin, motif, lignes[] }
  static const String creerTraitement = '/api/v1/treatments';

  /// GET → TraitementResponse (traitement actif du patient)
  static String traitementActif(String patientId) =>
      '/api/v1/treatments/patient/$patientId/actif';

  /// GET → List<TraitementResponse> (tous les traitements du patient)
  static String tousLesTraitements(String patientId) =>
      '/api/v1/treatments/patient/$patientId';

  /// GET → TraitementResponse (par ID)
  static String traitementById(String traitementId) =>
      '/api/v1/treatments/$traitementId';

  /// PUT { nouveauStatut, motif } → TraitementResponse (PHARMACIEN uniquement)
  /// Statuts : ACTIF | SUSPENDU | TERMINE
  static String modifierStatutTraitement(String traitementId) =>
      '/api/v1/treatments/$traitementId/statut';

  /// GET → List<PriseResponse> (prises du jour du patient)
  static String prisesAujourdhui(String patientId) =>
      '/api/v1/treatments/patient/$patientId/prises/today';

  /// GET → List<PriseResponse> (toutes les prises d'un traitement)
  static String prisesParTraitement(String traitementId) =>
      '/api/v1/treatments/$traitementId/prises';

  /// POST (pas de body) → PriseResponse (PATIENT uniquement)
  /// Confirme la prise d'un médicament
  static String confirmerPrise(String priseId) =>
      '/api/v1/treatments/prises/$priseId/confirmer';

  // ══════════════════════════════════════════════════════════════
  // ADHERENCE — adherence-service via Gateway
  // ══════════════════════════════════════════════════════════════

  /// GET → AdherenceSummaryResponse
  /// { tauxGlobal, taux7Jours, taux30Jours, taux90Jours, alerteCritique }
  static String adherenceSummary(String patientId) =>
      '/api/adherence/$patientId/summary';

  /// GET → List<HistoriqueEntry> (avec filtres optionnels)
  /// Query params: ?traitementId=&statut=MANQUEE&from=&to=
  static String adherenceHistorique(String patientId) =>
      '/api/adherence/$patientId/historique';

  /// GET → AdherenceParTraitementResponse
  static String adherenceParTraitement(String patientId, String traitementId) =>
      '/api/adherence/$patientId/traitement/$traitementId';

  // ══════════════════════════════════════════════════════════════
  // MÉDICAMENTS — medication-service via Gateway
  // ══════════════════════════════════════════════════════════════

  /// GET ?q=doliprane → List<MedicamentResponse>
  /// Cascade: Redis → MySQL → OpenFDA
  static const String medicamentSearch = '/api/v1/medications/search';

  /// POST ["maux de tête", "fièvre"] → List<MedicamentResponse>
  static const String medicamentSearchSymptoms =
      '/api/v1/medications/search/symptoms';

  /// GET → MedicamentResponse
  static String medicamentById(String id) => '/api/v1/medications/$id';

  /// POST { medicamentId, allergies[], maladiesChroniques[], age, enceinte }
  /// → ContreIndicationResponse { safe, alertes[], avertissements[] }
  static const String checkContreIndications =
      '/api/v1/medications/check-contre-indications';

  // ══════════════════════════════════════════════════════════════
  // NOTIFICATIONS — notification-service via Gateway
  // ══════════════════════════════════════════════════════════════

  /// POST { deviceToken, plateforme: "ANDROID" } → 200 OK
  static const String registerFcmToken = '/api/v1/notifications/device-token';

  /// GET → List<NotificationResponse> (50 dernières)
  static String notificationHistorique(String patientId) =>
      '/api/v1/notifications/historique/$patientId';

  // ══════════════════════════════════════════════════════════════
  // PAYMENT — payment-service via Gateway (Phase 4)
  // ══════════════════════════════════════════════════════════════

  /// POST { medicamentIds[], adresse } → CommandeResponse
  static const String passerCommande = '/api/v1/payments/commande';

  /// GET → List<CommandeResponse>
  static const String historiqueCommandes = '/api/v1/payments/historique';


  // Patient — profil complet (PatientController)
  static String patientGetProfile(String userId) =>
      '/api/v1/patients/$userId/profile';
  static String patientUpdateProfile(String userId) =>
      '/api/v1/patients/$userId/profile';
  static String patientQrCode(String userId) =>
      '/api/v1/patients/$userId/qrcode';

}
