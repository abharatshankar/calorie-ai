import '../entities/user_profile.dart';
import '../repositories/settings_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final SettingsRepository _repository;

  Future<UserProfile> call({
    required String fullName,
  }) {
    return _repository.updateProfile(fullName: fullName);
  }
}
