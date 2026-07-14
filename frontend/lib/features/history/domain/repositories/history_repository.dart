import '../entities/history_filters.dart';
import '../entities/meal_history_item.dart';
import '../entities/paginated_meal_history.dart';

abstract interface class HistoryRepository {
  Future<PaginatedMealHistory> listMeals({
    required int page,
    required int size,
    required HistoryFilters filters,
  });

  Future<MealHistoryItem> getMeal(String id);

  Future<void> deleteMeal(String id);
}
