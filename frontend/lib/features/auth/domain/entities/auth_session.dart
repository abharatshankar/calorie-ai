import 'auth_tokens.dart';
import 'auth_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.tokens,
  });

  final AuthUser user;
  final AuthTokens tokens;
}
