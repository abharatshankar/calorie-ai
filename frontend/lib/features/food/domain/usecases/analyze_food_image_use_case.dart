import '../entities/analysis_image.dart';
import '../entities/food_analysis.dart';
import '../repositories/analysis_repository.dart';

class AnalyzeFoodImageUseCase {
  const AnalyzeFoodImageUseCase(this._repository);

  final AnalysisRepository _repository;

  Future<FoodAnalysis> call(AnalysisImage image) {
    return _repository.analyzeFoodImage(image);
  }
}
