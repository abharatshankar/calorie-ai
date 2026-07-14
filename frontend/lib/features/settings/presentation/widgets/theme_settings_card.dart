import 'package:flutter/material.dart';

import '../../domain/entities/app_theme_preference.dart';

class ThemeSettingsCard extends StatelessWidget {
  const ThemeSettingsCard({
    required this.preference,
    required this.onChanged,
    super.key,
  });

  final AppThemePreference preference;
  final ValueChanged<AppThemePreference> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<AppThemePreference>(
              segments: AppThemePreference.values
                  .map(
                    (value) => ButtonSegment<AppThemePreference>(
                      value: value,
                      label: Text(value.label),
                    ),
                  )
                  .toList(growable: false),
              selected: {preference},
              onSelectionChanged: (selection) {
                onChanged(selection.first);
              },
            ),
          ],
        ),
      ),
    );
  }
}
