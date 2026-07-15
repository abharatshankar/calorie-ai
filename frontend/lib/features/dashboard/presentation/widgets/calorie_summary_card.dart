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
                    child: Text(title, style: theme.textTheme.labelLarge),
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
                          TextSpan(text: calories.toString()),
                          TextSpan(
                            text: ' kcal',
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
