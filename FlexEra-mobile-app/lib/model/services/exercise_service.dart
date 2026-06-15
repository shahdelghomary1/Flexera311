import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../core/network/end_points.dart';
import '../../core/network/cache_helper.dart';
import '../../core/network/dio_helper.dart';
import '../../view_model/patient_profile_view_model.dart';

class ExerciseService {
  static Future<void> addExercises({
    required String userId,
    required List<ExercisePlan> exercises,
  }) async {
    final token = CacheHelper.getData(key: 'token');

    final exercisesData = exercises.map((e) => e.toJson()).toList();

    debugPrint('🚀 START REQUEST: Add Exercises');
    debugPrint('🔗 URL: ${EndPoints.userExercises(userId)}');
    debugPrint('📦 Body: {"exercises": $exercisesData}');

    try {
      final response = await DioHelper.postData(
        url: EndPoints.userExercises(userId),
        token: token,
        data: {'exercises': exercisesData},
      );

      debugPrint('✅ Server Response Code: ${response.statusCode}');

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(response.data['message'] ?? 'Failed to add exercises');
      }
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      debugPrint('❌ General Error: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUserFullProfile({
    required String userId,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      final response = await DioHelper.getData(
        url: EndPoints.userFullProfile(userId),
        token: token,
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return {};
    } catch (e) {
      debugPrint('❌ Error fetching full profile: $e');
      return {};
    }
  }

  static Future<List<ExercisePlan>> deleteExercise({
    required String userId,
    required String exerciseId,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      final response = await DioHelper.deleteData(
        url: EndPoints.specificExercise(userId, exerciseId),
        token: token,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['schedule'] != null && data['schedule']['exercises'] != null) {
          final List list = data['schedule']['exercises'];
          return list.map((e) => ExercisePlan.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error deleting exercise: $e');
      rethrow;
    }
  }

  static Future<List<ExercisePlan>> updateExercise({
    required String userId,
    required String exerciseId,
    required int sets,
    required int reps,
    required String notes,
    required String category,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      final response = await DioHelper.putData(
        url: EndPoints.specificExercise(userId, exerciseId),
        token: token,
        data: {
          "sets": sets,
          "reps": reps,
          "notes": notes,
          "category": category,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['schedule'] != null && data['schedule']['exercises'] != null) {
          final List list = data['schedule']['exercises'];
          return list.map((e) => ExercisePlan.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error updating exercise: $e');
      rethrow;
    }
  }

  static Future<List<ExercisePlan>> getExercises(
      {required String userId}) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      final response = await DioHelper.getData(
        url: 'doctors/users/$userId/exercises',
        token: token,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        List<dynamic> list = [];

        if (data is Map && data.containsKey('schedule')) {
          list = data['schedule']['exercises'] ?? [];
        } else if (data is Map && data.containsKey('exercises')) {
          list = data['exercises'] ?? [];
        }

        return list.map((e) => ExercisePlan.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('❌ Error getting exercises (Legacy): $e');
      return [];
    }
  }
}
