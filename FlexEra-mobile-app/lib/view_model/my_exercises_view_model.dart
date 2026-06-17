import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../core/network/cache_helper.dart';
import '../core/network/dio_helper.dart';
import '../core/network/end_points.dart';
import '../core/network/constants.dart';
import '../model/auth_models/my_exercises_model.dart';

class MyExercisesViewModel extends ChangeNotifier {
  ExercisePlan? _currentPlan;
  bool _isLoading = false;
  String _errorMessage = '';

  final String _completedExercisesKey = 'completed_exercises_ids';

  ExercisePlan? get currentPlan => _currentPlan;

  bool get isLoading => _isLoading;

  String get errorMessage => _errorMessage;

  double get progressPercent {
    if (_currentPlan == null ||
        _currentPlan!.exerciseItems == null ||
        _currentPlan!.exerciseItems!.isEmpty) {
      return 0.0;
    }
    int total = _currentPlan!.exerciseItems!.length;
    int completed =
        _currentPlan!.exerciseItems!.where((e) => e.isCompleted).length;
    return completed / total;
  }

  bool get isProgressGood => progressPercent >= 0.5;

  String get progressImage {
    return isProgressGood
        ? "assets/images/star.gif"
        : "assets/images/Tired.gif";
  }

  Future<void> fetchMyExercises() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      if (token == null || token!.isEmpty) {
        token = CacheHelper.getData(key: 'token');
      }

      debugPrint('📡 Fetching exercises from: ${EndPoints.myExercises}');

      Response response = await DioHelper.getData(
        url: EndPoints.myExercises,
        token: token,
      );

      debugPrint('📦 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        if (data['exercises'] != null) {
          List<dynamic> plansList = data['exercises'];

          if (plansList.isNotEmpty) {
            var activePlanJson = plansList.firstWhere(
              (plan) =>
                  plan['exercises'] != null &&
                  (plan['exercises'] as List).isNotEmpty,
              orElse: () => null,
            );

            activePlanJson ??= plansList.last;

            _currentPlan = ExercisePlan.fromJson(activePlanJson);

            debugPrint(
                '✅ Plan Loaded. Date: ${_currentPlan?.date}, Items: ${_currentPlan?.exerciseItems?.length}');

            _applyLocalProgress();
          } else {
            _currentPlan = null;
            _errorMessage = "No exercises assigned yet.";
          }
        }
      }
    } on DioException catch (e) {
      debugPrint('❌ Dio Error: ${e.response?.data}');
      _errorMessage = e.response?.data['message'] ?? "Connection Error";
    } catch (e) {
      debugPrint('❌ Error: $e');
      _errorMessage = "Something went wrong";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleExerciseCompletion(int index) async {
    if (_currentPlan == null ||
        _currentPlan!.exerciseItems == null ||
        index >= _currentPlan!.exerciseItems!.length) {
      return;
    }

    final exercise = _currentPlan!.exerciseItems![index];
    final bool oldState = exercise.isCompleted;

    exercise.isCompleted = !oldState;
    _saveLocalProgress();
    notifyListeners();

    try {
      if (exercise.id != null) {
        debugPrint('📡 Syncing status for: ${exercise.name}');

        await DioHelper.postData(
          url: EndPoints.isCompleted,
          token: token,
          data: {
            'exercise_id': exercise.id,
            'is_completed': exercise.isCompleted,
          },
        );
      }
    } catch (e) {
      debugPrint('❌ Sync failed: $e');
      exercise.isCompleted = oldState;
      _saveLocalProgress();
      notifyListeners();
    }
  }

  void _applyLocalProgress() {
    if (_currentPlan?.exerciseItems == null) return;

    List<String>? completedIds =
        CacheHelper.getStringList(key: _completedExercisesKey);

    if (completedIds != null && completedIds.isNotEmpty) {
      for (var item in _currentPlan!.exerciseItems!) {
        if ((item.id != null && completedIds.contains(item.id)) ||
            (item.name != null && completedIds.contains(item.name))) {
          item.isCompleted = true;
        }
      }
    }
  }

  void _saveLocalProgress() {
    if (_currentPlan?.exerciseItems == null) return;

    List<String> completedIds = [];
    for (var item in _currentPlan!.exerciseItems!) {
      if (item.isCompleted) {
        if (item.id != null) {
          completedIds.add(item.id!);
        } else if (item.name != null) {
          completedIds.add(item.name!);
        }
      }
    }

    CacheHelper.saveStringList(
        key: _completedExercisesKey, value: completedIds);
  }

  Future<void> markExerciseAsCompleted(String exerciseId) async {
    if (_currentPlan?.exerciseItems == null) return;

    try {
      final exercise = _currentPlan!.exerciseItems!.firstWhere(
            (e) => e.id == exerciseId,
      );

      exercise.isCompleted = true;

      _saveLocalProgress();
      notifyListeners();

      await DioHelper.postData(
        url: EndPoints.isCompleted,
        token: token,
        data: {
          'exercise_id': exerciseId,
          'is_completed': true,
        },
      );

      debugPrint('✅ Exercise marked completed');
    } catch (e) {
      debugPrint('❌ Failed to mark completed: $e');
    }
  }
}
