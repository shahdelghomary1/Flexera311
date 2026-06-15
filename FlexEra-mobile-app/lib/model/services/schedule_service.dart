import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flexera/core/network/cache_helper.dart';
import 'package:flexera/core/network/dio_helper.dart';
import 'package:flexera/model/doc_model/doc_schedule_model.dart';
import 'package:flexera/model/doc_model/doctor_appointment_model.dart';

import '../doc_model/time_slot_model.dart';

class ScheduleService {
  static Future<List<DocScheduleModel>> getMyAppointments() async {
    try {
      final token = CacheHelper.getData(key: 'token');

      debugPrint('📡 GET /api/schedule/my-appointments');
      debugPrint('🔑 Token: ${token != null ? "Present" : "Missing"}');

      final response = await DioHelper.getData(
        url: 'schedule/my-appointments',
        token: token,
      );

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final schedules = data['schedules'] as List;

        debugPrint('📋 Found ${schedules.length} schedule(s)');

        return schedules
            .map((schedule) =>
                DocScheduleModel.fromJson(schedule as Map<String, dynamic>))
            .toList();
      } else {
        // Handle error responses
        final responseData = response.data;
        String errorMessage = 'Failed to fetch appointments';

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException Status: ${e.response?.statusCode}');
      debugPrint('❌ DioException Data: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String message = 'Error fetching appointments';
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          message = responseData['message'];
        }

        if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 403) {
          throw Exception('Forbidden: Invalid doctor role');
        } else {
          throw Exception(message);
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  static Future<DocScheduleModel> createSchedule({
    required String doctorId,
    required String date,
    required List<TimeSlotModel> timeSlots,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      final requestData = {
        'doctorId': doctorId,
        'date': date,
        'timeSlots': timeSlots
            .map((slot) => {
                  'from': slot.from,
                  'to': slot.to,
                })
            .toList(),
      };

      debugPrint('📡 POST /api/schedule');
      debugPrint('🔑 Token: ${token != null ? "Present" : "Missing"}');
      debugPrint('📦 Request Data: $requestData');

      final response = await DioHelper.postData(
        url: 'schedule',
        token: token,
        data: requestData,
      );

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data as Map<String, dynamic>;
        final schedule = data['schedule'] as Map<String, dynamic>;
        return DocScheduleModel.fromJson(schedule);
      } else {
        // Handle error responses (400, 404, etc.)
        final responseData = response.data;
        String errorMessage = 'Failed to create schedule';

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException Status: ${e.response?.statusCode}');
      debugPrint('❌ DioException Data: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String message = 'Error creating schedule';
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          message = responseData['message'];
        }

        if (statusCode == 400) {
          // Check if it's a duplicate time slot error
          if (message.contains('already exists')) {
            throw Exception(message);
          }
          throw Exception(message);
        } else if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 409) {
          throw Exception(message);
        } else {
          throw Exception(message);
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  static Future<DocScheduleModel> updateSchedule({
    required String scheduleId,
    required String date,
    required List<TimeSlotModel> timeSlots,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      final response = await DioHelper.putData(
        url: 'schedule/$scheduleId',
        token: token,
        data: {
          'date': date,
          'timeSlots': timeSlots
              .map((slot) => {
                    'from': slot.from,
                    'to': slot.to,
                  })
              .toList(),
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final schedule = data['schedule'] as Map<String, dynamic>;
        return DocScheduleModel.fromJson(schedule);
      } else {
        throw Exception('Failed to update schedule');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message =
            e.response!.data['message'] ?? 'Error updating schedule';

        if (statusCode == 400) {
          throw Exception('Validation error: $message');
        } else if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 403) {
          throw Exception('Forbidden: No permission to edit this schedule');
        } else if (statusCode == 404) {
          throw Exception('Schedule not found');
        } else if (statusCode == 409) {
          throw Exception('Conflicting time slots: $message');
        } else {
          throw Exception(message);
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  static Future<DocScheduleModel> deleteTimeSlot({
    required String scheduleId,
    required String slotId,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      debugPrint('🗑️ DELETE /api/doctors/schedule/$scheduleId/slot/$slotId');
      debugPrint('🔑 Token: ${token != null ? "Present" : "Missing"}');

      final response = await DioHelper.deleteData(
        url: 'doctors/schedule/$scheduleId/slot/$slotId',
        token: token,
      );

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final schedule = data['schedule'] as Map<String, dynamic>;
        return DocScheduleModel.fromJson(schedule);
      } else {
        // Handle error responses
        final responseData = response.data;
        String errorMessage = 'Failed to delete time slot';

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException Status: ${e.response?.statusCode}');
      debugPrint('❌ DioException Data: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String message = 'Error deleting time slot';
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          message = responseData['message'];
        }

        if (statusCode == 400) {
          throw Exception(message);
        } else if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 404) {
          throw Exception('Time slot not found');
        } else {
          throw Exception(message);
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  // static Future<void> deleteSchedule(String scheduleId) async {
  //   try {
  //     final token = CacheHelper.getData(key: 'token');

  //     final response = await DioHelper.deleteData(
  //       url: 'schedule/$scheduleId',
  //       token: token,
  //     );

  //     if (response.statusCode != 200) {
  //       throw Exception('Failed to delete schedule');
  //     }
  //   } on DioException catch (e) {
  //     if (e.response != null) {
  //       throw Exception(
  //           e.response!.data['message'] ?? 'Error deleting schedule');
  //     } else {
  //       throw Exception('Network error: ${e.message}');
  //     }
  //   }
  //   }
  // }

  // Fetch appointments for a specific doctor - POST approach (as specified in requirements)
  static Future<List<DoctorAppointmentModel>> getDoctorAppointments({
    required String doctorId,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      debugPrint('📡 POST /api/doctors/appointments');
      debugPrint('🔑 Token: ${token != null ? "Present" : "Missing"}');
      debugPrint('👨‍⚕️ Doctor ID: $doctorId');

      final response = await DioHelper.postData(
        url: 'doctors/appointments',
        token: token,
        data: {
          'doctorId': doctorId,
        },
      );

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final appointments = data['appointments'] as List;

        debugPrint('📋 Found ${appointments.length} appointment(s)');

        return appointments
            .map((appointment) => DoctorAppointmentModel.fromJson(
                appointment as Map<String, dynamic>))
            .toList();
      } else {
        // Handle error responses
        final responseData = response.data;
        String errorMessage = 'Failed to fetch appointments';

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException Status: ${e.response?.statusCode}');
      debugPrint('❌ DioException Data: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String message = 'Error fetching appointments';
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          message = responseData['message'];
        }

        if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 403) {
          throw Exception('Forbidden: Invalid doctor role');
        } else {
          throw Exception(message);
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  // Fetch appointments for a specific doctor - GET approach (alternative)
  static Future<List<DoctorAppointmentModel>> getDoctorAppointmentsGet({
    required String doctorId,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      debugPrint('📡 GET /api/doctors/appointments');
      debugPrint('🔑 Token: ${token != null ? "Present" : "Missing"}');
      debugPrint('👨‍⚕️ Doctor ID: $doctorId');

      final response = await DioHelper.getData(
        url: 'doctors/appointments',
        token: token,
        query: {
          'doctorId': doctorId,
        },
      );

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final appointments = data['appointments'] as List;

        debugPrint('📋 Found ${appointments.length} appointment(s)');

        return appointments
            .map((appointment) => DoctorAppointmentModel.fromJson(
                appointment as Map<String, dynamic>))
            .toList();
      } else {
        // Handle error responses
        final responseData = response.data;
        String errorMessage = 'Failed to fetch appointments';

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException Status: ${e.response?.statusCode}');
      debugPrint('❌ DioException Data: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String message = 'Error fetching appointments';
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          message = responseData['message'];
        }

        if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 403) {
          throw Exception('Forbidden: Invalid doctor role');
        } else {
          throw Exception(message);
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  // Update an existing exercise for a user
  static Future<DocScheduleModel> updateExercise({
    required String userId,
    required String exerciseId,
    int? sets,
    int? reps,
    String? notes,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      debugPrint('📡 PUT /api/doctors/users/$userId/exercises/$exerciseId');
      debugPrint('🔑 Token: ${token != null ? "Present" : "Missing"}');

      final requestBody = <String, dynamic>{};
      if (sets != null) requestBody['sets'] = sets;
      if (reps != null) requestBody['reps'] = reps;
      if (notes != null) requestBody['notes'] = notes;

      debugPrint('📦 Request Body: $requestBody');

      final response = await DioHelper.putData(
        url: 'doctors/users/$userId/exercises/$exerciseId',
        token: token,
        data: requestBody,
      );

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final schedule = data['schedule'] as Map<String, dynamic>;

        debugPrint('✅ Exercise updated successfully');

        return DocScheduleModel.fromJson(schedule);
      } else {
        // Handle error responses
        final responseData = response.data;
        String errorMessage = 'Failed to update exercise';

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException Status: ${e.response?.statusCode}');
      debugPrint('❌ DioException Data: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String message = 'Error updating exercise';
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          message = responseData['message'];
        }

        if (statusCode == 400) {
          throw Exception('Bad Request: $message');
        } else if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 403) {
          throw Exception('Forbidden: No permission to edit this exercise');
        } else if (statusCode == 404) {
          throw Exception('Not Found: User or exercise not found');
        } else if (statusCode == 409) {
          throw Exception('Conflict: $message');
        } else {
          throw Exception(message);
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  // Delete an exercise for a user
  static Future<DocScheduleModel> deleteExercise({
    required String userId,
    required String exerciseId,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      debugPrint('🗑️ DELETE /api/doctors/users/$userId/exercises/$exerciseId');
      debugPrint('🔑 Token: ${token != null ? "Present" : "Missing"}');

      final response = await DioHelper.deleteData(
        url: 'doctors/users/$userId/exercises/$exerciseId',
        token: token,
      );

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final schedule = data['schedule'] as Map<String, dynamic>;

        debugPrint('✅ Exercise deleted successfully');

        return DocScheduleModel.fromJson(schedule);
      } else {
        // Handle error responses
        final responseData = response.data;
        String errorMessage = 'Failed to delete exercise';

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException Status: ${e.response?.statusCode}');
      debugPrint('❌ DioException Data: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String message = 'Error deleting exercise';
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          message = responseData['message'];
        }

        if (statusCode == 400) {
          throw Exception('Bad Request: $message');
        } else if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 403) {
          throw Exception('Forbidden: No permission to delete this exercise');
        } else if (statusCode == 404) {
          // For 404 errors, return a default schedule or handle appropriately
          // This might happen if the exercise doesn't exist or the schedule is not found
          debugPrint('⚠️ 404 Error: $message - This might be expected in some cases');
          // We might want to handle this differently based on the actual error
          if (message.contains('Schedule not found')) {
            // In case of schedule not found, we might still want to update the UI
            // to reflect the deletion attempt
            throw Exception('Schedule not found for this doctor. Exercise may not exist.');
          } else {
            throw Exception('Not Found: User or exercise not found - $message');
          }
        } else {
          throw Exception(message);
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  // Batch update exercises for a user using PUT method
  static Future<DocScheduleModel> updateExercisesBatch({
    required String userId,
    required List<Map<String, dynamic>> exercises,
  }) async {
    try {
      final token = CacheHelper.getData(key: 'token');

      debugPrint('📡 PUT /api/doctors/users/$userId/exercises (batch update)');
      debugPrint('🔑 Token: ${token != null ? "Present" : "Missing"}');
      debugPrint('📝 Updating ${exercises.length} exercises');

      final response = await DioHelper.putData(
        url: 'doctors/users/$userId/exercises',
        token: token,
        data: {'exercises': exercises},
      );

      debugPrint('✅ Response Status: ${response.statusCode}');
      debugPrint('📥 Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final schedule = data['schedule'] as Map<String, dynamic>;

        debugPrint('✅ Batch exercises updated successfully');

        return DocScheduleModel.fromJson(schedule);
      } else {
        // Handle error responses
        final responseData = response.data;
        String errorMessage = 'Failed to update exercises';

        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }

        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException Status: ${e.response?.statusCode}');
      debugPrint('❌ DioException Data: ${e.response?.data}');

      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;

        String message = 'Error updating exercises';
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          message = responseData['message'];
        }

        if (statusCode == 400) {
          throw Exception('Bad Request: $message');
        } else if (statusCode == 401) {
          throw Exception('Unauthorized: Please login again');
        } else if (statusCode == 403) {
          throw Exception('Forbidden: No permission to edit these exercises');
        } else if (statusCode == 404) {
          throw Exception('Not Found: User not found');
        } else if (statusCode == 409) {
          throw Exception('Conflict: $message');
        } else {
          throw Exception(message);
        }
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
