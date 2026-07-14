class NotificationPreferences {
  const NotificationPreferences({
    required this.mealRemindersEnabled,
    required this.waterRemindersEnabled,
    required this.weeklySummaryEnabled,
  });

  const NotificationPreferences.defaults()
      : mealRemindersEnabled = false,
        waterRemindersEnabled = false,
        weeklySummaryEnabled = true;

  final bool mealRemindersEnabled;
  final bool waterRemindersEnabled;
  final bool weeklySummaryEnabled;

  NotificationPreferences copyWith({
    bool? mealRemindersEnabled,
    bool? waterRemindersEnabled,
    bool? weeklySummaryEnabled,
  }) {
    return NotificationPreferences(
      mealRemindersEnabled:
          mealRemindersEnabled ?? this.mealRemindersEnabled,
      waterRemindersEnabled:
          waterRemindersEnabled ?? this.waterRemindersEnabled,
      weeklySummaryEnabled:
          weeklySummaryEnabled ?? this.weeklySummaryEnabled,
    );
  }
}
