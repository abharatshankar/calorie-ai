import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/analysis_failure.dart';
import '../../domain/entities/analysis_image.dart';
import '../../domain/entities/food_analysis.dart';
import '../controllers/analysis_controller.dart';
import '../controllers/analysis_state.dart';
import '../widgets/confidence_card.dart';
import '../widgets/nutrition_card.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({
    required this.image,
    super.key,
  });

  final AnalysisImage? image;

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started || widget.image == null) {
      return;
    }

    _started = true;
    Future<void>.microtask(
      () => ref.read(analysisControllerProvider.notifier).analyze(widget.image!),
    );
  }

  @override
  Widget build(BuildContext context) {
    final analysisValue = ref.watch(analysisControllerProvider);
    final analysisState =
        analysisValue.value ?? const AnalysisState.initial();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Analysis'),
      ),
      body: widget.image == null
          ? _MissingImageView(onBack: () => Navigator.of(context).pop())
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(analysisControllerProvider.notifier).analyze(
                        widget.image!,
                      ),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  if (analysisState.isLoading) ...[
                    const _AnalysisLoadingView(),
                  ] else if (analysisState.isFailure) ...[
                    _AnalysisErrorView(
                      failure: analysisState.failure,
                      onRetry: () => ref
                          .read(analysisControllerProvider.notifier)
                          .retry(),
                    ),
                    if (analysisState.analysis != null) ...[
                      const SizedBox(height: 24),
                      _AnalysisResultView(analysis: analysisState.analysis!),
                    ],
                  ] else if (analysisState.isSuccess &&
                      analysisState.analysis != null) ...[
                    _AnalysisResultView(analysis: analysisState.analysis!),
                  ] else ...[
                    const _AnalysisLoadingView(),
                  ],
                ],
              ),
            ),
    );
  }
}

class _AnalysisLoadingView extends StatelessWidget {
  const _AnalysisLoadingView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            'Analyzing your food image',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This can take a moment while the AI estimates nutrition values.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _AnalysisErrorView extends StatelessWidget {
  const _AnalysisErrorView({
    required this.failure,
    required this.onRetry,
  });

  final AnalysisFailure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Analysis failed',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              failure?.message ??
                  'Could not analyze this image. Please try again.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisResultView extends StatelessWidget {
  const _AnalysisResultView({
    required this.analysis,
  });

  final FoodAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          analysis.foodName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (analysis.servingSize != null) ...[
          const SizedBox(height: 4),
          Text('Serving size: ${analysis.servingSize}'),
        ],
        if (analysis.nutritionSummary.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(analysis.nutritionSummary),
        ],
        const SizedBox(height: 24),
        GridView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.25,
          ),
          children: [
            NutritionCard(
              label: 'Calories',
              value: analysis.calories.toString(),
              unit: 'kcal',
              icon: Icons.local_fire_department_outlined,
            ),
            NutritionCard(
              label: 'Protein',
              value: analysis.protein.toStringAsFixed(1),
              unit: 'g',
              icon: Icons.fitness_center_outlined,
            ),
            NutritionCard(
              label: 'Carbs',
              value: analysis.carbs.toStringAsFixed(1),
              unit: 'g',
              icon: Icons.grain_outlined,
            ),
            NutritionCard(
              label: 'Fat',
              value: analysis.fat.toStringAsFixed(1),
              unit: 'g',
              icon: Icons.water_drop_outlined,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ConfidenceCard(confidencePercent: analysis.confidencePercent),
      ],
    );
  }
}

class _MissingImageView extends StatelessWidget {
  const _MissingImageView({
    required this.onBack,
  });

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_not_supported_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              'No image available for analysis.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onBack,
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }
}
