import 'app_theme_preference.dart';
import 'notification_preferences.dart';
import 'nutrition_preferences.dart';
import 'user_profile.dart';

class SettingsData {
  const SettingsData({
    required this.profile,
    required this.nutritionPreferences,
    required this.notificationPreferences,
    required this.themePreference,
    required this.appVersion,
    required this.remotePreferencesAvailable,
    required this.remoteNotificationsAvailable,
    required this.accountDeletionAvailable,
    required this.profileEditingAvailable,
  });

  final UserProfile profile;
  final NutritionPreferences nutritionPreferences;
  final NotificationPreferences notificationPreferences;
  final AppThemePreference themePreference;
  final String appVersion;
  final bool remotePreferencesAvailable;
  final bool remoteNotificationsAvailable;
  final bool accountDeletionAvailable;
  final bool profileEditingAvailable;

  SettingsData copyWith({
    UserProfile? profile,
    NutritionPreferences? nutritionPreferences,
    NotificationPreferences? notificationPreferences,
    AppThemePreference? themePreference,
    String? appVersion,
    bool? remotePreferencesAvailable,
    bool? remoteNotificationsAvailable,
    bool? accountDeletionAvailable,
    bool? profileEditingAvailable,
  }) {
    return SettingsData(
      profile: profile ?? this.profile,
      nutritionPreferences:
          nutritionPreferences ?? this.nutritionPreferences,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      themePreference: themePreference ?? this.themePreference,
      appVersion: appVersion ?? this.appVersion,
      remotePreferencesAvailable:
          remotePreferencesAvailable ?? this.remotePreferencesAvailable,
      remoteNotificationsAvailable:
          remoteNotificationsAvailable ?? this.remoteNotificationsAvailable,
      accountDeletionAvailable:
          accountDeletionAvailable ?? this.accountDeletionAvailable,
      profileEditingAvailable:
          profileEditingAvailable ?? this.profileEditingAvailable,
    );
  }
}
