import '../repositories/settings_repository.dart';

class ClearCacheUseCase {
  const ClearCacheUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call() {
    return _repository.clearCache();
  }
}
