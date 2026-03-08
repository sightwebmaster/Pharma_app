class StorageKeys {
  // Token keys (stockés dans secure storage)
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';

  // User data keys (stockés dans shared preferences)
  static const String userId = 'user_id';
  static const String userEmail = 'user_email';
  static const String userRole = 'user_role';
  static const String userName = 'user_name';
  static const String isLoggedIn = 'is_logged_in';

  // App preferences
  static const String appLanguage = 'app_language';
  static const String appTheme = 'app_theme';
}
