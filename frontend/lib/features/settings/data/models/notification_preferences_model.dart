import '../../domain/entities/notification_preferences.dart';

class NotificationPreferencesModel extends NotificationPreferences {
  const NotificationPreferencesModel({
    required super.mealRemindersEnabled,
    required super.waterRemindersEnabled,
    required super.weeklySummaryEnabled,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      mealRemindersEnabled: json['meal_reminders_enabled'] as bool? ?? false,
      waterRemindersEnabled: json['water_reminders_enabled'] as bool? ?? false,
      weeklySummaryEnabled: json['weekly_summary_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_reminders_enabled': mealRemindersEnabled,
      'water_reminders_enabled': waterRemindersEnabled,
      'weekly_summary_enabled': weeklySummaryEnabled,
    };
  }

  static NotificationPreferencesModel fromEntity(
    NotificationPreferences preferences,
  ) {
    return NotificationPreferencesModel(
      mealRemindersEnabled: preferences.mealRemindersEnabled,
      waterRemindersEnabled: preferences.waterRemindersEnabled,
      weeklySummaryEnabled: preferences.weeklySummaryEnabled,
    );
  }
}
