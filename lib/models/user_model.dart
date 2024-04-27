import 'dart:core';

class User {
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? password;
  final String? role;

  User({required this.userId, required this.fullName, required this.email, required this.phoneNumber, this.password, required this.role});
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      fullName: json['full_name'],
      email: json['email'],
      phoneNumber: json['phone_number'],
      role: json['role']
    );
  }
}
