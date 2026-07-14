import 'package:flutter/material.dart';

class ConfidenceCard extends StatelessWidget {
  const ConfidenceCard({
    required this.confidencePercent,
    super.key,
  });

  final int? confidencePercent;

  @override
  Widget build(BuildContext context) {
    final value = confidencePercent;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Confidence Score',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (value == null) ...[
              const Text('Not provided by the analysis provider.'),
            ] else ...[
              LinearProgressIndicator(value: value / 100),
              const SizedBox(height: 8),
              Text(
                '$value%',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
