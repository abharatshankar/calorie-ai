import '../entities/analysis_image.dart';
import '../entities/food_analysis.dart';

abstract interface class AnalysisRepository {
  Future<FoodAnalysis> analyzeFoodImage(AnalysisImage image);
}
