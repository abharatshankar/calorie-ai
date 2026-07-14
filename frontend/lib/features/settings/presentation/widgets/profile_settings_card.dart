import 'package:flutter/material.dart';

import '../../domain/entities/user_profile.dart';

class ProfileSettingsCard extends StatelessWidget {
  const ProfileSettingsCard({
    required this.profile,
    required this.profileEditingAvailable,
    required this.onEditProfile,
    required this.onLogout,
    super.key,
  });

  final UserProfile profile;
  final bool profileEditingAvailable;
  final VoidCallback onEditProfile;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  child: Text(
                    profile.email.characters.first.toUpperCase(),
                    style: textTheme.titleLarge,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(profile.email),
                    ],
                  ),
                ),
                if (profile.isVerified)
                  const Icon(Icons.verified_outlined),
              ],
            ),
            const SizedBox(height: 16),
            _ProfileRow(
              icon: Icons.calendar_today_outlined,
              label: 'Joined',
              value: _formatDate(profile.joinedAt),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEditProfile,
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(
                      profileEditingAvailable
                          ? 'Edit Profile'
                          : 'Edit Profile',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text(label),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}
