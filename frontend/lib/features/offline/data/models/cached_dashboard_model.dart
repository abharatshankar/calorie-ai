import 'package:hive/hive.dart';

import '../../../dashboard/data/models/dashboard_data_model.dart';
import '../../../dashboard/data/models/dashboard_recent_meal_model.dart';
import '../../../dashboard/data/models/dashboard_summary_model.dart';
import '../../../dashboard/domain/entities/dashboard_data.dart';

class CachedDashboardModel {
  const CachedDashboardModel({
    required this.todayCalories,
    required this.weeklyCalories,
    required this.monthlyCalories,
    required this.averageCalories,
    required this.proteinTotal,
    required this.carbsTotal,
    required this.fatTotal,
    required this.totalMeals,
    required this.recentMeals,
    required this.cachedAt,
  });

  final int todayCalories;
  final int weeklyCalories;
  final int monthlyCalories;
  final double averageCalories;
  final double proteinTotal;
  final double carbsTotal;
  final double fatTotal;
  final int totalMeals;
  final List<CachedDashboardRecentMealModel> recentMeals;
  final DateTime cachedAt;

  DashboardDataModel toEntity() {
    return DashboardDataModel(
      summary: DashboardSummaryModel(
        todayCalories: todayCalories,
        weeklyCalories: weeklyCalories,
        monthlyCalories: monthlyCalories,
        averageCalories: averageCalories,
        proteinTotal: proteinTotal,
        carbsTotal: carbsTotal,
        fatTotal: fatTotal,
        totalMeals: totalMeals,
      ),
      recentMeals: recentMeals
          .map(
            (meal) => DashboardRecentMealModel(
              id: meal.id,
              foodName: meal.foodName,
              imageUrl: meal.imageUrl,
              calories: meal.calories,
              createdAt: meal.createdAt,
            ),
          )
          .toList(growable: false),
    );
  }

  static CachedDashboardModel fromEntity(
    DashboardData data, {
    required DateTime cachedAt,
  }) {
    final summary = data.summary;
    return CachedDashboardModel(
      todayCalories: summary.todayCalories,
      weeklyCalories: summary.weeklyCalories,
      monthlyCalories: summary.monthlyCalories,
      averageCalories: summary.averageCalories,
      proteinTotal: summary.proteinTotal,
      carbsTotal: summary.carbsTotal,
      fatTotal: summary.fatTotal,
      totalMeals: summary.totalMeals,
      recentMeals: data.recentMeals
          .map(
            (meal) => CachedDashboardRecentMealModel(
              id: meal.id,
              foodName: meal.foodName,
              imageUrl: meal.imageUrl,
              calories: meal.calories,
              createdAt: meal.createdAt,
            ),
          )
          .toList(growable: false),
      cachedAt: cachedAt,
    );
  }
}

class CachedDashboardRecentMealModel {
  const CachedDashboardRecentMealModel({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.createdAt,
    this.imageUrl,
  });

  final String id;
  final String foodName;
  final String? imageUrl;
  final int calories;
  final DateTime createdAt;
}

class CachedDashboardModelAdapter extends TypeAdapter<CachedDashboardModel> {
  @override
  final int typeId = 2;

  @override
  CachedDashboardModel read(BinaryReader reader) {
    return CachedDashboardModel(
      todayCalories: reader.readInt(),
      weeklyCalories: reader.readInt(),
      monthlyCalories: reader.readInt(),
      averageCalories: reader.readDouble(),
      proteinTotal: reader.readDouble(),
      carbsTotal: reader.readDouble(),
      fatTotal: reader.readDouble(),
      totalMeals: reader.readInt(),
      recentMeals: (reader.read() as List)
          .cast<CachedDashboardRecentMealModel>()
          .toList(growable: false),
      cachedAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, CachedDashboardModel obj) {
    writer
      ..writeInt(obj.todayCalories)
      ..writeInt(obj.weeklyCalories)
      ..writeInt(obj.monthlyCalories)
      ..writeDouble(obj.averageCalories)
      ..writeDouble(obj.proteinTotal)
      ..writeDouble(obj.carbsTotal)
      ..writeDouble(obj.fatTotal)
      ..writeInt(obj.totalMeals)
      ..write(obj.recentMeals)
      ..writeInt(obj.cachedAt.millisecondsSinceEpoch);
  }
}

class CachedDashboardRecentMealModelAdapter
    extends TypeAdapter<CachedDashboardRecentMealModel> {
  @override
  final int typeId = 3;

  @override
  CachedDashboardRecentMealModel read(BinaryReader reader) {
    return CachedDashboardRecentMealModel(
      id: reader.readString(),
      foodName: reader.readString(),
      imageUrl: reader.read() as String?,
      calories: reader.readInt(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(reader.readInt()),
    );
  }

  @override
  void write(BinaryWriter writer, CachedDashboardRecentMealModel obj) {
    writer
      ..writeString(obj.id)
      ..writeString(obj.foodName)
      ..write(obj.imageUrl)
      ..writeInt(obj.calories)
      ..writeInt(obj.createdAt.millisecondsSinceEpoch);
  }
}
