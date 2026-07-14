class DashboardSummary {
  const DashboardSummary({
    required this.todayCalories,
    required this.weeklyCalories,
    required this.monthlyCalories,
    required this.averageCalories,
    required this.proteinTotal,
    required this.carbsTotal,
    required this.fatTotal,
    required this.totalMeals,
  });

  final int todayCalories;
  final int weeklyCalories;
  final int monthlyCalories;
  final double averageCalories;
  final double proteinTotal;
  final double carbsTotal;
  final double fatTotal;
  final int totalMeals;

  double get macroTotal => proteinTotal + carbsTotal + fatTotal;
}
