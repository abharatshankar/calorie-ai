import '../../domain/entities/dashboard_data.dart';
import 'dashboard_recent_meal_model.dart';
import 'dashboard_summary_model.dart';

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    required DashboardSummaryModel super.summary,
    required List<DashboardRecentMealModel> super.recentMeals,
  });
}
