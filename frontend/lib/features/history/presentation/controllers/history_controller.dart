import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/history_repository_impl.dart';
import '../../domain/entities/history_failure.dart';
import '../../domain/entities/history_filters.dart';
import '../../domain/usecases/delete_meal_history_item_use_case.dart';
import '../../domain/usecases/list_meal_history_use_case.dart';
import 'history_state.dart';

final historyControllerProvider =
    AsyncNotifierProvider<HistoryController, HistoryState>(
  HistoryController.new,
);

class HistoryController extends AsyncNotifier<HistoryState> {
  static const pageSize = 20;

  late final ListMealHistoryUseCase _listMealHistoryUseCase;
  late final DeleteMealHistoryItemUseCase _deleteMealHistoryItemUseCase;

  @override
  HistoryState build() {
    final repository = ref.watch(historyRepositoryProvider);
    _listMealHistoryUseCase = ListMealHistoryUseCase(repository);
    _deleteMealHistoryItemUseCase = DeleteMealHistoryItemUseCase(repository);

    Future<void>.microtask(loadInitial);
    return const HistoryState.initial();
  }

  Future<void> loadInitial() async {
    final currentState = state.value ?? const HistoryState.initial();
    state = AsyncData(
      currentState.copyWith(
        isInitialLoading: true,
        isLoadingMore: false,
        isRefreshing: false,
        clearFailure: true,
      ),
    );

    await _loadPage(page: 1, replace: true);
  }

  Future<void> refresh() async {
    final currentState = state.value ?? const HistoryState.initial();
    state = AsyncData(
      currentState.copyWith(
        isRefreshing: true,
        isLoadingMore: false,
        clearFailure: true,
      ),
    );

    await _loadPage(page: 1, replace: true);
  }

  Future<void> loadNextPage() async {
    final currentState = state.value ?? const HistoryState.initial();
    if (currentState.isBusy || !currentState.hasMore) {
      return;
    }

    state = AsyncData(
      currentState.copyWith(
        isLoadingMore: true,
        clearFailure: true,
      ),
    );

    await _loadPage(page: currentState.page + 1, replace: false);
  }

  Future<void> applySearch(String value) async {
    final trimmed = value.trim();
    await _applyFilters(
      (state.value ?? const HistoryState.initial()).filters.copyWith(
            search: trimmed.isEmpty ? null : trimmed,
            clearSearch: trimmed.isEmpty,
          ),
    );
  }

  Future<void> applyDateRange(DateTimeRangeValue range) async {
    await _applyFilters(
      (state.value ?? const HistoryState.initial()).filters.copyWith(
            startDate: range.start,
            endDate: range.end,
          ),
    );
  }

  Future<void> clearDateRange() async {
    await _applyFilters(
      (state.value ?? const HistoryState.initial()).filters.copyWith(
            clearDates: true,
          ),
    );
  }

  Future<void> clearFilters() async {
    await _applyFilters(const HistoryFilters());
  }

  Future<void> deleteMeal(String id) async {
    final currentState = state.value ?? const HistoryState.initial();
    try {
      await _deleteMealHistoryItemUseCase(id);
      state = AsyncData(
        currentState.copyWith(
          items: currentState.items
              .where((item) => item.id != id)
              .toList(growable: false),
          total: currentState.total > 0 ? currentState.total - 1 : 0,
          clearFailure: true,
        ),
      );
    } on HistoryFailure catch (failure) {
      state = AsyncData(currentState.copyWith(failure: failure));
      rethrow;
    }
  }

  Future<void> _applyFilters(HistoryFilters filters) async {
    final currentState = state.value ?? const HistoryState.initial();
    state = AsyncData(
      currentState.copyWith(
        filters: filters,
        items: const [],
        page: 0,
        total: 0,
        pages: 0,
        isInitialLoading: true,
        clearFailure: true,
      ),
    );

    await _loadPage(page: 1, replace: true);
  }

  Future<void> _loadPage({
    required int page,
    required bool replace,
  }) async {
    final currentState = state.value ?? const HistoryState.initial();
    try {
      final result = await _listMealHistoryUseCase(
        page: page,
        size: pageSize,
        filters: currentState.filters,
      );

      final nextItems = replace
          ? result.items
          : [...currentState.items, ...result.items];

      state = AsyncData(
        currentState.copyWith(
          items: nextItems,
          page: result.page,
          total: result.total,
          pages: result.pages,
          isInitialLoading: false,
          isLoadingMore: false,
          isRefreshing: false,
          clearFailure: true,
        ),
      );
    } on HistoryFailure catch (failure) {
      state = AsyncData(
        currentState.copyWith(
          isInitialLoading: false,
          isLoadingMore: false,
          isRefreshing: false,
          failure: failure,
        ),
      );
    } catch (_) {
      state = AsyncData(
        currentState.copyWith(
          isInitialLoading: false,
          isLoadingMore: false,
          isRefreshing: false,
          failure: const HistoryFailure(
            type: HistoryFailureType.unknown,
            message: 'Could not load meal history. Please try again.',
          ),
        ),
      );
    }
  }
}

class DateTimeRangeValue {
  const DateTimeRangeValue({
    required this.start,
    required this.end,
  });

  final DateTime start;
  final DateTime end;
}
