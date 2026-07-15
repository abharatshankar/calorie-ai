import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../offline/presentation/widgets/offline_status_banner.dart';
import '../../domain/entities/dashboard_data.dart';
import '../../domain/entities/dashboard_failure.dart';
import '../controllers/dashboard_controller.dart';
import '../widgets/calorie_summary_card.dart';
import '../widgets/goal_progress_card.dart';
import '../widgets/macro_chart_card.dart';
import '../widgets/placeholder_metric_card.dart';
import '../widgets/recent_meals_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  static const _dailyCalorieGoal = 2000;
  static const _weeklyCalorieGoal = 14000;
  static const _monthlyCalorieGoal = 60000;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardValue = ref.watch(dashboardControllerProvider);

    ref.listen<AsyncValue<DashboardData?>>(dashboardControllerProvider, (
      previous,
      next,
    ) {
      final error = next.error;
      if (error is DashboardFailure &&
          error.type == DashboardFailureType.unauthorized) {
        ref.read(authControllerProvider.notifier).logout();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            onPressed: dashboardValue.isLoading
                ? null
                : () => ref.read(dashboardControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: dashboardValue.when(
        data: (data) {
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () =>
                ref.read(dashboardControllerProvider.notifier).refresh(),
            child: _DashboardContent(data: data),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _DashboardErrorView(
          message: error is DashboardFailure
              ? error.message
              : 'Could not load dashboard. Please try again.',
          onRetry: () => ref.read(dashboardControllerProvider.notifier).refresh(),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.data,
  });

  final DashboardData data;

  @override
  Widget build(BuildContext context) {
    final summary = data.summary;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const OfflineStatusBanner(),
        const SizedBox(height: 12),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.1,
          ),
          children: [
            CalorieSummaryCard(
              title: 'Daily Calories',
              calories: summary.todayCalories,
              icon: Icons.today_outlined,
            ),
            CalorieSummaryCard(
              title: 'Weekly Calories',
              calories: summary.weeklyCalories,
              icon: Icons.calendar_view_week_outlined,
            ),
            CalorieSummaryCard(
              title: 'Monthly Calories',
              calories: summary.monthlyCalories,
              icon: Icons.calendar_month_outlined,
            ),
            CalorieSummaryCard(
              title: 'Avg per Meal',
              calories: summary.averageCalories.round(),
              icon: Icons.restaurant_outlined,
            ),
          ],
        ),
        const SizedBox(height: 12),
        GoalProgressCard(
          title: 'Daily Goal Progress',
          current: summary.todayCalories,
          goal: DashboardScreen._dailyCalorieGoal,
          unit: 'kcal',
        ),
        const SizedBox(height: 12),
        GoalProgressCard(
          title: 'Weekly Goal Progress',
          current: summary.weeklyCalories,
          goal: DashboardScreen._weeklyCalorieGoal,
          unit: 'kcal',
        ),
        const SizedBox(height: 12),
        GoalProgressCard(
          title: 'Monthly Goal Progress',
          current: summary.monthlyCalories,
          goal: DashboardScreen._monthlyCalorieGoal,
          unit: 'kcal',
        ),
        const SizedBox(height: 12),
        MacroChartCard(
          protein: summary.proteinTotal,
          carbs: summary.carbsTotal,
          fat: summary.fatTotal,
        ),
        const SizedBox(height: 12),
        PlaceholderMetricCard(
          title: 'Water Intake',
          message: 'Water tracking will be available in a future milestone.',
          icon: Icons.water_drop_outlined,
        ),
        const SizedBox(height: 12),
        PlaceholderMetricCard(
          title: 'Weight',
          message: 'Weight tracking will be available in a future milestone.',
          icon: Icons.monitor_weight_outlined,
        ),
        const SizedBox(height: 12),
        RecentMealsCard(
          meals: data.recentMeals,
          onViewAll: () => context.push(AppRoute.history.path),
          onTapMeal: (id) => context.push(AppRoute.historyDetail.pathFor(id)),
        ),
      ],
    );
  }
}

class _DashboardErrorView extends StatelessWidget {
  const _DashboardErrorView({
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
