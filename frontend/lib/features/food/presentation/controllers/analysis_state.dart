import '../../domain/entities/analysis_failure.dart';
import '../../domain/entities/analysis_image.dart';
import '../../domain/entities/food_analysis.dart';

enum AnalysisStatus {
  initial,
  loading,
  success,
  failure,
}

class AnalysisState {
  const AnalysisState({
    required this.status,
    this.image,
    this.analysis,
    this.failure,
  });

  const AnalysisState.initial()
      : status = AnalysisStatus.initial,
        image = null,
        analysis = null,
        failure = null;

  final AnalysisStatus status;
  final AnalysisImage? image;
  final FoodAnalysis? analysis;
  final AnalysisFailure? failure;

  bool get isLoading => status == AnalysisStatus.loading;
  bool get isSuccess => status == AnalysisStatus.success;
  bool get isFailure => status == AnalysisStatus.failure;
}
