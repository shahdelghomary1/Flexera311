import 'package:flexera/view_model/patients_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import '../view/widget/patient_profile_widgets.dart';
import '../model/services/exercise_service.dart';

class ExercisePlan {
  final String? id;
  final String name;
  final int? sets;
  final int? reps;
  final String notes;
  final String? category;

  ExercisePlan({
    this.id,
    required this.name,
    this.sets,
    this.reps,
    required this.notes,
    this.category,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'sets': sets ?? 0,
      'reps': reps ?? 0,
      'notes': notes,
      'category': category ?? 'General',
    };
  }

  factory ExercisePlan.fromJson(Map<String, dynamic> json) {
    return ExercisePlan(
      id: json['_id']?.toString(),
      name: json['name']?.toString() ?? '',
      sets: (json['sets'] is int)
          ? json['sets']
          : (int.tryParse(json['sets']?.toString() ?? '0') ?? 0),
      reps: (json['reps'] is int)
          ? json['reps']
          : (int.tryParse(json['reps']?.toString() ?? '0') ?? 0),
      notes: json['notes']?.toString() ?? '',
      category: json['category']?.toString(),
    );
  }
}

class PatientProfileViewModel extends ChangeNotifier {
  final Patient patient;

  PatientProfileViewModel({required this.patient}) {
    _loadAvailableExercisesAssets();
    _fetchFullProfile();
  }

  int _selectedNavIndex = 0;

  int get selectedNavIndex => _selectedNavIndex;

  final List<ExercisePlan> exercisePlans = [];
  Map<String, List<String>> _availableExercises = {};

  Map<String, List<String>> get availableExercises => _availableExercises;

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _medicalFileUrl;

  String get medicalFilePath => _medicalFileUrl ?? '';

  Future<void> _fetchFullProfile() async {
    if (patient.id == null) return;
    try {
      _isLoading = true;
      notifyListeners();

      final data = await ExerciseService.getUserFullProfile(
        userId: patient.id!,
      );

      if (data.containsKey('user') && data['user']['medicalFile'] != null) {
        _medicalFileUrl = data['user']['medicalFile'];
      }

      if (data.containsKey('exercises')) {
        final List list = data['exercises'];
        exercisePlans.clear();
        exercisePlans.addAll(list.map((e) => ExercisePlan.fromJson(e)));
      }
    } catch (e) {
      debugPrint('Error fetching full profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadAvailableExercisesAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/ex.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _availableExercises = jsonData.map((key, value) {
        return MapEntry(
          key,
          (value as List).map((item) => item['name'].toString()).toList(),
        );
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading exercises assets: $e');
    }
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void onNavBarTap(int index, BuildContext context) {
    setNavIndex(index);
    switch (index) {
      case 0:
        Navigator.of(context).popUntil((route) => route.isFirst);
        break;
      case 1:
        debugPrint('Settings selected');
        break;
      case 2:
        debugPrint('Profile selected');
        break;
    }
  }

  Future<void> onViewMedicalFile(BuildContext context) async {
    if (_medicalFileUrl == null || _medicalFileUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No medical file available')),
      );
      return;
    }

    final Uri url = Uri.parse(_medicalFileUrl!);
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch medical file')),
        );
      }
    } catch (e) {
      debugPrint('Error launching url: $e');
    }
  }

  void onAddExercise(BuildContext context) {
    if (_availableExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Loading exercises, please wait...')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddExerciseDialog(
        exercises: _availableExercises,
        onAdd: (category, exerciseName, sets, reps, notes) {
          exercisePlans.add(
            ExercisePlan(
              name: exerciseName,
              sets: sets,
              reps: reps,
              notes: notes,
              category: category,
            ),
          );
          notifyListeners();
        },
      ),
    );
  }

  void onEditExercise(BuildContext context, int index) {
    if (_availableExercises.isEmpty) return;

    final exerciseToEdit = exercisePlans[index];

    if (exerciseToEdit.id == null) {
      showDialog(
        context: context,
        builder: (context) => AddExerciseDialog(
          exercises: _availableExercises,
          initialExercise: exerciseToEdit,
          onAdd: (category, exerciseName, sets, reps, notes) {
            exercisePlans[index] = ExercisePlan(
              name: exerciseName,
              sets: sets,
              reps: reps,
              notes: notes,
              category: category,
            );
            notifyListeners();
          },
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AddExerciseDialog(
        exercises: _availableExercises,
        initialExercise: exerciseToEdit,
        onAdd: (category, exerciseName, sets, reps, notes) async {
          await _updateExerciseOnServer(
            context,
            exerciseToEdit.id!,
            sets,
            reps,
            notes,
            category,
          );
        },
      ),
    );
  }

  Future<void> _updateExerciseOnServer(
    BuildContext context,
    String exerciseId,
    int sets,
    int reps,
    String notes,
    String category,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final updatedList = await ExerciseService.updateExercise(
        userId: patient.id!,
        exerciseId: exerciseId,
        sets: sets,
        reps: reps,
        notes: notes,
        category: category,
      );

      if (updatedList.isNotEmpty) {
        exercisePlans.clear();
        exercisePlans.addAll(updatedList);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onDeleteExercise(BuildContext context, int index) async {
    if (index < 0 || index >= exercisePlans.length) return;

    final exerciseId = exercisePlans[index].id;

    if (exerciseId == null) {
      exercisePlans.removeAt(index);
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final updatedList = await ExerciseService.deleteExercise(
        userId: patient.id!,
        exerciseId: exerciseId,
      );

      if (updatedList.isNotEmpty) {
        exercisePlans.clear();
        exercisePlans.addAll(updatedList);
      } else {
        exercisePlans.removeAt(index);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exercise deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e')));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> onSaveChanges(BuildContext context) async {
    if (patient.id == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      List<ExercisePlan> newExercises = exercisePlans
          .where((e) => e.id == null)
          .toList();
      List<ExercisePlan> existingExercises = exercisePlans
          .where((e) => e.id != null)
          .toList();

      if (newExercises.isNotEmpty) {
        await ExerciseService.addExercises(
          userId: patient.id!,
          exercises: newExercises,
        );
      }

      if (existingExercises.isNotEmpty) {
        List<Future> updateTasks = [];

        for (var exercise in existingExercises) {
          updateTasks.add(
            ExerciseService.updateExercise(
              userId: patient.id!,
              exerciseId: exercise.id!,
              sets: exercise.sets ?? 0,
              reps: exercise.reps ?? 0,
              notes: exercise.notes,
              category: exercise.category ?? 'General',
            ),
          );
        }

        await Future.wait(updateTasks);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving: $e')));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onBackPressed(BuildContext context) {
    Navigator.of(context).pop();
  }
}
