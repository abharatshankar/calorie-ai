import '../../domain/entities/settings_data.dart';
import '../../domain/entities/settings_failure.dart';

class SettingsState {
  const SettingsState({
    required this.data,
    this.isSaving = false,
    this.successMessage,
    this.failure,
  });

  final SettingsData data;
  final bool isSaving;
  final String? successMessage;
  final SettingsFailure? failure;

  SettingsState copyWith({
    SettingsData? data,
    bool? isSaving,
    String? successMessage,
    SettingsFailure? failure,
    bool clearMessage = false,
    bool clearFailure = false,
  }) {
    return SettingsState(
      data: data ?? this.data,
      isSaving: isSaving ?? this.isSaving,
      successMessage: clearMessage
          ? null
          : successMessage ?? this.successMessage,
      failure: clearFailure ? null : failure ?? this.failure,
    );
  }
}
