import '../entities/nutrition_preferences.dart';
import '../repositories/settings_repository.dart';

class UpdateNutritionPreferencesUseCase {
  const UpdateNutritionPreferencesUseCase(this._repository);

  final SettingsRepository _repository;

  Future<NutritionPreferences> call(NutritionPreferences preferences) {
    return _repository.updateNutritionPreferences(preferences);
  }
}
