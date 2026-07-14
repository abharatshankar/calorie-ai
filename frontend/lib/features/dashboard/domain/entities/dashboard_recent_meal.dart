class DashboardRecentMeal {
  const DashboardRecentMeal({
    required this.id,
    required this.foodName,
    required this.calories,
    required this.createdAt,
    this.imageUrl,
  });

  final String id;
  final String foodName;
  final String? imageUrl;
  final int calories;
  final DateTime createdAt;
}
