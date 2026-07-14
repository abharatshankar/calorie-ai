import '../../domain/entities/history_failure.dart';
import '../../domain/entities/history_filters.dart';
import '../../domain/entities/meal_history_item.dart';

class HistoryState {
  const HistoryState({
    required this.items,
    required this.filters,
    required this.page,
    required this.total,
    required this.pages,
    required this.isInitialLoading,
    required this.isLoadingMore,
    required this.isRefreshing,
    this.failure,
  });

  const HistoryState.initial()
      : items = const [],
        filters = const HistoryFilters(),
        page = 0,
        total = 0,
        pages = 0,
        isInitialLoading = false,
        isLoadingMore = false,
        isRefreshing = false,
        failure = null;

  final List<MealHistoryItem> items;
  final HistoryFilters filters;
  final int page;
  final int total;
  final int pages;
  final bool isInitialLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  final HistoryFailure? failure;

  bool get hasMore => page < pages;
  bool get isBusy => isInitialLoading || isLoadingMore || isRefreshing;
  bool get isEmpty => items.isEmpty && !isInitialLoading;

  HistoryState copyWith({
    List<MealHistoryItem>? items,
    HistoryFilters? filters,
    int? page,
    int? total,
    int? pages,
    bool? isInitialLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    HistoryFailure? failure,
    bool clearFailure = false,
  }) {
    return HistoryState(
      items: items ?? this.items,
      filters: filters ?? this.filters,
      page: page ?? this.page,
      total: total ?? this.total,
      pages: pages ?? this.pages,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
