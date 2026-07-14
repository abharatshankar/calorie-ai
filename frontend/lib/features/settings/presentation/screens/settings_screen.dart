import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/entities/app_theme_preference.dart';
import '../../domain/entities/notification_preferences.dart';
import '../../domain/entities/nutrition_preferences.dart';
import '../../domain/entities/settings_failure.dart';
import '../controllers/settings_controller.dart';
import '../controllers/settings_state.dart';
import '../validators/settings_validators.dart';
import '../widgets/account_settings_card.dart';
import '../widgets/notifications_settings_card.dart';
import '../widgets/preferences_settings_card.dart';
import '../widgets/profile_settings_card.dart';
import '../widgets/theme_settings_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsValue = ref.watch(settingsControllerProvider);

    ref.listen<AsyncValue<SettingsState>>(settingsControllerProvider, (
      previous,
      next,
    ) {
      final state = next.value;
      final failure = state?.failure;
      if (failure?.type == SettingsFailureType.unauthorized) {
        ref.read(authControllerProvider.notifier).logout();
        return;
      }

      final message = failure?.message ?? state?.successMessage;
      if (message == null) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      ref.read(settingsControllerProvider.notifier).clearMessages();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            onPressed: settingsValue.isLoading
                ? null
                : () => ref.read(settingsControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: settingsValue.when(
        data: (state) => _SettingsContent(
          state: state,
          onEditProfile: () => _editProfile(context, ref, state),
          onEditPreferences: () => _editPreferences(context, ref, state),
          onThemeChanged: (preference) => ref
              .read(settingsControllerProvider.notifier)
              .updateThemePreference(preference),
          onNotificationsChanged: (preferences) => ref
              .read(settingsControllerProvider.notifier)
              .updateNotificationPreferences(preferences),
          onRefresh: () =>
              ref.read(settingsControllerProvider.notifier).refresh(),
          onClearCache: () => _clearCache(context, ref),
          onDeleteAccount: () => _deleteAccount(context, ref),
          onLogout: () => ref.read(authControllerProvider.notifier).logout(),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _SettingsErrorView(
          message: error is SettingsFailure
              ? error.message
              : 'Could not load settings. Please try again.',
          onRetry: () => ref.read(settingsControllerProvider.notifier).refresh(),
        ),
      ),
    );
  }

  Future<void> _editProfile(
    BuildContext context,
    WidgetRef ref,
    SettingsState state,
  ) async {
    final controller = TextEditingController(
      text: state.data.profile.fullName ?? '',
    );
    final formKey = GlobalKey<FormState>();

    final fullName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(labelText: 'Name'),
              validator: SettingsValidators.requiredName,
              onFieldSubmitted: (_) {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(controller.text.trim());
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState?.validate() ?? false) {
                  Navigator.of(context).pop(controller.text.trim());
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    controller.dispose();

    if (fullName == null) {
      return;
    }

    await ref.read(settingsControllerProvider.notifier).updateProfile(fullName);
  }

  Future<void> _editPreferences(
    BuildContext context,
    WidgetRef ref,
    SettingsState state,
  ) async {
    final preferences = state.data.nutritionPreferences;
    final formKey = GlobalKey<FormState>();
    final calorieController = TextEditingController(
      text: preferences.dailyCalorieGoal.toString(),
    );
    final proteinController = TextEditingController(
      text: preferences.dailyProteinGoal.toStringAsFixed(0),
    );
    final carbsController = TextEditingController(
      text: preferences.dailyCarbsGoal.toStringAsFixed(0),
    );
    final fatController = TextEditingController(
      text: preferences.dailyFatGoal.toStringAsFixed(0),
    );
    final waterController = TextEditingController(
      text: preferences.waterIntakeGoalMl.toString(),
    );
    final weightController = TextEditingController(
      text: preferences.weightGoalKg.toStringAsFixed(1),
    );

    final updatedPreferences = await showDialog<NutritionPreferences>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nutrition Preferences'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: calorieController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Daily calorie goal',
                      suffixText: 'kcal',
                    ),
                    validator: (value) => SettingsValidators.integerRange(
                      value,
                      label: 'Daily calorie goal',
                      min: 500,
                      max: 10000,
                    ),
                  ),
                  TextFormField(
                    controller: proteinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Daily protein goal',
                      suffixText: 'g',
                    ),
                    validator: (value) => SettingsValidators.decimalRange(
                      value,
                      label: 'Daily protein goal',
                      min: 1,
                      max: 500,
                    ),
                  ),
                  TextFormField(
                    controller: carbsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Daily carbs goal',
                      suffixText: 'g',
                    ),
                    validator: (value) => SettingsValidators.decimalRange(
                      value,
                      label: 'Daily carbs goal',
                      min: 1,
                      max: 1000,
                    ),
                  ),
                  TextFormField(
                    controller: fatController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Daily fat goal',
                      suffixText: 'g',
                    ),
                    validator: (value) => SettingsValidators.decimalRange(
                      value,
                      label: 'Daily fat goal',
                      min: 1,
                      max: 500,
                    ),
                  ),
                  TextFormField(
                    controller: waterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Water intake goal',
                      suffixText: 'ml',
                    ),
                    validator: (value) => SettingsValidators.integerRange(
                      value,
                      label: 'Water intake goal',
                      min: 250,
                      max: 10000,
                    ),
                  ),
                  TextFormField(
                    controller: weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Weight goal',
                      suffixText: 'kg',
                    ),
                    validator: (value) => SettingsValidators.decimalRange(
                      value,
                      label: 'Weight goal',
                      min: 1,
                      max: 500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!(formKey.currentState?.validate() ?? false)) {
                  return;
                }

                Navigator.of(context).pop(
                  NutritionPreferences(
                    dailyCalorieGoal:
                        int.parse(calorieController.text.trim()),
                    dailyProteinGoal:
                        double.parse(proteinController.text.trim()),
                    dailyCarbsGoal: double.parse(carbsController.text.trim()),
                    dailyFatGoal: double.parse(fatController.text.trim()),
                    waterIntakeGoalMl:
                        int.parse(waterController.text.trim()),
                    weightGoalKg:
                        double.parse(weightController.text.trim()),
                  ),
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    calorieController.dispose();
    proteinController.dispose();
    carbsController.dispose();
    fatController.dispose();
    waterController.dispose();
    weightController.dispose();

    if (updatedPreferences == null) {
      return;
    }

    await ref
        .read(settingsControllerProvider.notifier)
        .updateNutritionPreferences(updatedPreferences);
  }

  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: 'Clear Cache',
      message: 'Temporary images and cached files will be removed.',
      confirmLabel: 'Clear',
    );
    if (!confirmed) {
      return;
    }

    await ref.read(settingsControllerProvider.notifier).clearCache();
  }

  Future<void> _deleteAccount(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirm(
      context,
      title: 'Delete Account',
      message:
          'This action is permanent. Your account and nutrition data will be deleted if the backend supports account deletion.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) {
      return;
    }

    final deleted =
        await ref.read(settingsControllerProvider.notifier).deleteAccount();
    if (deleted) {
      ref.read(authControllerProvider.notifier).logout();
    }
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool isDestructive = false,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: isDestructive
                    ? FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor:
                            Theme.of(context).colorScheme.onError,
                      )
                    : null,
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _SettingsContent extends StatelessWidget {
  const _SettingsContent({
    required this.state,
    required this.onEditProfile,
    required this.onEditPreferences,
    required this.onThemeChanged,
    required this.onNotificationsChanged,
    required this.onRefresh,
    required this.onClearCache,
    required this.onDeleteAccount,
    required this.onLogout,
  });

  final SettingsState state;
  final VoidCallback onEditProfile;
  final VoidCallback onEditPreferences;
  final ValueChanged<AppThemePreference> onThemeChanged;
  final ValueChanged<NotificationPreferences> onNotificationsChanged;
  final Future<void> Function() onRefresh;
  final VoidCallback onClearCache;
  final VoidCallback onDeleteAccount;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final data = state.data;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              ProfileSettingsCard(
                profile: data.profile,
                profileEditingAvailable: data.profileEditingAvailable,
                onEditProfile: onEditProfile,
                onLogout: onLogout,
              ),
              const SizedBox(height: 12),
              PreferencesSettingsCard(
                preferences: data.nutritionPreferences,
                remotePreferencesAvailable: data.remotePreferencesAvailable,
                onEdit: onEditPreferences,
              ),
              const SizedBox(height: 12),
              ThemeSettingsCard(
                preference: data.themePreference,
                onChanged: onThemeChanged,
              ),
              const SizedBox(height: 12),
              NotificationsSettingsCard(
                preferences: data.notificationPreferences,
                remoteNotificationsAvailable:
                    data.remoteNotificationsAvailable,
                onChanged: onNotificationsChanged,
              ),
              const SizedBox(height: 12),
              AccountSettingsCard(
                appVersion: data.appVersion,
                accountDeletionAvailable: data.accountDeletionAvailable,
                onClearCache: onClearCache,
                onDeleteAccount: onDeleteAccount,
                onLogout: onLogout,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
        if (state.isSaving)
          Positioned.fill(
            child: ColoredBox(
              color: Theme.of(context)
                  .colorScheme
                  .surface
                  .withValues(alpha: 0.42),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class _SettingsErrorView extends StatelessWidget {
  const _SettingsErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
