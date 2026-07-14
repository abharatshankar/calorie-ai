import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/auth_token_storage.dart';
import '../models/auth_tokens_model.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(authTokenStorageProvider),
  ),
);

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthTokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final tokens = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    await _tokenStorage.saveTokens(tokens);
    final user = await _remoteDataSource.getCurrentUser(tokens.accessToken);

    return AuthSession(user: user, tokens: tokens);
  }

  @override
  Future<AuthSession> register({
    required String email,
    required String password,
    String? fullName,
  }) async {
    await _remoteDataSource.register(
      email: email,
      password: password,
      fullName: fullName,
    );

    return login(email: email, password: password);
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final storedTokens = await _tokenStorage.readTokens();
    if (storedTokens == null) {
      return null;
    }

    try {
      final tokens = storedTokens.isAccessTokenExpired
          ? await _refreshWith(storedTokens.refreshToken)
          : storedTokens;
      final user = await _remoteDataSource.getCurrentUser(tokens.accessToken);

      return AuthSession(user: user, tokens: tokens);
    } catch (_) {
      await _tokenStorage.clearTokens();
      return null;
    }
  }

  @override
  Future<AuthTokens> refreshToken() async {
    final storedTokens = await _tokenStorage.readTokens();
    if (storedTokens == null) {
      throw StateError('No refresh token is available.');
    }

    return _refreshWith(storedTokens.refreshToken);
  }

  @override
  Future<AuthUser> getCurrentUser() async {
    final tokens = await _ensureFreshTokens();
    return _remoteDataSource.getCurrentUser(tokens.accessToken);
  }

  @override
  Future<String> getValidAccessToken() async {
    final tokens = await _ensureFreshTokens();
    return tokens.accessToken;
  }

  @override
  Future<void> logout() {
    return _tokenStorage.clearTokens();
  }

  Future<AuthTokensModel> _ensureFreshTokens() async {
    final storedTokens = await _tokenStorage.readTokens();
    if (storedTokens == null) {
      throw StateError('No authenticated session is available.');
    }

    if (!storedTokens.isAccessTokenExpired) {
      return storedTokens;
    }

    return _refreshWith(storedTokens.refreshToken);
  }

  Future<AuthTokensModel> _refreshWith(String refreshToken) async {
    final tokens = await _remoteDataSource.refreshToken(refreshToken);
    await _tokenStorage.saveTokens(tokens);
    return tokens;
  }
}
