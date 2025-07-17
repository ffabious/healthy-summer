import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_app/models/models.dart';
import 'package:flutter_app/utils/endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/secure_storage.dart';

class SocialService {
  final Dio _dio;

  SocialService() : _dio = Dio() {
    if (kIsWeb) {
      _dio.options.baseUrl = socialUrl;
    } else {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
      _dio.options.baseUrl = socialUrl;
    }
  }

  Future<GetFeedResponseModel> getFeed() async {
    try {
      debugPrint('🌐 Calling GET /feed');
      final response = await _dio.get(
        '/feed',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data: ${response.data}');

      if (response.statusCode == 200) {
        return GetFeedResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to fetch feed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException in getFeed: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      debugPrint('❌ Exception in getFeed: $e');
      throw Exception('Failed to fetch feed: $e');
    }
  }
}
