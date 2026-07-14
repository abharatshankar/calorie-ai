import 'package:flutter/material.dart';

import '../../domain/entities/uploaded_food_image.dart';

class AnalysisLoadingScreen extends StatelessWidget {
  const AnalysisLoadingScreen({
    this.uploadedImage,
    super.key,
  });

  final UploadedFoodImage? uploadedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preparing Analysis'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                'Image uploaded successfully.',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              if (uploadedImage != null) ...[
                Text(
                  uploadedImage!.filename,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
              ],
              Text(
                'AI analysis will be implemented in a later milestone.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
