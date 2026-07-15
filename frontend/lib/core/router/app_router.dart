import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/auth/presentation/controllers/auth_state.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/food/domain/entities/analysis_image.dart';
import '../../features/food/presentation/screens/analysis_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/history/presentation/screens/meal_detail_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/upload/presentation/screens/home_screen.dart';

final appRouterProvider = Provider<GoRouter>(
  (ref) {
    // Re-run redirects when the auth status changes WITHOUT rebuilding the
    // GoRouter. Rebuilding the router (e.g. via ref.watch) would reset it to
    // the initial location and discard the current navigation stack, so we
    // drive refreshes through a Listenable instead and read the auth status
    // inside the redirect callback.
    final authRefresh = ValueNotifier<int>(0);
    ref.listen(
      authControllerProvider.select((state) => state.status),
      (_, _) => authRefresh.value++,
    );
    ref.onDispose(authRefresh.dispose);

    return GoRouter(
      initialLocation: AppRoute.splash.path,
      refreshListenable: authRefresh,
      redirect: (context, state) {
        final status = ref.read(authControllerProvider).status;
        final location = state.uri.path;
        final isAuthRoute = location == AppRoute.login.path ||
            location == AppRoute.register.path;

        return switch (status) {
          AuthStatus.checking => location == AppRoute.splash.path
              ? null
              : AppRoute.splash.path,
          AuthStatus.unauthenticated => isAuthRoute
              ? null
              : AppRoute.login.path,
          AuthStatus.authenticated =>
            isAuthRoute || location == AppRoute.splash.path
                ? AppRoute.home.path
                : null,
        };
      },
      routes: [
        GoRoute(
          path: AppRoute.splash.path,
          name: AppRoute.splash.name,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: AppRoute.login.path,
          name: AppRoute.login.name,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: AppRoute.register.path,
          name: AppRoute.register.name,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: AppRoute.home.path,
          name: AppRoute.home.name,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: AppRoute.dashboard.path,
          name: AppRoute.dashboard.name,
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: AppRoute.analysis.path,
          name: AppRoute.analysis.name,
          builder: (context, state) {
            final image = state.extra as AnalysisImage?;
            return AnalysisScreen(image: image);
          },
        ),
        GoRoute(
          path: AppRoute.history.path,
          name: AppRoute.history.name,
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: AppRoute.historyDetail.path,
          name: AppRoute.historyDetail.name,
          builder: (context, state) {
            final mealId = state.pathParameters['id'] ?? '';
            return MealDetailScreen(mealId: mealId);
          },
        ),
        GoRoute(
          path: AppRoute.settings.path,
          name: AppRoute.settings.name,
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    );
  },
);

enum AppRoute {
  splash('/'),
  login('/login'),
  register('/register'),
  home('/home'),
  dashboard('/dashboard'),
  analysis('/analysis'),
  history('/history'),
  historyDetail('/history/:id'),
  settings('/settings');

  const AppRoute(this.path);

  final String path;

  String pathFor(String id) {
    return path.replaceFirst(':id', id);
  }
}
