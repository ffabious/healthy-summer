import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_app/models/models.dart';
import 'package:flutter_app/utils/endpoints.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  late final Dio _dio;

  AuthService() {
    _dio = Dio(
      BaseOptions(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Accept self-signed certificate
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => host == addr;
      return client;
    };
  }

  Future<RegisterResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _dio.post(
        registerEndpoint,
        data: request.toJson(),
      );

      debugPrint("Response code: ${response.statusCode}");

      if (response.statusCode == 201) {
        return RegisterResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to register user');
      }
    } catch (e) {
      debugPrint('Error during registration: $e');
      rethrow;
    }
  }

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _dio.post(loginEndpoint, data: request.toJson());

      debugPrint("Response code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to login user');
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      rethrow;
    }
  }

  Future<UserModel> getUser(String token) async {
    try {
      final response = await _dio.get(
        userEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      debugPrint("Response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch user data');
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      rethrow;
    }
  }

  Future<ProfileModel> getProfile(String token) async {
    try {
      final response = await _dio.get(
        profileEndpoint,
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      debugPrint("Response code: ${response.statusCode}");
      if (response.statusCode == 200) {
        return ProfileModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch profile data');
      }
    } catch (e) {
      debugPrint('Error fetching profile data: $e');
      rethrow;
    }
  }

  Future<void> updateProfile(String token, ProfileModel profile) async {
    try {
      final response = await _dio.put(
        profileEndpoint,
        data: profile.toJson(),
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      debugPrint("Response code: ${response.statusCode}");
      if (response.statusCode != 200) {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }
}
