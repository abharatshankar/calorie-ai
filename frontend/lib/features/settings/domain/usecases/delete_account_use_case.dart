import '../repositories/settings_repository.dart';

class DeleteAccountUseCase {
  const DeleteAccountUseCase(this._repository);

  final SettingsRepository _repository;

  Future<void> call() {
    return _repository.deleteAccount();
  }
}
