import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_app/models/models.dart';
import 'package:flutter_app/utils/endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_app/core/secure_storage.dart';

class NutritionService {
  final Dio _dio;

  NutritionService() : _dio = Dio() {
    if (kIsWeb) {
      _dio.options.baseUrl = nutritionUrl;
    } else {
      (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      };
      _dio.options.baseUrl = nutritionUrl;
    }
  }

  Future<PostMealResponseModel> postMeal(PostMealRequestModel meal) async {
    try {
      final response = await _dio.post(
        postMealEndpoint,
        data: meal.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return PostMealResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to post meal: ${e.response?.data}');
      } else {
        throw Exception('Failed to post meal: ${e.message}');
      }
    }
  }

  Future<GetMealsResponseModel> getMeals() async {
    try {
      final response = await _dio.get(
        getMealsEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return GetMealsResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to get meals: ${e.response?.data}');
      } else {
        throw Exception('Failed to get meals: ${e.message}');
      }
    }
  }

  Future<PostWaterIntakeResponseModel> postWaterIntake(
    PostWaterIntakeRequestModel waterIntake,
  ) async {
    try {
      final response = await _dio.post(
        postWaterEndpoint,
        data: waterIntake.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return PostWaterIntakeResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to post water intake: ${e.response?.data}');
      } else {
        throw Exception('Failed to post water intake: ${e.message}');
      }
    }
  }

  Future<NutritionStats> getNutritionStats() async {
    try {
      final response = await _dio.get(
        getNutritionStatsEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return NutritionStats.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to get nutrition stats: ${e.response?.data}');
      } else {
        throw Exception('Failed to get nutrition stats: ${e.message}');
      }
    }
  }

  Future<GetWaterEntriesResponseModel> getWaterEntries() async {
    try {
      final response = await _dio.get(
        getWaterEndpoint,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return GetWaterEntriesResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to get water entries: ${e.response?.data}');
      } else {
        throw Exception('Failed to get water entries: ${e.message}');
      }
    }
  }

  Future<void> deleteMeal(String mealId) async {
    try {
      await _dio.delete(
        '$getMealsEndpoint/$mealId',
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
        throw Exception('Failed to delete meal: ${e.response?.data}');
      } else {
        throw Exception('Failed to delete meal: ${e.message}');
      }
    }
  }

  Future<PostMealResponseModel> updateMeal(
    String mealId,
    PostMealRequestModel meal,
  ) async {
    try {
      final response = await _dio.put(
        '$getMealsEndpoint/$mealId',
        data: meal.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return PostMealResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to update meal: ${e.response?.data}');
      } else {
        throw Exception('Failed to update meal: ${e.message}');
      }
    }
  }

  Future<void> deleteWaterEntry(String waterEntryId) async {
    try {
      await _dio.delete(
        '$getWaterEndpoint/$waterEntryId',
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
        throw Exception('Failed to delete water entry: ${e.response?.data}');
      } else {
        throw Exception('Failed to delete water entry: ${e.message}');
      }
    }
  }

  Future<PostWaterIntakeResponseModel> updateWaterEntry(
    String waterEntryId,
    PostWaterIntakeRequestModel waterEntry,
  ) async {
    try {
      final response = await _dio.put(
        '$getWaterEndpoint/$waterEntryId',
        data: waterEntry.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${await SecureStorage.getToken()}',
          },
        ),
      );
      return PostWaterIntakeResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('Failed to update water entry: ${e.response?.data}');
      } else {
        throw Exception('Failed to update water entry: ${e.message}');
      }
    }
  }
}
