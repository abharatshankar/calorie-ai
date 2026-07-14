class AuthTokens {
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final DateTime expiresAt;

  bool get isAccessTokenExpired {
    final refreshWindow = DateTime.now().add(const Duration(minutes: 1));
    return !expiresAt.isAfter(refreshWindow);
  }
}
