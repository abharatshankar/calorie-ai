import 'package:flutter/material.dart';

class AccountSettingsCard extends StatelessWidget {
  const AccountSettingsCard({
    required this.appVersion,
    required this.accountDeletionAvailable,
    required this.onClearCache,
    required this.onDeleteAccount,
    required this.onLogout,
    super.key,
  });

  final String appVersion;
  final bool accountDeletionAvailable;
  final VoidCallback onClearCache;
  final VoidCallback onDeleteAccount;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: onLogout,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cleaning_services_outlined),
              title: const Text('Clear cache'),
              onTap: onClearCache,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                Icons.delete_forever_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete account',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              subtitle: accountDeletionAvailable
                  ? null
                  : const Text('Backend API not available yet.'),
              onTap: onDeleteAccount,
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.info_outline),
              title: const Text('App version'),
              trailing: Text(appVersion),
            ),
          ],
        ),
      ),
    );
  }
}
