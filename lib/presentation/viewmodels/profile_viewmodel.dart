// ─────────────────────────────────────────────────────────────
// FICHIER 1 : profile_viewmodel.dart
// ─────────────────────────────────────────────────────────────
 
import 'package:flutter/foundation.dart';
import '../../data/models/user_model.dart';
import '../../services/patient_profile_service.dart';
import '../../services/storage_service.dart';
 
enum ProfileStatus { initial, loading, success, error }
 
class ProfileViewModel extends ChangeNotifier {
  final PatientProfileService _profileService = PatientProfileService();
  final StorageService _storage = StorageService();
 
  ProfileStatus _status = ProfileStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  String? _qrCode;       // ✅ QR Code base64 du patient
  bool _isSaving = false;
 
  ProfileStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get qrCode => _qrCode;
  bool get isSaving => _isSaving;
  bool get isLoading => _status == ProfileStatus.loading;
  bool get isSuccess => _status == ProfileStatus.success;
  bool get isError => _status == ProfileStatus.error;
 
  // ═══════════════════════════════════════════════════════════════
  // LOAD PROFILE
  // ✅ Utilise le userId stocké si non fourni
  // ✅ Route selon le rôle PATIENT / PHARMACIEN
  // ═══════════════════════════════════════════════════════════════
 
  Future<void> loadProfile([String? userId]) async {
    _status = ProfileStatus.loading;
    notifyListeners();
 
    // ✅ Utilise le userId stocké localement si non fourni
    final id = userId ?? _storage.getUserId();
    if (id == null) {
      _status = ProfileStatus.error;
      _errorMessage = 'Utilisateur non connecté';
      notifyListeners();
      return;
    }
 
    final response = await _profileService.getMyProfile();
 
    if (response.success && response.data != null) {
      _currentUser = response.data;
      _status = ProfileStatus.success;
      _errorMessage = null;
    } else {
      _status = ProfileStatus.error;
      _errorMessage = response.message ?? 'Erreur chargement profil';
    }
 
    notifyListeners();
  }
 
  // ═══════════════════════════════════════════════════════════════
  // UPDATE PROFILE
  // ✅ Retourne 501 honnêtement si non implémenté
  // ═══════════════════════════════════════════════════════════════
 
  Future<bool> updateProfile(UserModel updatedUser) async {
    _isSaving = true;
    notifyListeners();
 
    final response = await _profileService.updatePatientProfile(updatedUser);
 
    _isSaving = false;
 
    if (response.success && response.data != null) {
      _currentUser = response.data;
      _status = ProfileStatus.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _status = ProfileStatus.error;
      _errorMessage = response.message ?? 'Mise à jour non disponible';
      notifyListeners();
      return false;
    }
  }
 
  Future<bool> updateProfileField({
    required String fieldName,
    required dynamic fieldValue,
  }) async {
    if (_currentUser == null) {
      _errorMessage = 'Profil non chargé';
      _status = ProfileStatus.error;
      notifyListeners();
      return false;
    }
 
    final updatedUser = _applyFieldUpdate(_currentUser!, fieldName, fieldValue);
    return await updateProfile(updatedUser);
  }
 
  UserModel _applyFieldUpdate(UserModel user, String fieldName, dynamic value) {
    switch (fieldName) {
      case 'nom':              return user.copyWith(nom: value as String);
      case 'prenom':           return user.copyWith(prenom: value as String);
      case 'email':            return user.copyWith(email: value as String?);
      case 'telephone':        return user.copyWith(telephone: value as String?);
      case 'dateNaissance':    return user.copyWith(dateNaissance: value as DateTime?);
      case 'groupeSanguin':    return user.copyWith(groupeSanguin: value as String?);
      case 'allergies':        return user.copyWith(allergies: value as List<String>);
      case 'maladiesChroniques': return user.copyWith(maladiesChroniques: value as List<String>);
      default:                 return user;
    }
  }
 
  // ═══════════════════════════════════════════════════════════════
  // QR CODE
  // ✅ Utilise GET /api/v1/patients/{userId}/qrcode
  // ❌ ÉTAIT : generateShareLink() → /patient/{id}/share-link (fantôme)
  // ═══════════════════════════════════════════════════════════════
 
  Future<bool> loadQrCode() async {
    _status = ProfileStatus.loading;
    notifyListeners();
 
    final response = await _profileService.getMyQrCode();
 
    if (response.success && response.data != null) {
      _qrCode = response.data;
      _status = ProfileStatus.success;
      _errorMessage = null;
      notifyListeners();
      return true;
    } else {
      _status = ProfileStatus.error;
      _errorMessage = response.message ?? 'Erreur chargement QR Code';
      notifyListeners();
      return false;
    }
  }
 
  // ═══════════════════════════════════════════════════════════════
  // RESET
  // ═══════════════════════════════════════════════════════════════
 
  void resetState() {
    _status = ProfileStatus.initial;
    _currentUser = null;
    _errorMessage = null;
    _qrCode = null;
    _isSaving = false;
    notifyListeners();
  }
 
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
 




