import 'package:flutter/material.dart';

import '../../domain/entities/dashboard_recent_meal.dart';

class RecentMealsCard extends StatelessWidget {
  const RecentMealsCard({
    required this.meals,
    required this.onViewAll,
    required this.onTapMeal,
    super.key,
  });

  final List<DashboardRecentMeal> meals;
  final VoidCallback onViewAll;
  final ValueChanged<String> onTapMeal;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Meals',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('View all'),
                ),
              ],
            ),
            if (meals.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No meals logged yet.')),
              )
            else
              ...meals.map(
                (meal) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  onTap: () => onTapMeal(meal.id),
                  title: Text(meal.foodName),
                  subtitle: Text(_formatDate(meal.createdAt)),
                  trailing: Text('${meal.calories} kcal'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }
}
