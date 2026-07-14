import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/history_repository_impl.dart';
import '../../domain/entities/meal_history_item.dart';
import '../../domain/usecases/get_meal_history_item_use_case.dart';

final historyDetailProvider = FutureProvider.family<MealHistoryItem, String>(
  (ref, id) {
    final repository = ref.watch(historyRepositoryProvider);
    return GetMealHistoryItemUseCase(repository)(id);
  },
);
