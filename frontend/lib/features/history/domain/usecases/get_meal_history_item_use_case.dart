import '../entities/meal_history_item.dart';
import '../repositories/history_repository.dart';

class GetMealHistoryItemUseCase {
  const GetMealHistoryItemUseCase(this._repository);

  final HistoryRepository _repository;

  Future<MealHistoryItem> call(String id) {
    return _repository.getMeal(id);
  }
}
