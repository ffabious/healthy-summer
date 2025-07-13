import 'package:flutter_app/models/models.dart';

class RegisterRequestModel {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  RegisterRequestModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
    };
  }
}

class RegisterResponseModel {
  final String token;
  final UserModel user;
  final DateTime expiresAt;

  RegisterResponseModel({
    required this.token,
    required this.user,
    required this.expiresAt,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      token: json['token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
}
