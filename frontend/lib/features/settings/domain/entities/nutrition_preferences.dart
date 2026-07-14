class NutritionPreferences {
  const NutritionPreferences({
    required this.dailyCalorieGoal,
    required this.dailyProteinGoal,
    required this.dailyCarbsGoal,
    required this.dailyFatGoal,
    required this.waterIntakeGoalMl,
    required this.weightGoalKg,
  });

  const NutritionPreferences.defaults()
      : dailyCalorieGoal = 2000,
        dailyProteinGoal = 120,
        dailyCarbsGoal = 250,
        dailyFatGoal = 70,
        waterIntakeGoalMl = 2500,
        weightGoalKg = 70;

  final int dailyCalorieGoal;
  final double dailyProteinGoal;
  final double dailyCarbsGoal;
  final double dailyFatGoal;
  final int waterIntakeGoalMl;
  final double weightGoalKg;

  NutritionPreferences copyWith({
    int? dailyCalorieGoal,
    double? dailyProteinGoal,
    double? dailyCarbsGoal,
    double? dailyFatGoal,
    int? waterIntakeGoalMl,
    double? weightGoalKg,
  }) {
    return NutritionPreferences(
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyProteinGoal: dailyProteinGoal ?? this.dailyProteinGoal,
      dailyCarbsGoal: dailyCarbsGoal ?? this.dailyCarbsGoal,
      dailyFatGoal: dailyFatGoal ?? this.dailyFatGoal,
      waterIntakeGoalMl: waterIntakeGoalMl ?? this.waterIntakeGoalMl,
      weightGoalKg: weightGoalKg ?? this.weightGoalKg,
    );
  }
}
