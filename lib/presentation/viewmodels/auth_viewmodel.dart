import 'package:flutter/foundation.dart';
<<<<<<< HEAD
import '../../data/models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/patient_profile_service.dart';
=======

import '../../data/models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/fcm_registration_service.dart';
import '../../services/patient_profile_service.dart';
import '../../services/storage_service.dart';
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
<<<<<<< HEAD
  final PatientProfileService _profileService = PatientProfileService();
=======
  final FcmRegistrationService _fcmRegistrationService = FcmRegistrationService();
  final PatientProfileService _profileService = PatientProfileService();
  final StorageService _storage = StorageService();
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

<<<<<<< HEAD
  // Getters
=======
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isUnauthenticated => _status == AuthStatus.unauthenticated;

<<<<<<< HEAD
  // ===== INITIALISATION =====
  // Vérifier si l'utilisateur est déjà connecté au démarrage

=======
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  Future<void> checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final isLoggedIn = await _authService.isLoggedIn();
<<<<<<< HEAD

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

=======
    if (!isLoggedIn) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    await _hydrateUserFromBackend();
  }

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  Future<bool> login({required String email, required String password}) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.login(email: email, password: password);
<<<<<<< HEAD

    if (response.success && response.data != null) {
      _currentUser = response.data!.user;

      // Charger le profil complet du patient après le login
      final profileResponse = await _profileService.getPatientProfile(
        _currentUser!.id,
      );

      if (profileResponse.success && profileResponse.data != null) {
        // Remplacer avec les données complètes du profil
        _currentUser = profileResponse.data;
      }
      // Si le chargement du profil échoue, continuer avec les données basiques

      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
=======
    if (!response.success || response.data == null) {
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      _errorMessage = response.message ?? 'Erreur de connexion';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
<<<<<<< HEAD
  }

  // ===== SIGNUP =====
=======

    _currentUser = response.data!.user;
    _status = AuthStatus.authenticated;
    notifyListeners();
    _fcmRegistrationService.registerCurrentDevice();
    _hydrateUserFromBackend(fallbackUser: _currentUser);
    return true;
  }
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

  Future<bool> signup({
    required String nom,
    required String prenom,
    required String email,
    required String password,
    required String telephone,
    required String adresse,
    required String role,
<<<<<<< HEAD
=======
    DateTime? dateNaissance,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
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
<<<<<<< HEAD
=======
      dateNaissance: dateNaissance,
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      groupeSanguin: groupeSanguin,
      allergies: allergies,
      maladiesChroniques: maladiesChroniques,
    );

<<<<<<< HEAD
    if (response.success && response.data != null) {
      _currentUser = response.data!.user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? 'Erreur d\'inscription';
=======
    if (!response.success || response.data == null) {
      _errorMessage = response.message ?? 'Erreur d’inscription';
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
<<<<<<< HEAD
  }

  // ===== LOGOUT =====
=======

    _currentUser = response.data!.user;
    _status = AuthStatus.authenticated;
    notifyListeners();
    _fcmRegistrationService.registerCurrentDevice();
    _hydrateUserFromBackend(fallbackUser: _currentUser);
    return true;
  }
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234

  Future<void> logout() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await _authService.logout();
<<<<<<< HEAD

=======
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    _currentUser = null;
    _errorMessage = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

<<<<<<< HEAD
  // ===== CLEAR ERROR =====

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ===== REFRESH TOKEN =====

=======
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  Future<bool> refreshToken() async {
    final response = await _authService.refreshToken();
    if (response.success) {
      return true;
<<<<<<< HEAD
    } else {
      // Token refresh failed, logout user
      await logout();
      return false;
    }
=======
    }
    await logout();
    return false;
  }

  Future<bool> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _authService.changePassword(
      email: email,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    if (response.success) {
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    }

    _errorMessage = response.message ?? 'Impossible de modifier le mot de passe';
    _status = AuthStatus.error;
    notifyListeners();
    return false;
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _currentUser == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<void> reloadProfile() async {
    if (_currentUser == null && _storage.getUserId() == null) {
      return;
    }
    await _hydrateUserFromBackend(fallbackUser: _currentUser);
  }

  void setCurrentUser(UserModel? user) {
    _currentUser = user;
    if (user != null) {
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<void> _hydrateUserFromBackend({UserModel? fallbackUser}) async {
    final profileResponse = await _profileService.getMyProfile();
    if (profileResponse.success && profileResponse.data != null) {
      _currentUser = profileResponse.data;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
    } else if (fallbackUser != null) {
      _currentUser = fallbackUser.copyWith(
        role: _storage.getUserRole() ?? fallbackUser.role,
      );
      _status = AuthStatus.authenticated;
      _errorMessage = null;
    } else {
      final fullName = (_storage.getUserName() ?? '').trim();
      final parts = fullName.isEmpty ? <String>[] : fullName.split(' ');
      _currentUser = UserModel(
        id: _storage.getUserId() ?? '',
        nom: parts.length > 1 ? parts.sublist(1).join(' ') : '',
        prenom: parts.isNotEmpty ? parts.first : '',
        role: _storage.getUserRole() ?? 'PATIENT',
        email: _storage.getUserEmail(),
      );
      _status = AuthStatus.authenticated;
      _errorMessage = profileResponse.message;
    }
    _fcmRegistrationService.registerCurrentDevice();
    notifyListeners();
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  }
}
