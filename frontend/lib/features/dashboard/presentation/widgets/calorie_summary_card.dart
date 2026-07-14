import 'package:flutter/material.dart';

class CalorieSummaryCard extends StatelessWidget {
  const CalorieSummaryCard({
    required this.title,
    required this.calories,
    required this.icon,
    super.key,
  });

  final String title;
  final int calories;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              calories.toString(),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              'kcal',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
