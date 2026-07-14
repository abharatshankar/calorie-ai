import 'package:flutter/material.dart';

class GoalProgressCard extends StatelessWidget {
  const GoalProgressCard({
    required this.title,
    required this.current,
    required this.goal,
    required this.unit,
    super.key,
  });

  final String title;
  final num current;
  final num goal;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final progress = goal <= 0 ? 0.0 : (current / goal).clamp(0.0, 1.0);
    final percent = (progress * 100).round();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 8),
            Text(
              '${current.round()} / ${goal.round()} $unit ($percent%)',
            ),
          ],
        ),
      ),
    );
  }
}
