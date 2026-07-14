import 'package:flutter/material.dart';

import '../../domain/entities/meal_history_item.dart';

class MealHistoryCard extends StatelessWidget {
  const MealHistoryCard({
    required this.item,
    required this.onTap,
    super.key,
  });

  final MealHistoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Text(item.calories.toString()),
        ),
        title: Text(item.foodName),
        subtitle: Text(
          '${_formatDate(item.createdAt)} • '
          'P ${item.protein.toStringAsFixed(1)}g  '
          'C ${item.carbs.toStringAsFixed(1)}g  '
          'F ${item.fat.toStringAsFixed(1)}g',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}
