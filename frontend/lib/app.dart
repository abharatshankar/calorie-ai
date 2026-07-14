import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/environment_config.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/offline/presentation/controllers/sync_controller.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';

class CalorieAiApp extends ConsumerWidget {
  const CalorieAiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final environmentConfig = ref.watch(environmentConfigProvider);
    final router = ref.watch(appRouterProvider);
    final settingsValue = ref.watch(settingsControllerProvider);
    ref.watch(syncControllerProvider);
    final themeMode = settingsValue.value?.data.themePreference.themeMode;

    return MaterialApp.router(
      title: environmentConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode ?? ThemeMode.system,
      routerConfig: router,
    );
  }
}
