class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    this.fullName,
  });

  final String id;
  final String email;
  final String? fullName;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
}
