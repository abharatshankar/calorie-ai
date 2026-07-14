import 'package:flutter/material.dart';

import '../../domain/entities/nutrition_preferences.dart';

class PreferencesSettingsCard extends StatelessWidget {
  const PreferencesSettingsCard({
    required this.preferences,
    required this.remotePreferencesAvailable,
    required this.onEdit,
    super.key,
  });

  final NutritionPreferences preferences;
  final bool remotePreferencesAvailable;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Preferences',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.tune_outlined),
                  label: const Text('Edit'),
                ),
              ],
            ),
            if (!remotePreferencesAvailable) ...[
              const SizedBox(height: 8),
              Text(
                'Backend preference APIs are not available yet.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _PreferenceTile(
              icon: Icons.local_fire_department_outlined,
              label: 'Daily calorie goal',
              value: '${preferences.dailyCalorieGoal} kcal',
            ),
            _PreferenceTile(
              icon: Icons.fitness_center_outlined,
              label: 'Daily protein goal',
              value: '${preferences.dailyProteinGoal.toStringAsFixed(0)} g',
            ),
            _PreferenceTile(
              icon: Icons.grain_outlined,
              label: 'Daily carbs goal',
              value: '${preferences.dailyCarbsGoal.toStringAsFixed(0)} g',
            ),
            _PreferenceTile(
              icon: Icons.opacity_outlined,
              label: 'Daily fat goal',
              value: '${preferences.dailyFatGoal.toStringAsFixed(0)} g',
            ),
            _PreferenceTile(
              icon: Icons.water_drop_outlined,
              label: 'Water intake goal',
              value: '${preferences.waterIntakeGoalMl} ml',
            ),
            _PreferenceTile(
              icon: Icons.monitor_weight_outlined,
              label: 'Weight goal',
              value: '${preferences.weightGoalKg.toStringAsFixed(1)} kg',
            ),
          ],
        ),
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
