import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../core/config/api_config.dart';
import 'api_client.dart';

class FcmRegistrationService {
  FcmRegistrationService();

  final _dio = ApiClient().dio;

  Future<void> registerCurrentDevice() async {
    if (kIsWeb) {
      return;
    }

    try {
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null || token.isEmpty) {
        return;
      }

      await _dio.post(
        ApiConfig.registerFcmToken,
        data: {
          'deviceToken': token,
          'plateforme': 'ANDROID',
        },
      );
    } catch (_) {
      // Les notifications restent best-effort pour ne pas bloquer l'authentification.
    }
  }
}
