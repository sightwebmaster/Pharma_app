import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:typed_data';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService _instance =
      LocalNotificationService._();

  factory LocalNotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _timezoneReady = false;

  // Android notification channels are sticky once created.
  // Use a dedicated alarm channel id so existing silent channels
  // from previous builds do not keep overriding sound/vibration.
  static const String _channelId = 'pharmacare_medication_alarm_v2';
  static const String _channelName = 'PharmaCare medication alarm';
  static const String _channelDescription =
      'Medication reminders and adherence alerts';

  Future<void> init() async {
    if (kIsWeb) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const settings = InitializationSettings(android: androidSettings);

    _ensureTimezones();
    await _plugin.initialize(settings);
    await _requestPermissions();
    await _requestExactAlarmPermission();
  }

  Future<void> showDoseReminder({
    required int id,
    required String title,
    required String body,
    required bool playSound,
  }) async {
    if (kIsWeb) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1200, 800, 1200]),
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      autoCancel: false,
      ongoing: true,
      playSound: playSound,
      ticker: 'PharmaCare',
    );

    await _plugin.show(
      id,
      title,
      body,
      NotificationDetails(android: androidDetails),
    );
  }

  Future<void> scheduleExactDoseReminder({
    required int id,
    required DateTime scheduledAt,
    required String title,
    required String body,
    required bool playSound,
  }) async {
    if (kIsWeb) {
      return;
    }

    final scheduleTime = _toTzDateTime(scheduledAt);
    if (scheduleTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 1200, 800, 1200]),
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      autoCancel: false,
      ongoing: true,
      playSound: playSound,
      ticker: 'PharmaCare',
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduleTime,
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelDoseReminder(int id) async {
    if (kIsWeb) {
      return;
    }
    await _plugin.cancel(id);
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _requestExactAlarmPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestExactAlarmsPermission();
  }

  void _ensureTimezones() {
    if (_timezoneReady) {
      return;
    }
    tz.initializeTimeZones();
    _timezoneReady = true;
  }

  tz.TZDateTime _toTzDateTime(DateTime value) {
    _ensureTimezones();
    final localValue = value.isUtc ? value.toLocal() : value;
    return tz.TZDateTime.from(localValue, tz.local);
  }
}
