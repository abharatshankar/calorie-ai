class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.isVerified,
    required this.joinedAt,
    this.fullName,
  });

  final String id;
  final String email;
  final String? fullName;
  final bool isVerified;
  final DateTime joinedAt;

  String get displayName {
    final name = fullName?.trim();
    if (name != null && name.isNotEmpty) {
      return name;
    }
    return 'Calorie AI User';
  }
}
