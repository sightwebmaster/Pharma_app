<<<<<<< HEAD
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
 
=======
import 'package:flutter/foundation.dart';

import '../../data/models/user_model.dart';
import '../../services/patient_profile_service.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  final PatientProfileService _profileService = PatientProfileService();

  ProfileStatus _status = ProfileStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  String? _qrCode;
  String? _qrErrorMessage;
  bool _isSaving = false;
  bool _isQrLoading = false;

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  ProfileStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get qrCode => _qrCode;
<<<<<<< HEAD
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
=======
  String? get qrErrorMessage => _qrErrorMessage;
  bool get isSaving => _isSaving;
  bool get isLoading => _status == ProfileStatus.loading;
  bool get isQrLoading => _isQrLoading;
  bool get isSuccess => _status == ProfileStatus.success;
  bool get isError => _status == ProfileStatus.error;

  Future<void> loadProfile([String? _]) async {
    _status = ProfileStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final response = await _profileService.getMyProfile();
    if (response.success && response.data != null) {
      _currentUser = response.data;
      if (response.data!.qrCode != null && response.data!.qrCode!.isNotEmpty) {
        _qrCode = response.data!.qrCode;
        _qrErrorMessage = null;
      }
      _status = ProfileStatus.success;
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
    } else {
      _status = ProfileStatus.error;
      _errorMessage = response.message ?? 'Erreur chargement profil';
    }
<<<<<<< HEAD
 
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
 
=======
    notifyListeners();
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _profileService.updateProfile(updatedUser);
    _isSaving = false;

    if (response.success && response.data != null) {
      _currentUser = response.data;
      _status = ProfileStatus.success;
      notifyListeners();
      return true;
    }

    _status = ProfileStatus.error;
    _errorMessage = response.message ?? 'Mise à jour impossible';
    notifyListeners();
    return false;
  }

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  Future<bool> updateProfileField({
    required String fieldName,
    required dynamic fieldValue,
  }) async {
<<<<<<< HEAD
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
 
=======
    final currentUser = _currentUser;
    if (currentUser == null) {
      _status = ProfileStatus.error;
      _errorMessage = 'Profil non chargé';
      notifyListeners();
      return false;
    }

    final updated = switch (fieldName) {
      'nom' => currentUser.copyWith(nom: fieldValue as String),
      'prenom' => currentUser.copyWith(prenom: fieldValue as String),
      'telephone' => currentUser.copyWith(telephone: fieldValue as String?),
      'dateNaissance' => currentUser.copyWith(dateNaissance: _coerceDate(fieldValue)),
      'groupeSanguin' => currentUser.copyWith(groupeSanguin: fieldValue as String?),
      'allergies' => currentUser.copyWith(
          allergies: List<String>.from(fieldValue as List<dynamic>),
        ),
      'maladiesChroniques' => currentUser.copyWith(
          maladiesChroniques: List<String>.from(fieldValue as List<dynamic>),
        ),
      'numeroOrdre' => currentUser.copyWith(numeroOrdre: fieldValue as String?),
      'specialite' => currentUser.copyWith(specialite: fieldValue as String?),
      'photoBase64' => currentUser.copyWith(photoBase64: fieldValue as String?),
      'enceinte' => currentUser.copyWith(enceinte: fieldValue as bool?),
      _ => currentUser,
    };

    return updateProfile(updated);
  }

  Future<bool> loadQrCode() async {
    final cachedQr = _currentUser?.qrCode;
    if (cachedQr != null && cachedQr.isNotEmpty) {
      _qrCode = cachedQr;
      _qrErrorMessage = null;
      notifyListeners();
      return true;
    }

    _isQrLoading = true;
    _qrErrorMessage = null;
    notifyListeners();

    final response = await _profileService.getMyQrCode();
    if (response.success && response.data != null) {
      _qrCode = response.data;
      _qrErrorMessage = null;
      _isQrLoading = false;
      notifyListeners();
      return true;
    }

    _isQrLoading = false;
    _qrErrorMessage = response.message ?? 'Erreur chargement QR Code';
    notifyListeners();
    return false;
  }

  void syncCurrentUser(UserModel? user) {
    if (user == null) {
      return;
    }

    final existing = _currentUser;
    if (existing != null && existing.id == user.id) {
      _currentUser = existing.copyWith(
        nom: user.nom.isNotEmpty ? user.nom : existing.nom,
        prenom: user.prenom.isNotEmpty ? user.prenom : existing.prenom,
        email: user.email ?? existing.email,
        telephone: user.telephone ?? existing.telephone,
        adresse: user.adresse ?? existing.adresse,
        role: user.role.isNotEmpty ? user.role : existing.role,
        groupeSanguin: user.groupeSanguin ?? existing.groupeSanguin,
        allergies: user.allergies.isNotEmpty ? user.allergies : existing.allergies,
        maladiesChroniques: user.maladiesChroniques.isNotEmpty
            ? user.maladiesChroniques
            : existing.maladiesChroniques,
        numeroOrdre: user.numeroOrdre ?? existing.numeroOrdre,
        specialite: user.specialite ?? existing.specialite,
        enceinte: user.enceinte ?? existing.enceinte,
        photoBase64: user.photoBase64 ?? existing.photoBase64,
        qrCode: user.qrCode ?? existing.qrCode,
        dateNaissance: user.dateNaissance ?? existing.dateNaissance,
      );
    } else {
      _currentUser = user;
    }

    if ((_currentUser?.qrCode?.isNotEmpty ?? false) && _qrCode == null) {
      _qrCode = _currentUser!.qrCode;
      _qrErrorMessage = null;
    }
    notifyListeners();
  }

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  void resetState() {
    _status = ProfileStatus.initial;
    _currentUser = null;
    _errorMessage = null;
    _qrCode = null;
<<<<<<< HEAD
    _isSaving = false;
    notifyListeners();
  }
 
=======
    _qrErrorMessage = null;
    _isSaving = false;
    _isQrLoading = false;
    notifyListeners();
  }

>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
<<<<<<< HEAD
}
 




=======

  DateTime? _coerceDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
>>>>>>> dc6ccb98422de4442b9a23b8821d05e677c94234
