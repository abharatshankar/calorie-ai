import 'package:flutter/material.dart';

class NutritionCard extends StatelessWidget {
  const NutritionCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    super.key,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;
            final hasBoundedHeight = availableHeight.isFinite;

            final iconSize = hasBoundedHeight
                ? (availableHeight * 0.22).clamp(18.0, 28.0)
                : 24.0;
            final primaryGap = hasBoundedHeight
                ? (availableHeight * 0.12).clamp(6.0, 16.0)
                : 16.0;
            final secondaryGap = (primaryGap * 0.25).clamp(2.0, 4.0);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: iconSize),
                SizedBox(height: primaryGap),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(label, style: theme.textTheme.labelLarge),
                  ),
                ),
                SizedBox(height: secondaryGap),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.headlineSmall,
                        children: [
                          TextSpan(text: value),
                          TextSpan(
                            text: ' $unit',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
