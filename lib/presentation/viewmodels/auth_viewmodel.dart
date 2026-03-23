import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isUnauthenticated => _status == AuthStatus.unauthenticated;

  // ===== INITIALISATION =====
  // Vérifier si l'utilisateur est déjà connecté au démarrage

  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final isLoggedIn = await _authService.isLoggedIn();

    if (isLoggedIn) {
      // L'utilisateur est connecté
      _status = AuthStatus.authenticated;
      // Note: Idéalement, récupérer le profil complet depuis le backend
      // Pour l'instant, on marque juste comme authentifié
    } else {
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  // ===== LOGIN =====

  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.login(email: email, password: password);

    if (response.success && response.data != null) {
      _currentUser = response.data!.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? 'Erreur de connexion';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ===== SIGNUP =====

  Future<bool> signup({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String telephone,
    required String adresse,
    required String role,
    String? groupeSanguin,
    List<String>? allergies,
    List<String>? maladiesChroniques,
    String? pharmacyName,
    String? licenseNumber,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.signup(
      nom: nom,
      prenom: prenom,
      email: email,
      password: password,
      telephone: telephone,
      adresse: adresse,
      role: role,
      groupeSanguin: groupeSanguin,
      allergies: allergies,
      maladiesChroniques: maladiesChroniques,
      pharmacyName: pharmacyName,
      licenseNumber: licenseNumber,
    );

    if (response.success && response.data != null) {
      _currentUser = response.data!.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? 'Erreur d\'inscription';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ===== LOGOUT =====

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await _authService.logout();

    _currentUser = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ===== CLEAR ERROR =====

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ===== REFRESH TOKEN =====

  Future<bool> refreshToken() async {
    final response = await _authService.refreshToken();
    if (response.success) {
      return true;
    } else {
      // Token refresh failed, logout user
      await logout();
      return false;
    }
  }
}
