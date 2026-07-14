import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/analysis_repository_impl.dart';
import '../../domain/entities/analysis_failure.dart';
import '../../domain/entities/analysis_image.dart';
import '../../domain/usecases/analyze_food_image_use_case.dart';
import 'analysis_state.dart';

final analysisControllerProvider =
    AsyncNotifierProvider<AnalysisController, AnalysisState>(
  AnalysisController.new,
);

class AnalysisController extends AsyncNotifier<AnalysisState> {
  late final AnalyzeFoodImageUseCase _analyzeFoodImageUseCase;

  @override
  AnalysisState build() {
    _analyzeFoodImageUseCase = AnalyzeFoodImageUseCase(
      ref.watch(analysisRepositoryProvider),
    );
    return const AnalysisState.initial();
  }

  Future<void> analyze(AnalysisImage image) async {
    final currentState = state.value ?? const AnalysisState.initial();
    if (currentState.isLoading) {
      return;
    }

    state = AsyncData(
      AnalysisState(
        status: AnalysisStatus.loading,
        image: image,
        analysis: currentState.analysis,
      ),
    );

    try {
      final analysis = await _analyzeFoodImageUseCase(image);
      state = AsyncData(
        AnalysisState(
          status: AnalysisStatus.success,
          image: image,
          analysis: analysis,
        ),
      );
    } on AnalysisFailure catch (failure) {
      state = AsyncData(
        AnalysisState(
          status: AnalysisStatus.failure,
          image: image,
          failure: failure,
          analysis: currentState.analysis,
        ),
      );
    } catch (_) {
      state = AsyncData(
        AnalysisState(
          status: AnalysisStatus.failure,
          image: image,
          failure: const AnalysisFailure(
            type: AnalysisFailureType.unknown,
            message: 'Could not analyze this image. Please try again.',
          ),
          analysis: currentState.analysis,
        ),
      );
    }
  }

  Future<void> retry() async {
    final image = state.value?.image;
    if (image == null) {
      return;
    }

    await analyze(image);
  }

  void reset() {
    state = const AsyncData(AnalysisState.initial());
  }
}
