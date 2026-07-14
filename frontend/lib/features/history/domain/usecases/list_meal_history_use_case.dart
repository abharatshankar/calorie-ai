import '../entities/history_filters.dart';
import '../entities/paginated_meal_history.dart';
import '../repositories/history_repository.dart';

class ListMealHistoryUseCase {
  const ListMealHistoryUseCase(this._repository);

  final HistoryRepository _repository;

  Future<PaginatedMealHistory> call({
    required int page,
    required int size,
    required HistoryFilters filters,
  }) {
    return _repository.listMeals(
      page: page,
      size: size,
      filters: filters,
    );
  }
}
