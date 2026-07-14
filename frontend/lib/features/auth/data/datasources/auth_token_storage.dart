import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/secure_storage_service.dart';
import '../models/auth_tokens_model.dart';

final authTokenStorageProvider = Provider<AuthTokenStorage>(
  (ref) => AuthTokenStorage(ref.watch(secureStorageServiceProvider)),
);

class AuthTokenStorage {
  const AuthTokenStorage(this._storage);

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';
  static const _tokenTypeKey = 'auth.token_type';
  static const _expiresAtKey = 'auth.expires_at';

  final SecureStorageService _storage;

  Future<AuthTokensModel?> readTokens() async {
    final accessToken = await _storage.read(_accessTokenKey);
    final refreshToken = await _storage.read(_refreshTokenKey);
    final tokenType = await _storage.read(_tokenTypeKey);
    final expiresAt = await _storage.read(_expiresAtKey);

    if (accessToken == null ||
        refreshToken == null ||
        tokenType == null ||
        expiresAt == null) {
      return null;
    }

    return AuthTokensModel.fromStorage(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresAt: expiresAt,
    );
  }

  Future<void> saveTokens(AuthTokensModel tokens) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: tokens.accessToken),
      _storage.write(key: _refreshTokenKey, value: tokens.refreshToken),
      _storage.write(key: _tokenTypeKey, value: tokens.tokenType),
      _storage.write(
        key: _expiresAtKey,
        value: tokens.expiresAt.toIso8601String(),
      ),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(_accessTokenKey),
      _storage.delete(_refreshTokenKey),
      _storage.delete(_tokenTypeKey),
      _storage.delete(_expiresAtKey),
    ]);
  }
}
