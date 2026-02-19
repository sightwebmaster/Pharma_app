import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AuthService {
  // ─────────────────────────────────────────────────────────────────────────────
  // IMPORTANT :
  //   Émulateur Android  → utiliser 10.0.2.2  (= localhost du PC)
  //   Vrai téléphone     → utiliser l'IP du PC ex: 192.168.1.50
  //   iOS Simulator      → utiliser localhost
  // ─────────────────────────────────────────────────────────────────────────────
  static const String _host = '10.0.2.2'; // ← changer si vrai téléphone
  static const String _issuer = 'http://$_host:8080/realms/pharma-app';
  static const String _clientId = 'pharma-mobile';
  static const String _redirectUrl = 'com.pharma://callback';

  static const _storage = FlutterSecureStorage();
  static final _appAuth = FlutterAppAuth();

  // ── CONNEXION ─────────────────────────────────────────────────────────────
  static Future<bool> login() async {
    try {
      final result = await _appAuth.authorizeAndExchangeCode(
        AuthorizationTokenRequest(
          _clientId,
          _redirectUrl,
          issuer: _issuer,
          scopes: ['openid', 'profile', 'email'],
          preferEphemeralSession: false,
        ),
      );

      if (result != null && result.accessToken != null) {
        await _storage.write(key: 'access_token', value: result.accessToken);
        await _storage.write(key: 'refresh_token', value: result.refreshToken);

        final role = _extractRole(result.accessToken!);
        final email = _extractEmail(result.accessToken!);
        final name = _extractName(result.accessToken!);

        await _storage.write(key: 'user_role', value: role);
        await _storage.write(key: 'user_email', value: email);
        await _storage.write(key: 'user_name', value: name);

        return true;
      }
      return false;
    } catch (e) {
      print('AuthService.login error: $e');
      return false;
    }
  }

  // ── DÉCONNEXION ───────────────────────────────────────────────────────────
  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  // ── GETTERS ───────────────────────────────────────────────────────────────
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  static Future<String> getRole() async {
    return await _storage.read(key: 'user_role') ?? 'PATIENT';
  }

  static Future<String> getEmail() async {
    return await _storage.read(key: 'user_email') ?? '';
  }

  static Future<String> getUserName() async {
    return await _storage.read(key: 'user_name') ?? '';
  }

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  // ── EXTRACTION DEPUIS JWT ─────────────────────────────────────────────────
  static String _extractRole(String token) {
    try {
      final payload = _decodeToken(token);
      final roles = payload['realm_access']['roles'] as List;
      if (roles.contains('PHARMACIEN')) return 'PHARMACIEN';
      if (roles.contains('ADMIN')) return 'ADMIN';
      return 'PATIENT';
    } catch (_) {
      return 'PATIENT';
    }
  }

  static String _extractEmail(String token) {
    try {
      return _decodeToken(token)['email'] ?? '';
    } catch (_) {
      return '';
    }
  }

  static String _extractName(String token) {
    try {
      final payload = _decodeToken(token);
      final given = payload['given_name'] ?? '';
      final family = payload['family_name'] ?? '';
      return '$given $family'.trim();
    } catch (_) {
      return '';
    }
  }

  static Map<String, dynamic> _decodeToken(String token) {
    final parts = token.split('.');
    final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])));
    return json.decode(payload);
  }
}
