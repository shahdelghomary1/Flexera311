import 'package:dio/dio.dart';
import 'package:flexera/core/network/constants.dart';
import 'package:flexera/core/network/dio_helper.dart';
import 'package:flexera/core/network/end_points.dart';
import 'package:flexera/model/auth_models/schedule_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/network/cache_helper.dart';
import '../model/doc_model/time_slot_model.dart';

class AppointmentViewModel extends ChangeNotifier {
  List<ScheduleModel> _schedules = [];
  bool _isScheduleLoading = false;
  String _errorMessage = '';

  List<ScheduleModel> get schedules => _schedules;

  bool get isScheduleLoading => _isScheduleLoading;

  String get errorMessage => _errorMessage;

  int _selectedDateIndex = 0;
  int? _selectedTimeIndex;

  int get selectedDateIndex => _selectedDateIndex;

  int? get selectedTimeIndex => _selectedTimeIndex;

  List<DateTime> get nextDays => availableDates;

  List<DateTime> get availableDates {
    if (_schedules.isEmpty) return [];

    final uniqueDates = <String>{};
    final result = <DateTime>[];

    for (var schedule in _schedules) {
      if (schedule.date != null) {
        String dateKey =
            "${schedule.date!.year}-${schedule.date!.month}-${schedule.date!.day}";

        if (uniqueDates.add(dateKey)) {
          result.add(schedule.date!);
        }
      }
    }
    result.sort((a, b) => a.compareTo(b));
    return result;
  }

  List<TimeSlotModel> get availableTimes {
    if (availableDates.isEmpty || _selectedDateIndex >= availableDates.length) {
      return [];
    }

    final selectedDate = availableDates[_selectedDateIndex];

    final matchingSchedules = _schedules.where((s) =>
        s.date != null &&
        s.date!.year == selectedDate.year &&
        s.date!.month == selectedDate.month &&
        s.date!.day == selectedDate.day);

    final Map<String, TimeSlotModel> uniqueSlots = {};

    for (var schedule in matchingSchedules) {
      for (var slot in schedule.timeSlots) {
        if (slot.from != null && slot.from!.isNotEmpty) {
          uniqueSlots[slot.from!] = slot;
        }
      }
    }

    List<TimeSlotModel> result = uniqueSlots.values.toList();

    result.sort((a, b) {
      return (a.from ?? "").compareTo(b.from ?? "");
    });

    return result;
  }

  double _fetchedPrice = 0.0;

  double get consultationFee => _fetchedPrice > 0 ? _fetchedPrice : 250.0;

  double get adminFee => 0.0;

  double get totalAmount => consultationFee + adminFee;

  bool _hasSavedCard = false;
  String _cardHolderName = "";
  String _cardLast4Digits = "";
  bool _isCardSelected = true;
  bool isBookingLoading = false;

  bool get isCardSelected => _isCardSelected;

  String get cardHolderName => _cardHolderName;

  String get cardLast4Digits => _cardLast4Digits;

  void selectDate(int index) {
    _selectedDateIndex = index;
    _selectedTimeIndex = null;
    notifyListeners();
  }

  void selectTime(int index) {
    _selectedTimeIndex = index;
    notifyListeners();
  }

  Future<void> fetchDoctorSchedule(String doctorId) async {
    _isScheduleLoading = true;
    _schedules = [];
    _fetchedPrice = 0.0;
    _selectedDateIndex = 0;
    _selectedTimeIndex = null;
    notifyListeners();

    debugPrint("Searching Schedules for Doctor ID: $doctorId");

    try {
      Response response = await DioHelper.getData(
        url: EndPoints.doctorSchedule,
        query: {
          'doctorId': doctorId,
        },
        token: token,
      );

      debugPrint(" GET Response Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        List<dynamic> data = response.data['schedules'];
        if (data.isNotEmpty) {
          debugPrint("🔥🔥 SERVER RAW DATA: ${data.first}");
        } else {
          debugPrint("🔥🔥 SERVER RAW DATA: List is Empty");
        }
        _schedules = data.map((e) => ScheduleModel.fromJson(e)).toList();

        debugPrint(" Total Schedules Loaded: ${_schedules.length}");
        for (var s in _schedules) {
          debugPrint(" Date: ${s.date} | Slots Count: ${s.timeSlots.length}");
          if (s.timeSlots.isNotEmpty) {
            debugPrint("First Slot: ${s.timeSlots.first.from}");
          }
        }

        if (_schedules.isNotEmpty && _schedules.first.price != null) {
          _fetchedPrice = _schedules.first.price!.toDouble();
        }
      }
    } on DioException catch (e) {
      _errorMessage = e.response?.data['message'] ?? "Error fetching schedule";
      debugPrint("Schedule Error: $_errorMessage");
    } catch (e) {
      _errorMessage = "Something went wrong";
      debugPrint("Generic Error: $e");
    } finally {
      _isScheduleLoading = false;
      notifyListeners();
    }
  }

  Future<bool> confirmBooking() async {
    isBookingLoading = true;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 1));
      isBookingLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      isBookingLoading = false;
      notifyListeners();
      return false;
    }
  }

  void toggleCardSelection() {
    _isCardSelected = !_isCardSelected;
    notifyListeners();
  }

  Future<bool> checkUserHasCard() async {
    await Future.delayed(const Duration(seconds: 1));
    return _hasSavedCard;
  }

  void setPaymentDetails({required String name, required String cardNumber}) {
    _cardHolderName = name;
    if (cardNumber.length >= 4) {
      String cleanNumber = cardNumber.replaceAll(' ', '');
      if (cleanNumber.length >= 4) {
        _cardLast4Digits = cleanNumber.substring(cleanNumber.length - 4);
      } else {
        _cardLast4Digits = cleanNumber;
      }
    } else {
      _cardLast4Digits = cardNumber;
    }
    notifyListeners();
  }

  bool isPaymobLoading = false;

  Future<String?> initiatePaymobBooking({required String doctorId}) async {
    if (_selectedTimeIndex == null || availableDates.isEmpty) {
      debugPrint("No date/time selected");
      return null;
    }

    isPaymobLoading = true;
    notifyListeners();

    try {
      String? userToken = CacheHelper.getData(key: 'token');

      DateTime selectedDateObj = availableDates[_selectedDateIndex];

      String selectedTimeString =
          availableTimes[_selectedTimeIndex!].from ?? "";

      String apiDate = DateFormat('yyyy-MM-dd').format(selectedDateObj);

      String apiTime = selectedTimeString;

      Map<String, dynamic> requestBody = {
        "doctorId": doctorId,
        "date": apiDate,
        "from": apiTime
      };

      debugPrint("🚀 Sending to API: $requestBody");

      final response = await DioHelper.postData(
        url: EndPoints.paymobInit,
        data: requestBody,
        token: userToken,
      );

      isPaymobLoading = false;
      notifyListeners();

      debugPrint("✅ API Response: ${response.data}");

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['payment_url'];
      } else {
        String msg = response.data['message'] ?? "Unknown Error";
        debugPrint("⚠️ API Error Message: $msg");
        return null;
      }
    } catch (e) {
      isPaymobLoading = false;
      notifyListeners();

      if (e is DioException && e.response != null) {
        String errorMsg = e.response?.data['message'] ?? "Error";
        debugPrint("❌ Server Error ($errorMsg)");
      } else {
        debugPrint("❌ Generic Error: $e");
      }
      return null;
    }
  }
}
