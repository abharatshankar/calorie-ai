import '../entities/app_theme_preference.dart';
import '../repositories/settings_repository.dart';

class UpdateThemePreferenceUseCase {
  const UpdateThemePreferenceUseCase(this._repository);

  final SettingsRepository _repository;

  Future<AppThemePreference> call(AppThemePreference preference) {
    return _repository.updateThemePreference(preference);
  }
}
