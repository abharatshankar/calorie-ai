import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/services/secure_storage_service.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../models/notification_preferences_model.dart';

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>(
  (ref) => SettingsLocalDataSource(ref.watch(secureStorageServiceProvider)),
);

class SettingsLocalDataSource {
  const SettingsLocalDataSource(this._storage);

  static const _themePreferenceKey = 'settings.theme_preference';
  static const _mealRemindersKey = 'settings.notifications.meal_reminders';
  static const _waterRemindersKey = 'settings.notifications.water_reminders';
  static const _weeklySummaryKey = 'settings.notifications.weekly_summary';

  final SecureStorageService _storage;

  Future<AppThemePreference> readThemePreference() async {
    final value = await _storage.read(_themePreferenceKey);
    return AppThemePreference.fromStorageValue(value);
  }

  Future<void> saveThemePreference(AppThemePreference preference) {
    return _storage.write(
      key: _themePreferenceKey,
      value: preference.storageValue,
    );
  }

  Future<NotificationPreferencesModel> readNotificationPreferences() async {
    final mealReminders = await _storage.read(_mealRemindersKey);
    final waterReminders = await _storage.read(_waterRemindersKey);
    final weeklySummary = await _storage.read(_weeklySummaryKey);

    return NotificationPreferencesModel(
      mealRemindersEnabled: _readBool(mealReminders, defaultValue: false),
      waterRemindersEnabled: _readBool(waterReminders, defaultValue: false),
      weeklySummaryEnabled: _readBool(weeklySummary, defaultValue: true),
    );
  }

  Future<void> saveNotificationPreferences(
    NotificationPreferencesModel preferences,
  ) async {
    await Future.wait([
      _storage.write(
        key: _mealRemindersKey,
        value: preferences.mealRemindersEnabled.toString(),
      ),
      _storage.write(
        key: _waterRemindersKey,
        value: preferences.waterRemindersEnabled.toString(),
      ),
      _storage.write(
        key: _weeklySummaryKey,
        value: preferences.weeklySummaryEnabled.toString(),
      ),
    ]);
  }

  Future<void> clearCache() async {
    final temporaryDirectory = await getTemporaryDirectory();
    await _deleteDirectoryContents(temporaryDirectory);
  }

  Future<void> _deleteDirectoryContents(Directory directory) async {
    if (!await directory.exists()) {
      return;
    }

    await for (final entity in directory.list()) {
      try {
        await entity.delete(recursive: true);
      } on FileSystemException {
        // Cache cleanup should be best-effort; inaccessible files are skipped.
      }
    }
  }

  bool _readBool(String? value, {required bool defaultValue}) {
    return switch (value) {
      'true' => true,
      'false' => false,
      _ => defaultValue,
    };
  }
}
