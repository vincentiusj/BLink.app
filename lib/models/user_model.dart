import 'dart:core';

class User {
  final String userId;
  final String fullName;
  final String email;
  final String role;
  final String? password;
  String? profileImage;

  User({required this.userId, required this.fullName, required this.email, this.password, required this.role, this.profileImage});
  factory User.fromJson(Map<String, dynamic> json, String email) {
    return User(
      userId: json['user_id'],
      fullName: json['full_name'],
      email: email,
      role: json['role'],
      profileImage: json['profile_image']
    );
  }

  @override
  String toString() {
    return 'User(userId: $userId, fullName: $fullName, email: $email, role: $role, profileImage: ${profileImage})';
  }




}
