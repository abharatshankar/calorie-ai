import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_exception.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/restore_session_use_case.dart';
import 'auth_state.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final RestoreSessionUseCase _restoreSessionUseCase;
  late final LogoutUseCase _logoutUseCase;

  @override
  AuthState build() {
    final repository = ref.watch(authRepositoryProvider);
    _loginUseCase = LoginUseCase(repository);
    _registerUseCase = RegisterUseCase(repository);
    _restoreSessionUseCase = RestoreSessionUseCase(repository);
    _logoutUseCase = LogoutUseCase(repository);

    Future<void>.microtask(restoreSession);
    return const AuthState.checking();
  }

  Future<void> restoreSession() async {
    state = const AuthState.checking();

    final session = await _restoreSessionUseCase();
    state = session == null
        ? const AuthState.unauthenticated()
        : AuthState.authenticated(session);
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final session = await _loginUseCase(
        email: email.trim(),
        password: password,
      );
      state = AuthState.authenticated(session);
      return true;
    } catch (error) {
      state = AuthState.unauthenticated(errorMessage: _messageFor(error));
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    state = state.copyWith(isSubmitting: true, clearError: true);

    try {
      final trimmedName = fullName?.trim();
      final session = await _registerUseCase(
        email: email.trim(),
        password: password,
        fullName: trimmedName == null || trimmedName.isEmpty
            ? null
            : trimmedName,
      );
      state = AuthState.authenticated(session);
      return true;
    } catch (error) {
      state = AuthState.unauthenticated(errorMessage: _messageFor(error));
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isSubmitting: true, clearError: true);
    await _logoutUseCase();
    state = const AuthState.unauthenticated();
  }

  String _messageFor(Object error) {
    if (error is ApiException) {
      return error.message;
    }
    return 'Something went wrong. Please try again.';
  }
}
