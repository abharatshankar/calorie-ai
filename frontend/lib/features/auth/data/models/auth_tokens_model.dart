import '../../domain/entities/auth_tokens.dart';

class AuthTokensModel extends AuthTokens {
  const AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    required super.tokenType,
    required super.expiresAt,
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expires_in'];
    final expiresInSeconds = expiresIn is int ? expiresIn : 0;

    return AuthTokensModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String? ?? 'bearer',
      expiresAt: DateTime.now().add(Duration(seconds: expiresInSeconds)),
    );
  }

  factory AuthTokensModel.fromStorage({
    required String accessToken,
    required String refreshToken,
    required String tokenType,
    required String expiresAt,
  }) {
    return AuthTokensModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresAt: DateTime.parse(expiresAt),
    );
  }
}
