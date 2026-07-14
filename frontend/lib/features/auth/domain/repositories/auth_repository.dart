import '../entities/auth_session.dart';
import '../entities/auth_tokens.dart';
import '../entities/auth_user.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login({
    required String email,
    required String password,
  });

  Future<AuthSession> register({
    required String email,
    required String password,
    String? fullName,
  });

  Future<AuthSession?> restoreSession();

  Future<AuthTokens> refreshToken();

  Future<AuthUser> getCurrentUser();

  Future<String> getValidAccessToken();

  Future<void> logout();
}
