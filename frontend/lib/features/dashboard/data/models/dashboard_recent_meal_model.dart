import '../../domain/entities/dashboard_recent_meal.dart';

class DashboardRecentMealModel extends DashboardRecentMeal {
  const DashboardRecentMealModel({
    required super.id,
    required super.foodName,
    required super.calories,
    required super.createdAt,
    super.imageUrl,
  });

  factory DashboardRecentMealModel.fromJson(Map<String, dynamic> json) {
    return DashboardRecentMealModel(
      id: json['id'] as String,
      foodName: json['detected_food_name'] as String,
      imageUrl: json['image_url'] as String?,
      calories: json['calories'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
