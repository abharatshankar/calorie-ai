import 'dashboard_recent_meal.dart';
import 'dashboard_summary.dart';

class DashboardData {
  const DashboardData({
    required this.summary,
    required this.recentMeals,
  });

  final DashboardSummary summary;
  final List<DashboardRecentMeal> recentMeals;
}
