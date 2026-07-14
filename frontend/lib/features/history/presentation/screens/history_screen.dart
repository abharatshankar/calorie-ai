import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../offline/presentation/widgets/offline_status_banner.dart';
import '../../domain/entities/history_failure.dart';
import '../controllers/history_controller.dart';
import '../controllers/history_state.dart';
import '../widgets/meal_history_card.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) {
      return;
    }

    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 320) {
      ref.read(historyControllerProvider.notifier).loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyValue = ref.watch(historyControllerProvider);
    final historyState = historyValue.value ?? const HistoryState.initial();

    ref.listen<AsyncValue<HistoryState>>(historyControllerProvider, (
      previous,
      next,
    ) {
      final failure = next.value?.failure;
      if (failure?.type == HistoryFailureType.unauthorized) {
        ref.read(authControllerProvider.notifier).logout();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal History'),
        actions: [
          IconButton(
            onPressed: historyState.isBusy
                ? null
                : () => ref.read(historyControllerProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  const OfflineStatusBanner(),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      labelText: 'Search meals',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: historyState.filters.search?.isNotEmpty == true
                          ? IconButton(
                              onPressed: _clearSearch,
                              icon: const Icon(Icons.clear),
                            )
                          : null,
                    ),
                    onChanged: _onSearchChanged,
                    onSubmitted: (value) => ref
                        .read(historyControllerProvider.notifier)
                        .applySearch(value),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: historyState.isBusy
                              ? null
                              : () => _pickDateRange(context),
                          icon: const Icon(Icons.date_range_outlined),
                          label: Text(_dateFilterLabel(historyState)),
                        ),
                      ),
                      if (historyState.filters.startDate != null ||
                          historyState.filters.endDate != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: historyState.isBusy
                              ? null
                              : () => ref
                                  .read(historyControllerProvider.notifier)
                                  .clearDateRange(),
                          icon: const Icon(Icons.filter_alt_off_outlined),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ref.read(historyControllerProvider.notifier).refresh(),
                child: _HistoryBody(
                  state: historyState,
                  scrollController: _scrollController,
                  onRetry: () =>
                      ref.read(historyControllerProvider.notifier).refresh(),
                  onTapItem: (id) => context.go(
                    AppRoute.historyDetail.pathFor(id),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      ref.read(historyControllerProvider.notifier).applySearch(value);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(historyControllerProvider.notifier).applySearch('');
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final filters =
        ref.read(historyControllerProvider).value ?? const HistoryState.initial();
    final now = DateTime.now();
    final pickedRange = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: filters.filters.startDate != null &&
              filters.filters.endDate != null
          ? DateTimeRange(
              start: filters.filters.startDate!,
              end: filters.filters.endDate!,
            )
          : null,
    );

    if (pickedRange == null) {
      return;
    }

    await ref.read(historyControllerProvider.notifier).applyDateRange(
          DateTimeRangeValue(
            start: pickedRange.start,
            end: pickedRange.end,
          ),
        );
  }

  String _dateFilterLabel(HistoryState state) {
    final start = state.filters.startDate;
    final end = state.filters.endDate;
    if (start == null || end == null) {
      return 'Filter by date';
    }

    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({
    required this.state,
    required this.scrollController,
    required this.onRetry,
    required this.onTapItem,
  });

  final HistoryState state;
  final ScrollController scrollController;
  final VoidCallback onRetry;
  final ValueChanged<String> onTapItem;

  @override
  Widget build(BuildContext context) {
    if (state.isInitialLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.failure != null && state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.error_outline,
            size: 48,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            state.failure!.message,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (state.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: const [
          SizedBox(height: 80),
          Icon(Icons.restaurant_menu_outlined, size: 48),
          SizedBox(height: 16),
          Text(
            'No meals found.',
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return ListView.builder(
      controller: scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: state.items.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= state.items.length) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final item = state.items[index];
        return MealHistoryCard(
          item: item,
          onTap: () => onTapItem(item.id),
        );
      },
    );
  }
}
