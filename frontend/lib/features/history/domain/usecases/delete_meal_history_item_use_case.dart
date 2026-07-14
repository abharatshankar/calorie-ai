import '../repositories/history_repository.dart';

class DeleteMealHistoryItemUseCase {
  const DeleteMealHistoryItemUseCase(this._repository);

  final HistoryRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteMeal(id);
  }
}
