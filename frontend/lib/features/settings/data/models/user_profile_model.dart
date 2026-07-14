import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.email,
    required super.isVerified,
    required super.joinedAt,
    super.fullName,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      isVerified: json['is_verified'] as bool? ?? false,
      joinedAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
