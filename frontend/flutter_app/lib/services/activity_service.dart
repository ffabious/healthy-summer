import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_app/models/models.dart';
import 'package:flutter_app/utils/endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/secure_storage.dart';

class ActivityService {
  final Dio _dio;

  ActivityService() : _dio = Dio() {
    if (kIsWeb) {
      _dio.options.baseUrl = activityUrl;
    } else {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
      _dio.options.baseUrl = activityUrl;
    }
  }

  Future<PostActivityResponseModel> postActivity(
    PostActivityRequestModel activity,
  ) async {
    try {
      final response = await _dio.post(
        postActivityEndpoint,
        data: activity.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return PostActivityResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to post activity: ${e.response?.data}');
      } else {
        throw Exception('Failed to post activity: ${e.message}');
      }
    }
  }

  Future<GetActivitiesResponseModel> getActivities() async {
    try {
      final response = await _dio.get(
        getActivitiesEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return GetActivitiesResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to get activities: ${e.response?.data}');
      } else {
        throw Exception('Failed to get activities: ${e.message}');
      }
    }
  }

  Future<PostStepEntryResponseModel> createStepEntry(
    PostStepEntryRequestModel stepEntry,
  ) async {
    try {
      final response = await _dio.post(
        postStepEntryEndpoint,
        data: stepEntry.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return PostStepEntryResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to create step entry: ${e.response?.data}');
      } else {
        throw Exception('Failed to create step entry: ${e.message}');
      }
    }
  }

  Future<ActivityModel> updateActivity(
    String activityId,
    UpdateActivityRequestModel activity,
  ) async {
    try {
      final response = await _dio.put(
        '$updateActivityEndpoint/$activityId',
        data: activity.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return ActivityModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to update activity: ${e.response?.data}');
      } else {
        throw Exception('Failed to update activity: ${e.message}');
      }
    }
  }

  Future<void> deleteActivity(String activityId) async {
    try {
      await _dio.delete(
        '$deleteActivityEndpoint/$activityId',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to delete activity: ${e.response?.data}');
      } else {
        throw Exception('Failed to delete activity: ${e.message}');
      }
    }
  }

  Future<List<StepEntryModel>> getStepEntries({int days = 30}) async {
    try {
      final response = await _dio.get(
        '$getStepEntriesEndpoint?days=$days',
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );

      final List<dynamic> data = response.data;
      return data.map((item) => StepEntryModel.fromJson(item)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to get step entries: ${e.response?.data}');
      } else {
        throw Exception('Failed to get step entries: ${e.message}');
      }
    }
  }

  Future<ActivityStatsModel> getActivityStats() async {
    try {
      final response = await _dio.get(
        getActivityStatsEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return ActivityStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to get activity stats: ${e.response?.data}');
      } else {
        throw Exception('Failed to get activity stats: ${e.message}');
      }
    }
  }
}
