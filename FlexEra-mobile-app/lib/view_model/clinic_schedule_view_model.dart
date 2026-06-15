import 'package:flutter/material.dart';
import '../core/network/cache_helper.dart';
import '../model/auth_models/schedule_model.dart';
import '../model/doc_model/time_slot_model.dart';
import '../model/services/schedule_service.dart';

class ClinicScheduleViewModel extends ChangeNotifier {
  DateTime _selectedDate = DateTime.now();
  DateTime _displayedMonth = DateTime.now();

  // List to store scheduled appointments
  List<ScheduleItem> _schedules = [];
  bool _isLoading = false;
  String? _errorMessage;

  DateTime get selectedDate => _selectedDate;

  DateTime get displayedMonth => _displayedMonth;

  List<ScheduleItem> get schedules => _schedules;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // Get schedules for the selected date
  List<ScheduleItem> getSchedulesForDate(DateTime date) {
    return _schedules.where((schedule) {
      return schedule.date.year == date.year &&
          schedule.date.month == date.month &&
          schedule.date.day == date.day;
    }).toList();
  }

  // Get upcoming appointments (from today onwards, grouped by date)
  Map<DateTime, List<ScheduleItem>> getUpcomingAppointments() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final upcomingSchedules = _schedules.where((schedule) {
      final scheduleDate =
          DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
      return scheduleDate.isAfter(todayDate) || scheduleDate == todayDate;
    }).toList();

    // Group by date
    final Map<DateTime, List<ScheduleItem>> groupedSchedules = {};
    for (var schedule in upcomingSchedules) {
      final dateKey =
          DateTime(schedule.date.year, schedule.date.month, schedule.date.day);
      if (!groupedSchedules.containsKey(dateKey)) {
        groupedSchedules[dateKey] = [];
      }
      groupedSchedules[dateKey]!.add(schedule);
    }

    // Sort by date
    final sortedKeys = groupedSchedules.keys.toList()..sort();
    final sortedMap = Map.fromEntries(
        sortedKeys.map((key) => MapEntry(key, groupedSchedules[key]!)));

    return sortedMap;
  }

  void selectDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void previousMonth() {
    _displayedMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month - 1,
    );
    notifyListeners();
  }

  void nextMonth() {
    _displayedMonth = DateTime(
      _displayedMonth.year,
      _displayedMonth.month + 1,
    );
    notifyListeners();
  }

  // Check if a date is selected
  bool isDateSelected(DateTime date) {
    return _selectedDate.year == date.year &&
        _selectedDate.month == date.month &&
        _selectedDate.day == date.day;
  }

  // Check if a date is today
  bool isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  // Add a new schedule (deprecated - use addScheduleApi)
  // This method is kept for backward compatibility with existing UI code
  void addScheduleLocal(DateTime date, TimeOfDay fromTime, TimeOfDay toTime) {
    final newSchedule = ScheduleItem(
      date: date,
      fromTime: fromTime,
      toTime: toTime,
    );
    _schedules.add(newSchedule);
    notifyListeners();
  }

  // Remove a schedule (deprecated - use deleteTimeSlot for API call)
  void removeScheduleLocal(ScheduleItem schedule) {
    _schedules.remove(schedule);
    notifyListeners();
  }

  // Delete a time slot via API
  Future<void> deleteTimeSlot(ScheduleItem schedule) async {
    // Check if we have the required IDs
    if (schedule.scheduleId == null || schedule.id == null) {
      throw Exception('Cannot delete: Missing schedule or slot ID');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      debugPrint('🗑️ Deleting time slot...');
      debugPrint('📋 Schedule ID: ${schedule.scheduleId}');
      debugPrint('🆔 Slot ID: ${schedule.id}');

      await ScheduleService.deleteTimeSlot(
        scheduleId: schedule.scheduleId!,
        slotId: schedule.id!,
      );

      debugPrint('✅ Time slot deleted successfully');

      // Refresh schedules after deleting
      await fetchSchedules();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error deleting time slot: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Update schedule time
  void updateScheduleTime(
      ScheduleItem schedule, TimeOfDay? fromTime, TimeOfDay? toTime) {
    final index = _schedules.indexOf(schedule);
    if (index != -1) {
      _schedules[index] = ScheduleItem(
        date: schedule.date,
        fromTime: fromTime ?? schedule.fromTime,
        toTime: toTime ?? schedule.toTime,
      );
      notifyListeners();
    }
  }

  // Fetch schedules from API
  Future<void> fetchSchedules() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final scheduleModels = await ScheduleService.getMyAppointments();

      // Convert API models to local ScheduleItem models
      _schedules = [];
      for (var scheduleModel in scheduleModels) {
        try {
          // Normalize date format to ensure proper parsing
          // Handle formats like "2025-12-1" by padding to "2025-12-01"
          String normalizedDate = scheduleModel.date;
          final dateParts = normalizedDate.split('-');
          if (dateParts.length == 3) {
            final year = dateParts[0].padLeft(4, '0');
            final month = dateParts[1].padLeft(2, '0');
            final day = dateParts[2].padLeft(2, '0');
            normalizedDate = '$year-$month-$day';
          }

          final date = DateTime.parse(normalizedDate);

          for (var timeSlot in scheduleModel.timeSlots) {
            try {
              // Parse time in format "HH:mm" (24-hour format)
              final fromParts = timeSlot.from!.split(':');
              final toParts = timeSlot.to!.split(':');

              // Ensure we have valid hour and minute parts
              if (fromParts.length >= 2 && toParts.length >= 2) {
                final fromHour = int.parse(fromParts[0]);
                final fromMinute = int.parse(fromParts[1]);
                final toHour = int.parse(toParts[0]);
                final toMinute = int.parse(toParts[1]);

                _schedules.add(ScheduleItem(
                  id: timeSlot.id,
                  scheduleId: scheduleModel.id,
                  date: date,
                  fromTime: TimeOfDay(
                    hour: fromHour,
                    minute: fromMinute,
                  ),
                  toTime: TimeOfDay(
                    hour: toHour,
                    minute: toMinute,
                  ),
                  userName: scheduleModel.user?.name,
                ));
              }
            } catch (timeSlotError) {
              debugPrint(
                  '⚠️ Skipping invalid time slot: ${timeSlot.from}-${timeSlot.to} - $timeSlotError');
            }
          }
        } catch (dateError) {
          debugPrint(
              '⚠️ Skipping schedule with invalid date: ${scheduleModel.date} - $dateError');
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a new schedule via API
  Future<void> createSchedule(
      DateTime date, List<TimeSlotModel> timeSlots) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get doctor ID from cache or token
      final doctorId = CacheHelper.getData(key: 'doctor_id');

      debugPrint('🔍 Creating schedule...');
      debugPrint('📋 Doctor ID from cache: $doctorId');

      if (doctorId == null) {
        throw Exception('Doctor ID not found. Please login again.');
      }

      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      debugPrint('📅 Date: $dateString');
      debugPrint(
          '⏰ Time Slots: ${timeSlots.map((s) => '${s.from} - ${s.to}').join(', ')}');

      final result = await ScheduleService.createSchedule(
        doctorId: doctorId,
        date: dateString,
        timeSlots: timeSlots,
      );

      debugPrint('✅ Schedule created successfully: ${result.id}');

      // Refresh schedules after creating
      await fetchSchedules();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error creating schedule: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Add a new schedule via API
  // Future<void> addScheduleApi(DateTime date, TimeOfDay fromTime, TimeOfDay toTime) async {
  //   final timeSlot = TimeSlotModel(
  //     from: '${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')}',
  //     to: '${toTime.hour.toString().padLeft(2, '0')}:${toTime.minute.toString().padLeft(2, '0')}',
  //   );
  //
  //   await createSchedule(date, [timeSlot]);
  // }

  // Update schedule via API
  Future<void> updateScheduleApi(
      String scheduleId, DateTime date, List<TimeSlotModel> timeSlots) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final dateString =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      await ScheduleService.updateSchedule(
        scheduleId: scheduleId,
        date: dateString,
        timeSlots: timeSlots,
      );

      // Refresh schedules after updating
      await fetchSchedules();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Delete schedule via API
  // Future<void> deleteSchedule(String scheduleId) async {
  //   _isLoading = true;
  //   _errorMessage = null;
  //   notifyListeners();

  //   try {
  //     await ScheduleService.deleteSchedule(scheduleId);

  //     // Refresh schedules after deleting
  //     await fetchSchedules();

  //     _isLoading = false;
  //     notifyListeners();
  //   } catch (e) {
  //     _errorMessage = e.toString();
  //     _isLoading = false;
  //     notifyListeners();
  //     rethrow;
  //   }
  // }

  // Initialize with sample data (for demo/fallback)
  void initializeSampleData() {
    final today = DateTime.now();
    _schedules = [
      ScheduleItem(
        date: DateTime(today.year, today.month, 11),
        fromTime: const TimeOfDay(hour: 9, minute: 0),
        toTime: const TimeOfDay(hour: 10, minute: 0),
      ),
      ScheduleItem(
        date: DateTime(today.year, today.month, 11),
        fromTime: const TimeOfDay(hour: 15, minute: 0),
        toTime: const TimeOfDay(hour: 18, minute: 30),
      ),
    ];
    notifyListeners();
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

class ScheduleItem {
  final String? id;
  final String? scheduleId;
  final DateTime date;
  final TimeOfDay fromTime;
  final TimeOfDay toTime;
  final String? userName;

  ScheduleItem({
    this.id,
    this.scheduleId,
    required this.date,
    required this.fromTime,
    required this.toTime,
    this.userName,
  });

  String getTimeRange() {
    return '${_formatTime(fromTime)} - ${_formatTime(toTime)}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
