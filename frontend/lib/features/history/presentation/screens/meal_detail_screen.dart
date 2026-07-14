import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../food/presentation/widgets/confidence_card.dart';
import '../../../food/presentation/widgets/nutrition_card.dart';
import '../../domain/entities/history_failure.dart';
import '../../domain/entities/meal_history_item.dart';
import '../controllers/history_controller.dart';
import '../controllers/history_detail_provider.dart';

class MealDetailScreen extends ConsumerWidget {
  const MealDetailScreen({
    required this.mealId,
    super.key,
  });

  final String mealId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailValue = ref.watch(historyDetailProvider(mealId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Details'),
        actions: [
          IconButton(
            onPressed: () => ref.refresh(historyDetailProvider(mealId)),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => _confirmDelete(context, ref),
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: detailValue.when(
        data: (meal) => RefreshIndicator(
          onRefresh: () async => ref.refresh(historyDetailProvider(mealId)),
          child: _MealDetailBody(meal: meal),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _DetailErrorView(
          message: error is HistoryFailure
              ? error.message
              : 'Could not load this meal.',
          onRetry: () => ref.refresh(historyDetailProvider(mealId)),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete meal?'),
          content: const Text(
            'This meal entry will be permanently removed from your history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    try {
      await ref.read(historyControllerProvider.notifier).deleteMeal(mealId);
      ref.invalidate(historyDetailProvider(mealId));
      if (context.mounted) {
        context.pop();
      }
    } on HistoryFailure catch (failure) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
      }
    }
  }
}

class _MealDetailBody extends StatelessWidget {
  const _MealDetailBody({
    required this.meal,
  });

  final MealHistoryItem meal;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        if (meal.imageUrl != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              meal.imageUrl!,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 220,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_not_supported_outlined),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
        Text(
          meal.foodName,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(_formatDateTime(meal.createdAt)),
        if (meal.servingSize != null) ...[
          const SizedBox(height: 8),
          Text('Serving size: ${meal.servingSize}'),
        ],
        if (meal.nutritionSummary.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(meal.nutritionSummary),
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
              value: meal.calories.toString(),
              unit: 'kcal',
              icon: Icons.local_fire_department_outlined,
            ),
            NutritionCard(
              label: 'Protein',
              value: meal.protein.toStringAsFixed(1),
              unit: 'g',
              icon: Icons.fitness_center_outlined,
            ),
            NutritionCard(
              label: 'Carbs',
              value: meal.carbs.toStringAsFixed(1),
              unit: 'g',
              icon: Icons.grain_outlined,
            ),
            NutritionCard(
              label: 'Fat',
              value: meal.fat.toStringAsFixed(1),
              unit: 'g',
              icon: Icons.water_drop_outlined,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ConfidenceCard(confidencePercent: meal.confidencePercent),
      ],
    );
  }

  String _formatDateTime(DateTime value) {
    final local = value.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}

class _DetailErrorView extends StatelessWidget {
  const _DetailErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
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
