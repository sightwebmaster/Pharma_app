class NotificationPreferences {
  final bool remindersEnabled;
  final bool soundEnabled;
  final bool repeatEveryMinuteUntilConfirmed;
  final bool alertCaregiverAfterThirtyMinutes;
  final String ringtoneName;

  const NotificationPreferences({
    this.remindersEnabled = true,
    this.soundEnabled = true,
    this.repeatEveryMinuteUntilConfirmed = true,
    this.alertCaregiverAfterThirtyMinutes = true,
    this.ringtoneName = 'default',
  });

  NotificationPreferences copyWith({
    bool? remindersEnabled,
    bool? soundEnabled,
    bool? repeatEveryMinuteUntilConfirmed,
    bool? alertCaregiverAfterThirtyMinutes,
    String? ringtoneName,
  }) {
    return NotificationPreferences(
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      repeatEveryMinuteUntilConfirmed:
          repeatEveryMinuteUntilConfirmed ??
          this.repeatEveryMinuteUntilConfirmed,
      alertCaregiverAfterThirtyMinutes:
          alertCaregiverAfterThirtyMinutes ??
          this.alertCaregiverAfterThirtyMinutes,
      ringtoneName: ringtoneName ?? this.ringtoneName,
    );
  }
}
