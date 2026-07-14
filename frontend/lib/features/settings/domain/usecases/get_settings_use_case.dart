import '../entities/settings_data.dart';
import '../repositories/settings_repository.dart';

class GetSettingsUseCase {
  const GetSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<SettingsData> call() {
    return _repository.getSettings();
  }
}
