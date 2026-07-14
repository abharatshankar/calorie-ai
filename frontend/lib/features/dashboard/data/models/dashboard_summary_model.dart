import '../../domain/entities/dashboard_summary.dart';

class DashboardSummaryModel extends DashboardSummary {
  const DashboardSummaryModel({
    required super.todayCalories,
    required super.weeklyCalories,
    required super.monthlyCalories,
    required super.averageCalories,
    required super.proteinTotal,
    required super.carbsTotal,
    required super.fatTotal,
    required super.totalMeals,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryModel(
      todayCalories: json['today_calories'] as int,
      weeklyCalories: json['weekly_calories'] as int,
      monthlyCalories: json['monthly_calories'] as int,
      averageCalories: (json['average_calories'] as num).toDouble(),
      proteinTotal: (json['protein_total'] as num).toDouble(),
      carbsTotal: (json['carbs_total'] as num).toDouble(),
      fatTotal: (json['fat_total'] as num).toDouble(),
      totalMeals: json['total_meals'] as int,
    );
  }
}
