class ApiConfig {
  static const String _apiScheme = String.fromEnvironment(
    'API_SCHEME',
    defaultValue: 'http',
  );
  static const String _apiHost = String.fromEnvironment(
    'API_HOST',
    defaultValue: 'localhost',
  );
  static const String _gatewayPort = String.fromEnvironment(
    'GATEWAY_PORT',
    defaultValue: '8085',
  );
  static const String _userServicePort = String.fromEnvironment(
    'USER_SERVICE_PORT',
    defaultValue: '8083',
  );
  static const String _recommendationPort = String.fromEnvironment(
    'RECOMMENDATION_SERVICE_PORT',
    defaultValue: '8095',
  );

  // BASE URLs
  static const String baseUrl = '$_apiScheme://$_apiHost:$_gatewayPort';
  static const String authBaseUrl =
      '$_apiScheme://$_apiHost:$_userServicePort';
  static const String recommendationBaseUrl =
      '$_apiScheme://$_apiHost:$_recommendationPort';

  // TIMEOUTS
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // HEADERS
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // AUTH
  static const String loginEndpoint = '/api/v1/auth/login';
  static const String registerEndpoint = '/api/v1/auth/register';
  static const String changePasswordEndpoint = '/api/v1/auth/change-password';

  // PHARMACIEN
  static String pharmacienProfile(String pharmacienId) =>
      '/api/v1/pharmaciens/$pharmacienId/profile';

  static String pharmacienUpdateProfile(String pharmacienId) =>
      '/api/v1/pharmaciens/$pharmacienId/profile';

  static String pharmacienMesPatients(String pharmacienId) =>
      '/api/v1/pharmaciens/$pharmacienId/mes-patients';

  static String pharmacienScanQr(String pharmacienId) =>
      '/api/v1/pharmaciens/$pharmacienId/scan-qr';

  static String pharmacienCreatePatient(String pharmacienId) =>
      '/api/v1/pharmaciens/$pharmacienId/create-patient';

  static String patientProfileByPharmacien(String patientId) =>
      '/api/v1/pharmaciens/patients/$patientId/profile';

  static const String patientProfileByEmailByPharmacien =
      '/api/v1/pharmaciens/patients/by-email';

  static String patientProches(String patientId) =>
      '/api/v1/pharmaciens/patients/$patientId/proches';

  // TRAITEMENTS
  static const String creerTraitement = '/api/v1/treatments';

  static String traitementActif(String patientId) =>
      '/api/v1/treatments/patient/$patientId/actif';

  static String tousLesTraitements(String patientId) =>
      '/api/v1/treatments/patient/$patientId';

  static String traitementById(String traitementId) =>
      '/api/v1/treatments/$traitementId';

  static String modifierStatutTraitement(String traitementId) =>
      '/api/v1/treatments/$traitementId/statut';

  static String prisesAujourdhui(String patientId) =>
      '/api/v1/treatments/patient/$patientId/prises/today';

  static String toutesLesPrises(String patientId) =>
      '/api/v1/treatments/patient/$patientId/prises';

  static String prisesParTraitement(String traitementId) =>
      '/api/v1/treatments/$traitementId/prises';

  static String confirmerPrise(String traitementId, String priseId) =>
      '/api/v1/treatments/$traitementId/prises/$priseId/confirm';

  // ADHERENCE
  static String adherenceSummary(String patientId) =>
      '/api/adherence/$patientId/summary';

  static String adherenceHistorique(String patientId) =>
      '/api/adherence/$patientId/historique';

  static String adherenceParTraitement(String patientId, String traitementId) =>
      '/api/adherence/$patientId/traitement/$traitementId';

  // MEDICATIONS
  static const String medicamentSearch = '/api/v1/medications/search';
  static const String medicamentSearchSymptoms =
      '/api/v1/medications/search/symptoms';

  static String medicamentById(String id) => '/api/v1/medications/$id';

  static const String checkContreIndications =
      '/api/v1/medications/check-contre-indications';

  // NOTIFICATIONS
  static const String registerFcmToken = '/api/v1/notifications/device-token';

  static String notificationHistorique(String patientId) =>
      '/api/v1/notifications/historique/$patientId';

  // PAYMENT
  static const String passerCommande = '/api/v1/payments/commande';
  static const String historiqueCommandes = '/api/v1/payments/historique';

  // PATIENT
  static String patientGetProfile(String userId) =>
      '/api/v1/patients/$userId/profile';

  static String patientUpdateProfile(String userId) =>
      '/api/v1/patients/$userId/profile';

  static String patientQrCode(String userId) =>
      '/api/v1/patients/$userId/qrcode';
}
