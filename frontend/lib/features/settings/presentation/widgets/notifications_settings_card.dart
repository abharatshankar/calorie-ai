import 'package:flutter/material.dart';

import '../../domain/entities/notification_preferences.dart';

class NotificationsSettingsCard extends StatelessWidget {
  const NotificationsSettingsCard({
    required this.preferences,
    required this.remoteNotificationsAvailable,
    required this.onChanged,
    super.key,
  });

  final NotificationPreferences preferences;
  final bool remoteNotificationsAvailable;
  final ValueChanged<NotificationPreferences> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            if (!remoteNotificationsAvailable) ...[
              const SizedBox(height: 8),
              Text(
                'Notification preferences are saved locally until backend APIs are available.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.restaurant_outlined),
              title: const Text('Meal reminders'),
              value: preferences.mealRemindersEnabled,
              onChanged: (value) => onChanged(
                preferences.copyWith(mealRemindersEnabled: value),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.water_drop_outlined),
              title: const Text('Water reminders'),
              value: preferences.waterRemindersEnabled,
              onChanged: (value) => onChanged(
                preferences.copyWith(waterRemindersEnabled: value),
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.summarize_outlined),
              title: const Text('Weekly summary'),
              value: preferences.weeklySummaryEnabled,
              onChanged: (value) => onChanged(
                preferences.copyWith(weeklySummaryEnabled: value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
