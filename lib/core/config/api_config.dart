class ApiConfig {
  // URL de base du backend
  // IMPORTANT: Remplacer par l'URL réelle de votre backend
  static const String baseUrl = 'http://localhost:8083/api/v1';

  // Si backend déployé, utiliser:
  // static const String baseUrl = 'https://api.pharmaapp.com/api';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ===== Endpoints Auth =====
  static const String loginEndpoint = '/auth/login';
  static const String signupEndpoint = '/auth/register';
  static const String refreshTokenEndpoint = '/auth/refresh-token';
  static const String logoutEndpoint = '/auth/logout';
  static const String resetPasswordEndpoint = '/auth/reset-password';

  // ===== Endpoints User =====
  static const String profileEndpoint = '/users/profile';
  static const String updateProfileEndpoint = '/users/profile';
  static const String deleteAccountEndpoint = '/users/account';

  // ===== Endpoints Patient =====
  static const String patientMedicationsEndpoint = '/patient/medications';
  static const String patientPlanificationsEndpoint = '/patient/planifications';
  static const String patientProfileEndpoint = '/patient/profile';
  static const String patientConfirmTakenEndpoint = '/patient/medications';

  // Patient Proches (Family Members)
  static const String patientProchesEndpoint = '/patient/proches';
  static const String patientProcheDetailEndpoint =
      '/patient/proches/'; // + {id}

  // ===== Endpoints Pharmacien =====
  static const String pharmacienPatientsEndpoint = '/pharmacien/patients';
  static const String pharmacienStatsEndpoint = '/pharmacien/stats';
  static const String pharmacienTraitementsEndpoint = '/pharmacien/traitements';
  static const String pharmacienPlanifierEndpoint = '/pharmacien/planifier';

  // ===== Endpoints Products =====
  static const String productsEndpoint = '/products';
  static const String productDetailEndpoint = '/products/';
  static const String productSearchEndpoint = '/products/search';
  static const String productCategoriesEndpoint = '/products/categories';
  static const String pharmacienProductsEndpoint = '/pharmacien/products';

  // ===== Endpoints Orders =====
  static const String ordersEndpoint = '/orders';
  static const String orderDetailEndpoint = '/orders/';
  static const String orderTrackingEndpoint = '/orders/';
  static const String pharmacienOrdersEndpoint = '/pharmacien/orders';
  static const String cartEndpoint = '/cart';
  static const String cartItemsEndpoint = '/cart/items';

  // ===== Endpoints Prescriptions =====
  static const String prescriptionsEndpoint = '/prescriptions';
  static const String prescriptionDetailEndpoint = '/prescriptions/';
  static const String pharmacienPrescriptionsEndpoint =
      '/pharmacien/prescriptions';

  // ===== Endpoints Payments =====
  static const String paymentsEndpoint = '/payments';
  static const String paymentHistoryEndpoint = '/payments/history';

  // ===== Headers =====
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
