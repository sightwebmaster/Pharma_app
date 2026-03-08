import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/storage_keys.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  // Initialiser SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ===== TOKENS (stockage sécurisé) =====

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: StorageKeys.accessToken, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: StorageKeys.accessToken);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: StorageKeys.refreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: StorageKeys.refreshToken);
  }

  Future<void> deleteTokens() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
  }

  // ===== USER DATA (stockage normal) =====

  Future<void> saveUserId(String userId) async {
    await _prefs?.setString(StorageKeys.userId, userId);
  }

  String? getUserId() {
    return _prefs?.getString(StorageKeys.userId);
  }

  Future<void> saveUserEmail(String email) async {
    await _prefs?.setString(StorageKeys.userEmail, email);
  }

  String? getUserEmail() {
    return _prefs?.getString(StorageKeys.userEmail);
  }

  Future<void> saveUserRole(String role) async {
    await _prefs?.setString(StorageKeys.userRole, role);
  }

  String? getUserRole() {
    return _prefs?.getString(StorageKeys.userRole);
  }

  Future<void> saveUserName(String name) async {
    await _prefs?.setString(StorageKeys.userName, name);
  }

  String? getUserName() {
    return _prefs?.getString(StorageKeys.userName);
  }

  Future<void> saveIsLoggedIn(bool value) async {
    await _prefs?.setBool(StorageKeys.isLoggedIn, value);
  }

  bool getIsLoggedIn() {
    return _prefs?.getBool(StorageKeys.isLoggedIn) ?? false;
  }

  // ===== APP PREFERENCES =====

  Future<void> saveAppLanguage(String language) async {
    await _prefs?.setString(StorageKeys.appLanguage, language);
  }

  String? getAppLanguage() {
    return _prefs?.getString(StorageKeys.appLanguage);
  }

  // ===== CLEAR ALL =====

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs?.clear();
  }
}
