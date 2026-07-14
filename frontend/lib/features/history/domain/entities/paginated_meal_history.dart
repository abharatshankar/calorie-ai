import 'meal_history_item.dart';

class PaginatedMealHistory {
  const PaginatedMealHistory({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  });

  final List<MealHistoryItem> items;
  final int total;
  final int page;
  final int size;
  final int pages;

  bool get hasMore => page < pages;
}
