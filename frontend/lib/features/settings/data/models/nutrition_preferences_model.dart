import '../../domain/entities/nutrition_preferences.dart';

class NutritionPreferencesModel extends NutritionPreferences {
  const NutritionPreferencesModel({
    required super.dailyCalorieGoal,
    required super.dailyProteinGoal,
    required super.dailyCarbsGoal,
    required super.dailyFatGoal,
    required super.waterIntakeGoalMl,
    required super.weightGoalKg,
  });

  factory NutritionPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NutritionPreferencesModel(
      dailyCalorieGoal: json['daily_calorie_goal'] as int,
      dailyProteinGoal: (json['daily_protein_goal'] as num).toDouble(),
      dailyCarbsGoal: (json['daily_carbs_goal'] as num).toDouble(),
      dailyFatGoal: (json['daily_fat_goal'] as num).toDouble(),
      waterIntakeGoalMl: json['water_intake_goal_ml'] as int,
      weightGoalKg: (json['weight_goal_kg'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'daily_calorie_goal': dailyCalorieGoal,
      'daily_protein_goal': dailyProteinGoal,
      'daily_carbs_goal': dailyCarbsGoal,
      'daily_fat_goal': dailyFatGoal,
      'water_intake_goal_ml': waterIntakeGoalMl,
      'weight_goal_kg': weightGoalKg,
    };
  }

  static NutritionPreferencesModel fromEntity(
    NutritionPreferences preferences,
  ) {
    return NutritionPreferencesModel(
      dailyCalorieGoal: preferences.dailyCalorieGoal,
      dailyProteinGoal: preferences.dailyProteinGoal,
      dailyCarbsGoal: preferences.dailyCarbsGoal,
      dailyFatGoal: preferences.dailyFatGoal,
      waterIntakeGoalMl: preferences.waterIntakeGoalMl,
      weightGoalKg: preferences.weightGoalKg,
    );
  }
}
