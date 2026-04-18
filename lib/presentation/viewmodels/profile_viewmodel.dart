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

  ProfileStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get qrCode => _qrCode;
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
    } else {
      _status = ProfileStatus.error;
      _errorMessage = response.message ?? 'Erreur chargement profil';
    }
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

  Future<bool> updateProfileField({
    required String fieldName,
    required dynamic fieldValue,
  }) async {
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

  void resetState() {
    _status = ProfileStatus.initial;
    _currentUser = null;
    _errorMessage = null;
    _qrCode = null;
    _qrErrorMessage = null;
    _isSaving = false;
    _isQrLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

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
