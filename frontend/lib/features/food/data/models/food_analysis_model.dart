import '../../domain/entities/food_analysis.dart';

class FoodAnalysisModel extends FoodAnalysis {
  const FoodAnalysisModel({
    required super.id,
    required super.foodName,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
    required super.confidence,
    required super.nutritionSummary,
    required super.createdAt,
    required super.updatedAt,
    super.imageUrl,
    super.servingSize,
  });

  factory FoodAnalysisModel.fromJson(Map<String, dynamic> json) {
    return FoodAnalysisModel(
      id: json['id'] as String,
      foodName: json['detected_food_name'] as String,
      imageUrl: json['image_url'] as String?,
      calories: json['calories'] as int,
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      servingSize: json['serving_size'] as String?,
      confidence: (json['confidence'] as num?)?.toDouble(),
      nutritionSummary: json['nutrition_summary'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
