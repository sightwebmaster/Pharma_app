import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthService {
  // ─────────────────────────────────────────────────────────────────────────────
  // Émulateur Android  → 10.0.2.2  (= localhost du PC)
  // Vrai téléphone     → IP du PC ex: 192.168.1.50
  // iOS Simulator      → localhost
  // ─────────────────────────────────────────────────────────────────────────────
  static const String _host = 'localhost';
  static const String _tokenUrl =
      'http://$_host:8080/realms/pharma-app/protocol/openid-connect/token';
  static const String _clientId = 'pharma-mobile';

  static const _storage = FlutterSecureStorage();

  // ── CONNEXION NATIVE (sans navigateur) ───────────────────────────────────
  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type': 'password',
          'client_id': _clientId,
          'username': email,
          'password': password,
          'scope': 'openid profile email',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final accessToken  = data['access_token']  as String;
        final refreshToken = data['refresh_token'] as String;

        await _storage.write(key: 'access_token',  value: accessToken);
        await _storage.write(key: 'refresh_token', value: refreshToken);

        final role  = _extractRole(accessToken);
        final email = _extractEmail(accessToken);
        final name  = _extractName(accessToken);

        await _storage.write(key: 'user_role',  value: role);
        await _storage.write(key: 'user_email', value: email);
        await _storage.write(key: 'user_name',  value: name);

        return true;
      } else {
        // 401 = mauvais credentials  |  400 = client mal configuré dans Keycloak
        print('Login failed [${response.statusCode}]: ${response.body}');
        return false;
      }
    } catch (e) {
      print('AuthService.login error: $e');
      return false;
    }
  }

  // ── REFRESH TOKEN ─────────────────────────────────────────────────────────
  static Future<bool> refreshToken() async {
    final refresh = await _storage.read(key: 'refresh_token');
    if (refresh == null) return false;

    try {
      final response = await http.post(
        Uri.parse(_tokenUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'grant_type':    'refresh_token',
          'client_id':     _clientId,
          'refresh_token': refresh,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _storage.write(key: 'access_token',  value: data['access_token']);
        await _storage.write(key: 'refresh_token', value: data['refresh_token']);
        return true;
      }
      return false;
    } catch (e) {
      print('AuthService.refreshToken error: $e');
      return false;
    }
  }

  // ── DÉCONNEXION ───────────────────────────────────────────────────────────
  static Future<void> logout() async => await _storage.deleteAll();

  // ── GETTERS ───────────────────────────────────────────────────────────────
  static Future<String?> getAccessToken() async =>
      await _storage.read(key: 'access_token');

  static Future<String> getRole() async =>
      await _storage.read(key: 'user_role') ?? 'PATIENT';

  static Future<String> getEmail() async =>
      await _storage.read(key: 'user_email') ?? '';

  static Future<String> getUserName() async =>
      await _storage.read(key: 'user_name') ?? '';

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  // ── EXTRACTION DEPUIS JWT ─────────────────────────────────────────────────
  static String _extractRole(String token) {
    try {
      final roles = _decodeToken(token)['realm_access']['roles'] as List;
      if (roles.contains('PHARMACIEN')) return 'PHARMACIEN';
      if (roles.contains('ADMIN'))      return 'ADMIN';
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
      final p = _decodeToken(token);
      return '${p['given_name'] ?? ''} ${p['family_name'] ?? ''}'.trim();
    } catch (_) {
      return '';
    }
  }

  static Map<String, dynamic> _decodeToken(String token) {
    final parts   = token.split('.');
    final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
    return json.decode(payload);
  }
}
