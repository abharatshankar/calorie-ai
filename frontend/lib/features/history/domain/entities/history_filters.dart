class HistoryFilters {
  const HistoryFilters({
    this.search,
    this.startDate,
    this.endDate,
  });

  final String? search;
  final DateTime? startDate;
  final DateTime? endDate;

  bool get hasActiveFilters =>
      (search != null && search!.trim().isNotEmpty) ||
      startDate != null ||
      endDate != null;

  HistoryFilters copyWith({
    String? search,
    DateTime? startDate,
    DateTime? endDate,
    bool clearSearch = false,
    bool clearDates = false,
  }) {
    return HistoryFilters(
      search: clearSearch ? null : search ?? this.search,
      startDate: clearDates ? null : startDate ?? this.startDate,
      endDate: clearDates ? null : endDate ?? this.endDate,
    );
  }
}
