import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_app/models/models.dart';
import 'package:flutter_app/utils/local_endpoints.dart';
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

      if (response.statusCode == 200) {
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

  static Future<String?> getStoredToken() async {
    // Implement your logic to retrieve the stored token
    // This could be from shared preferences, secure storage, etc.
    // For now, return null to indicate no token is stored.
    return null;
  }
}
