class MealHistoryItem {
  const MealHistoryItem({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.confidence,
    required this.nutritionSummary,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
    this.servingSize,
  });

  final String id;
  final String foodName;
  final String? imageUrl;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? servingSize;
  final double? confidence;
  final String nutritionSummary;
  final DateTime createdAt;
  final DateTime updatedAt;

  int? get confidencePercent {
    final value = confidence;
    if (value == null) {
      return null;
    }
    return (value * 100).round().clamp(0, 100);
  }
}
