import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../dashboard/domain/entities/dashboard_data.dart';
import '../../../history/domain/entities/history_filters.dart';
import '../../../history/domain/entities/meal_history_item.dart';
import '../../../history/domain/entities/paginated_meal_history.dart';
import '../models/cached_dashboard_model.dart';
import '../models/cached_meal_history_item_model.dart';
import 'offline_database.dart';

final offlineCacheDataSourceProvider = Provider<OfflineCacheDataSource>(
  (ref) => OfflineCacheDataSource(
    historyBox: Hive.box<CachedMealHistoryItemModel>(
      OfflineDatabase.historyBoxName,
    ),
    dashboardBox: Hive.box<CachedDashboardModel>(
      OfflineDatabase.dashboardBoxName,
    ),
  ),
);

class OfflineCacheDataSource {
  const OfflineCacheDataSource({
    required Box<CachedMealHistoryItemModel> historyBox,
    required Box<CachedDashboardModel> dashboardBox,
  })  : _historyBox = historyBox,
        _dashboardBox = dashboardBox;

  static const dashboardKey = 'latest';
  static const dashboardTtl = Duration(minutes: 30);
  static const historyTtl = Duration(hours: 6);

  final Box<CachedMealHistoryItemModel> _historyBox;
  final Box<CachedDashboardModel> _dashboardBox;

  Future<void> cacheHistoryPage(PaginatedMealHistory history) async {
    final cachedAt = DateTime.now();
    final entries = {
      for (final item in history.items)
        item.id: CachedMealHistoryItemModel.fromEntity(
          item,
          cachedAt: cachedAt,
        ),
    };
    await _historyBox.putAll(entries);
  }

  Future<PaginatedMealHistory?> readHistoryPage({
    required int page,
    required int size,
    required HistoryFilters filters,
    required bool allowExpired,
  }) async {
    try {
      final cachedItems = _historyBox.values.toList(growable: false);
      if (cachedItems.isEmpty) {
        return null;
      }

      final cutoff = DateTime.now().subtract(historyTtl);
      final usableItems = allowExpired
          ? cachedItems
          : cachedItems
              .where((item) => item.cachedAt.isAfter(cutoff))
              .toList(growable: false);
      if (usableItems.isEmpty) {
        return null;
      }

      final filteredItems = usableItems
          .map((item) => item.toEntity())
          .where((item) => _matchesFilters(item, filters))
          .toList(growable: false);
      final sortedItems = filteredItems
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final start = (page - 1) * size;
      if (start >= sortedItems.length) {
        return PaginatedMealHistory(
          items: const [],
          total: sortedItems.length,
          page: page,
          size: size,
          pages: _pagesFor(sortedItems.length, size),
        );
      }

      final end = (start + size).clamp(0, sortedItems.length);
      return PaginatedMealHistory(
        items: sortedItems.sublist(start, end),
        total: sortedItems.length,
        page: page,
        size: size,
        pages: _pagesFor(sortedItems.length, size),
      );
    } catch (_) {
      return null;
    }
  }

  Future<MealHistoryItem?> readMeal(String id) async {
    try {
      return _historyBox.get(id)?.toEntity();
    } catch (_) {
      return null;
    }
  }

  Future<void> removeMeal(String id) {
    return _historyBox.delete(id);
  }

  Future<void> cacheDashboard(DashboardData data) {
    return _dashboardBox.put(
      dashboardKey,
      CachedDashboardModel.fromEntity(data, cachedAt: DateTime.now()),
    );
  }

  Future<DashboardData?> readDashboard({required bool allowExpired}) async {
    try {
      final cached = _dashboardBox.get(dashboardKey);
      if (cached == null) {
        return null;
      }
      final isFresh = cached.cachedAt.isAfter(
        DateTime.now().subtract(dashboardTtl),
      );
      if (!allowExpired && !isFresh) {
        return null;
      }
      return cached.toEntity();
    } catch (_) {
      return null;
    }
  }

  int _pagesFor(int total, int size) {
    return total == 0 ? 0 : (total + size - 1) ~/ size;
  }

  bool _matchesFilters(MealHistoryItem item, HistoryFilters filters) {
    final search = filters.search?.trim().toLowerCase();
    if (search != null &&
        search.isNotEmpty &&
        !item.foodName.toLowerCase().contains(search)) {
      return false;
    }

    final createdDate = DateTime(
      item.createdAt.year,
      item.createdAt.month,
      item.createdAt.day,
    );
    final startDate = filters.startDate;
    if (startDate != null && createdDate.isBefore(_dateOnly(startDate))) {
      return false;
    }
    final endDate = filters.endDate;
    if (endDate != null && createdDate.isAfter(_dateOnly(endDate))) {
      return false;
    }
    return true;
  }

  DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
