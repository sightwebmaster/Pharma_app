import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/notification_preferences.dart';

class NotificationPreferencesService {
  static const _remindersEnabledKey = 'notif_reminders_enabled';
  static const _soundEnabledKey = 'notif_sound_enabled';
  static const _repeatEveryMinuteKey = 'notif_repeat_every_minute';
  static const _alertCaregiverAfterThirtyMinutesKey =
      'notif_alert_caregiver_after_thirty_minutes';
  static const _ringtoneNameKey = 'notif_ringtone_name';

  Future<NotificationPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationPreferences(
      remindersEnabled: prefs.getBool(_remindersEnabledKey) ?? true,
      soundEnabled: prefs.getBool(_soundEnabledKey) ?? true,
      repeatEveryMinuteUntilConfirmed:
          prefs.getBool(_repeatEveryMinuteKey) ?? true,
      alertCaregiverAfterThirtyMinutes:
          prefs.getBool(_alertCaregiverAfterThirtyMinutesKey) ?? true,
      ringtoneName: prefs.getString(_ringtoneNameKey) ?? 'default',
    );
  }

  Future<void> save(NotificationPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_remindersEnabledKey, preferences.remindersEnabled);
    await prefs.setBool(_soundEnabledKey, preferences.soundEnabled);
    await prefs.setBool(
      _repeatEveryMinuteKey,
      preferences.repeatEveryMinuteUntilConfirmed,
    );
    await prefs.setBool(
      _alertCaregiverAfterThirtyMinutesKey,
      preferences.alertCaregiverAfterThirtyMinutes,
    );
    await prefs.setString(_ringtoneNameKey, preferences.ringtoneName);
  }
}
