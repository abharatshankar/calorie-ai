import '../../domain/entities/paginated_meal_history.dart';
import 'meal_history_item_model.dart';

class PaginatedMealHistoryModel extends PaginatedMealHistory {
  const PaginatedMealHistoryModel({
    required super.items,
    required super.total,
    required super.page,
    required super.size,
    required super.pages,
  });

  factory PaginatedMealHistoryModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? const [];

    return PaginatedMealHistoryModel(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(MealHistoryItemModel.fromJson)
          .toList(growable: false),
      total: json['total'] as int,
      page: json['page'] as int,
      size: json['size'] as int,
      pages: json['pages'] as int,
    );
  }
}
