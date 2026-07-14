import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/entities/nutrition_preferences.dart';
import '../../domain/entities/settings_failure.dart';
import '../../domain/usecases/clear_cache_use_case.dart';
import '../../domain/usecases/delete_account_use_case.dart';
import '../../domain/usecases/get_settings_use_case.dart';
import '../../domain/usecases/update_notification_preferences_use_case.dart';
import '../../domain/usecases/update_nutrition_preferences_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../../domain/usecases/update_theme_preference_use_case.dart';
import 'settings_state.dart';

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, SettingsState>(
  SettingsController.new,
);

class SettingsController extends AsyncNotifier<SettingsState> {
  late final GetSettingsUseCase _getSettingsUseCase;
  late final UpdateNutritionPreferencesUseCase
      _updateNutritionPreferencesUseCase;
  late final UpdateThemePreferenceUseCase _updateThemePreferenceUseCase;
  late final UpdateNotificationPreferencesUseCase
      _updateNotificationPreferencesUseCase;
  late final UpdateProfileUseCase _updateProfileUseCase;
  late final ClearCacheUseCase _clearCacheUseCase;
  late final DeleteAccountUseCase _deleteAccountUseCase;

  @override
  Future<SettingsState> build() async {
    final repository = ref.watch(settingsRepositoryProvider);
    _getSettingsUseCase = GetSettingsUseCase(repository);
    _updateNutritionPreferencesUseCase =
        UpdateNutritionPreferencesUseCase(repository);
    _updateThemePreferenceUseCase = UpdateThemePreferenceUseCase(repository);
    _updateNotificationPreferencesUseCase =
        UpdateNotificationPreferencesUseCase(repository);
    _updateProfileUseCase = UpdateProfileUseCase(repository);
    _clearCacheUseCase = ClearCacheUseCase(repository);
    _deleteAccountUseCase = DeleteAccountUseCase(repository);

    final data = await _getSettingsUseCase();
    return SettingsState(data: data);
  }

  Future<void> refresh() async {
    state = const AsyncLoading<SettingsState>();
    state = await AsyncValue.guard(build);
  }

  Future<void> updateThemePreference(AppThemePreference preference) async {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }

    state = AsyncData(
      current.copyWith(isSaving: true, clearFailure: true, clearMessage: true),
    );

    try {
      final updatedPreference = await _updateThemePreferenceUseCase(preference);
      state = AsyncData(
        current.copyWith(
          data: current.data.copyWith(themePreference: updatedPreference),
          isSaving: false,
          successMessage: 'Theme updated.',
          clearFailure: true,
        ),
      );
    } on SettingsFailure catch (failure) {
      state = AsyncData(current.copyWith(isSaving: false, failure: failure));
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          failure: const SettingsFailure(
            type: SettingsFailureType.unknown,
            message: 'Could not update theme. Please try again.',
          ),
        ),
      );
    }
  }

  Future<void> updateNutritionPreferences(
    NutritionPreferences preferences,
  ) async {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }

    final validationFailure = _validateNutritionPreferences(preferences);
    if (validationFailure != null) {
      state = AsyncData(current.copyWith(failure: validationFailure));
      return;
    }

    state = AsyncData(
      current.copyWith(isSaving: true, clearFailure: true, clearMessage: true),
    );

    try {
      final updatedPreferences =
          await _updateNutritionPreferencesUseCase(preferences);
      state = AsyncData(
        current.copyWith(
          data: current.data.copyWith(
            nutritionPreferences: updatedPreferences,
          ),
          isSaving: false,
          successMessage: 'Nutrition preferences updated.',
          clearFailure: true,
        ),
      );
    } on SettingsFailure catch (failure) {
      state = AsyncData(current.copyWith(isSaving: false, failure: failure));
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          failure: const SettingsFailure(
            type: SettingsFailureType.unknown,
            message: 'Could not update nutrition preferences.',
          ),
        ),
      );
    }
  }

  Future<void> updateNotificationPreferences(
    NotificationPreferences preferences,
  ) async {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }

    state = AsyncData(
      current.copyWith(isSaving: true, clearFailure: true, clearMessage: true),
    );

    try {
      final updatedPreferences =
          await _updateNotificationPreferencesUseCase(preferences);
      state = AsyncData(
        current.copyWith(
          data: current.data.copyWith(
            notificationPreferences: updatedPreferences,
          ),
          isSaving: false,
          successMessage: current.data.remoteNotificationsAvailable
              ? 'Notification preferences updated.'
              : 'Notification preferences saved on this device.',
          clearFailure: true,
        ),
      );
    } on SettingsFailure catch (failure) {
      state = AsyncData(current.copyWith(isSaving: false, failure: failure));
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          failure: const SettingsFailure(
            type: SettingsFailureType.unknown,
            message: 'Could not update notification preferences.',
          ),
        ),
      );
    }
  }

  Future<void> updateProfile(String fullName) async {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }

    final trimmedName = fullName.trim();
    if (trimmedName.isEmpty || trimmedName.length > 100) {
      state = AsyncData(
        current.copyWith(
          failure: const SettingsFailure(
            type: SettingsFailureType.validation,
            message: 'Name must be between 1 and 100 characters.',
          ),
        ),
      );
      return;
    }

    state = AsyncData(
      current.copyWith(isSaving: true, clearFailure: true, clearMessage: true),
    );

    try {
      final profile = await _updateProfileUseCase(fullName: trimmedName);
      state = AsyncData(
        current.copyWith(
          data: current.data.copyWith(profile: profile),
          isSaving: false,
          successMessage: 'Profile updated.',
          clearFailure: true,
        ),
      );
    } on SettingsFailure catch (failure) {
      state = AsyncData(current.copyWith(isSaving: false, failure: failure));
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          failure: const SettingsFailure(
            type: SettingsFailureType.unknown,
            message: 'Could not update profile.',
          ),
        ),
      );
    }
  }

  Future<void> clearCache() async {
    final current = state.value;
    if (current == null || current.isSaving) {
      return;
    }

    state = AsyncData(
      current.copyWith(isSaving: true, clearFailure: true, clearMessage: true),
    );

    try {
      await _clearCacheUseCase();
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          successMessage: 'Cache cleared.',
          clearFailure: true,
        ),
      );
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          failure: const SettingsFailure(
            type: SettingsFailureType.unknown,
            message: 'Could not clear cache.',
          ),
        ),
      );
    }
  }

  Future<bool> deleteAccount() async {
    final current = state.value;
    if (current == null || current.isSaving) {
      return false;
    }

    state = AsyncData(
      current.copyWith(isSaving: true, clearFailure: true, clearMessage: true),
    );

    try {
      await _deleteAccountUseCase();
      state = AsyncData(current.copyWith(isSaving: false, clearFailure: true));
      return true;
    } on SettingsFailure catch (failure) {
      state = AsyncData(current.copyWith(isSaving: false, failure: failure));
      return false;
    } catch (_) {
      state = AsyncData(
        current.copyWith(
          isSaving: false,
          failure: const SettingsFailure(
            type: SettingsFailureType.unknown,
            message: 'Could not delete account.',
          ),
        ),
      );
      return false;
    }
  }

  void clearMessages() {
    final current = state.value;
    if (current == null) {
      return;
    }
    state = AsyncData(
      current.copyWith(clearFailure: true, clearMessage: true),
    );
  }

  SettingsFailure? _validateNutritionPreferences(
    NutritionPreferences preferences,
  ) {
    if (preferences.dailyCalorieGoal < 500 ||
        preferences.dailyCalorieGoal > 10000) {
      return const SettingsFailure(
        type: SettingsFailureType.validation,
        message: 'Daily calorie goal must be between 500 and 10000 kcal.',
      );
    }
    if (preferences.dailyProteinGoal <= 0 ||
        preferences.dailyProteinGoal > 500) {
      return const SettingsFailure(
        type: SettingsFailureType.validation,
        message: 'Daily protein goal must be between 1 and 500 g.',
      );
    }
    if (preferences.dailyCarbsGoal <= 0 || preferences.dailyCarbsGoal > 1000) {
      return const SettingsFailure(
        type: SettingsFailureType.validation,
        message: 'Daily carbs goal must be between 1 and 1000 g.',
      );
    }
    if (preferences.dailyFatGoal <= 0 || preferences.dailyFatGoal > 500) {
      return const SettingsFailure(
        type: SettingsFailureType.validation,
        message: 'Daily fat goal must be between 1 and 500 g.',
      );
    }
    if (preferences.waterIntakeGoalMl < 250 ||
        preferences.waterIntakeGoalMl > 10000) {
      return const SettingsFailure(
        type: SettingsFailureType.validation,
        message: 'Water goal must be between 250 and 10000 ml.',
      );
    }
    if (preferences.weightGoalKg <= 0 || preferences.weightGoalKg > 500) {
      return const SettingsFailure(
        type: SettingsFailureType.validation,
        message: 'Weight goal must be between 1 and 500 kg.',
      );
    }
    return null;
  }
}
