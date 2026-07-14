import '../entities/app_theme_preference.dart';
import '../entities/notification_preferences.dart';
import '../entities/nutrition_preferences.dart';
import '../entities/settings_data.dart';
import '../entities/user_profile.dart';

abstract interface class SettingsRepository {
  Future<SettingsData> getSettings();

  Future<NutritionPreferences> updateNutritionPreferences(
    NutritionPreferences preferences,
  );

  Future<AppThemePreference> updateThemePreference(
    AppThemePreference preference,
  );

  Future<NotificationPreferences> updateNotificationPreferences(
    NotificationPreferences preferences,
  );

  Future<UserProfile> updateProfile({
    required String fullName,
  });

  Future<void> clearCache();

  Future<void> deleteAccount();
}
