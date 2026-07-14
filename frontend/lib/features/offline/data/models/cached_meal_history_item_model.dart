import 'package:hive/hive.dart';

import '../../../history/domain/entities/meal_history_item.dart';

class CachedMealHistoryItemModel {
  const CachedMealHistoryItemModel({
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
    required this.cachedAt,
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
  final DateTime cachedAt;

  MealHistoryItem toEntity() {
    return MealHistoryItem(
      id: id,
      foodName: foodName,
      imageUrl: imageUrl,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      servingSize: servingSize,
      confidence: confidence,
      nutritionSummary: nutritionSummary,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static CachedMealHistoryItemModel fromEntity(
    MealHistoryItem item, {
    required DateTime cachedAt,
  }) {
    return CachedMealHistoryItemModel(
      id: item.id,
      foodName: item.foodName,
      imageUrl: item.imageUrl,
      calories: item.calories,
      protein: item.protein,
      carbs: item.carbs,
      fat: item.fat,
      servingSize: item.servingSize,
      confidence: item.confidence,
      nutritionSummary: item.nutritionSummary,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
      cachedAt: cachedAt,
    );
  }
}

class CachedMealHistoryItemModelAdapter
    extends TypeAdapter<CachedMealHistoryItemModel> {
  @override
  final int typeId = 1;

  @override
  CachedMealHistoryItemModel read(BinaryReader reader) {
    return CachedMealHistoryItemModel(
      id: reader.readString(),
      foodName: reader.readString(),
      imageUrl: reader.read() as String?,
      calories: reader.readInt(),
      protein: reader.readDouble(),
      carbs: reader.readDouble(),
      fat: reader.readDouble(),
      servingSize: reader.read() as String?,
      confidence: reader.read() as double?,
      nutritionSummary: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
      cachedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, CachedMealHistoryItemModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.foodName)
      ..write(obj.imageUrl)
      ..writeInt(obj.calories)
      ..writeDouble(obj.protein)
      ..writeDouble(obj.carbs)
      ..writeDouble(obj.fat)
      ..write(obj.servingSize)
      ..write(obj.confidence)
      ..writeString(obj.nutritionSummary)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch)
      ..writeInt(obj.updatedAt.millisecondsSinceEpoch)
      ..writeInt(obj.cachedAt.millisecondsSinceEpoch);
  }
}
