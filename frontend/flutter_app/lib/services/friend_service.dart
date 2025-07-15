import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_app/models/models.dart';
import 'package:flutter_app/utils/endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/secure_storage.dart';

class FriendService {
  final Dio _dio;

  FriendService() : _dio = Dio() {
    if (kIsWeb) {
      _dio.options.baseUrl = userUrl;
    } else {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
      _dio.options.baseUrl = userUrl;
    }
  }

  Future<GetFriendsResponseModel> getFriends() async {
    try {
      debugPrint('🌐 Calling GET /friends');
      final response = await _dio.get(
        '/friends',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      debugPrint('📥 Response status: ${response.statusCode}');
      debugPrint('📥 Response data type: ${response.data.runtimeType}');
      debugPrint('📥 Response data: ${response.data}');

      // Handle null or empty response
      List<dynamic> friendsData;
      if (response.data == null) {
        debugPrint('⚠️ Response data is null, using empty list');
        friendsData = [];
      } else if (response.data is List) {
        friendsData = response.data as List<dynamic>;
      } else {
        debugPrint(
          '⚠️ Unexpected response data type: ${response.data.runtimeType}',
        );
        friendsData = [];
      }

      final result = GetFriendsResponseModel.fromJson(friendsData);
      debugPrint('✅ Parsed ${result.friends.length} friends');
      return result;
    } on DioException catch (e) {
      debugPrint('❌ DioException: ${e.message}');
      debugPrint('❌ Response: ${e.response?.data}');
      if (e.response != null) {
        throw Exception('Failed to get friends: ${e.response?.data}');
      } else {
        throw Exception('Failed to get friends: ${e.message}');
      }
    } catch (e) {
      debugPrint('❌ General Exception: $e');
      rethrow;
    }
  }

  Future<FriendRequestModel> sendFriendRequest(
    SendFriendRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/friends/request',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return FriendRequestModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to send friend request: ${e.response?.data}');
      } else {
        throw Exception('Failed to send friend request: ${e.message}');
      }
    }
  }

  Future<GetFriendRequestsResponseModel> getPendingFriendRequests() async {
    try {
      final response = await _dio.get(
        '/friends/requests',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );

      // Handle null or empty response
      List<dynamic> requestsData;
      if (response.data == null) {
        debugPrint('⚠️ Response data is null, using empty list');
        requestsData = [];
      } else if (response.data is List) {
        requestsData = response.data as List<dynamic>;
      } else {
        debugPrint(
          '⚠️ Unexpected response data type: ${response.data.runtimeType}',
        );
        requestsData = [];
      }

      return GetFriendRequestsResponseModel.fromJson(requestsData);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to get friend requests: ${e.response?.data}');
      } else {
        throw Exception('Failed to get friend requests: ${e.message}');
      }
    }
  }

  Future<FriendRequestModel> respondToFriendRequest(
    RespondToFriendRequestModel request,
  ) async {
    try {
      final response = await _dio.post(
        '/friends/respond',
        data: request.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return FriendRequestModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Failed to respond to friend request: ${e.response?.data}',
        );
      } else {
        throw Exception('Failed to respond to friend request: ${e.message}');
      }
    }
  }

  Future<SearchUsersResponseModel> searchUsers(String query) async {
    try {
      final response = await _dio.get(
        '/search',
        queryParameters: {'q': query},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );

      // Handle null or empty response
      List<dynamic> usersData;
      if (response.data == null) {
        debugPrint('⚠️ Response data is null, using empty list');
        usersData = [];
      } else if (response.data is List) {
        usersData = response.data as List<dynamic>;
      } else {
        debugPrint(
          '⚠️ Unexpected response data type: ${response.data.runtimeType}',
        );
        usersData = [];
      }

      return SearchUsersResponseModel.fromJson(usersData);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to search users: ${e.response?.data}');
      } else {
        throw Exception('Failed to search users: ${e.message}');
      }
    }
  }
}
