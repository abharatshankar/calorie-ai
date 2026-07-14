import 'package:flutter/material.dart';

class MacroChartCard extends StatelessWidget {
  const MacroChartCard({
    required this.protein,
    required this.carbs,
    required this.fat,
    super.key,
  });

  final double protein;
  final double carbs;
  final double fat;

  @override
  Widget build(BuildContext context) {
    final maxValue = [protein, carbs, fat, 1.0]
        .reduce((value, element) => value > element ? value : element);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macronutrients',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _MacroBar(
              label: 'Protein',
              value: protein,
              maxValue: maxValue,
              color: Colors.green,
            ),
            const SizedBox(height: 12),
            _MacroBar(
              label: 'Carbs',
              value: carbs,
              maxValue: maxValue,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
            _MacroBar(
              label: 'Fat',
              value: fat,
              maxValue: maxValue,
              color: Colors.blue,
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  const _MacroBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
  });

  final String label;
  final double value;
  final double maxValue;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = maxValue <= 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${value.toStringAsFixed(1)}g'),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          color: color,
          minHeight: 10,
          borderRadius: BorderRadius.circular(999),
        ),
      ],
    );
  }
}
