import 'package:flutter/material.dart';
import '../../core/network/dio_helper.dart';
import '../../core/network/end_points.dart';
import '../../core/network/cache_helper.dart';

class Appointment {
  final String id;
  final String patientName;
  final String patientAvatar;
  final DateTime date;
  final String time;
  String status;
  bool isCancelled;
  final String orderId;

  Appointment({
    required this.id,
    required this.patientName,
    required this.patientAvatar,
    required this.date,
    required this.time,
    required this.status,
    this.isCancelled = false,
    this.orderId = '',
  });

  String get dayOfWeek {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String get month {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[date.month - 1];
  }

  int get day => date.day;
}

class DocAppointmentViewModel extends ChangeNotifier {
  int _selectedTabIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  List<Appointment> _upcomingAppointments = [];
  List<Appointment> _pastAppointments = [];

  int get selectedTabIndex => _selectedTabIndex;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<Appointment> get currentAppointments {
    return _selectedTabIndex == 0 ? _upcomingAppointments : _pastAppointments;
  }

  DocAppointmentViewModel() {
    fetchAppointments();
  }

  void setTabIndex(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  Future<void> fetchAppointments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = CacheHelper.getData(key: 'token');

      final results = await Future.wait([
        DioHelper.getData(
            url: EndPoints.upcomingPaidAppointments, token: token),
        DioHelper.getData(url: EndPoints.pastPaidAppointments, token: token),
      ]);

      final upcomingResponse = results[0];
      final pastResponse = results[1];

      if (upcomingResponse.data != null &&
          upcomingResponse.data['success'] == true) {
        final List<dynamic> patients = upcomingResponse.data['patients'] ?? [];
        _upcomingAppointments = _parsePatientsList(patients, isUpcoming: true);
      }

      if (pastResponse.data != null && pastResponse.data['success'] == true) {
        final List<dynamic> patients = pastResponse.data['patients'] ?? [];
        _pastAppointments = _parsePatientsList(patients, isUpcoming: false);
      }
    } catch (e) {
      debugPrint('Error fetching appointments: $e');
      _errorMessage = 'Failed to load appointments';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Appointment> _parsePatientsList(List<dynamic> patients,
      {required bool isUpcoming}) {
    List<Appointment> appointmentsList = [];

    for (var patient in patients) {
      final Map<String, dynamic> user = patient['user'] ?? {};
      final String name = user['name'] ?? 'Unknown';

      debugPrint("👤 User Data for $name: $user");

      String? apiImage = user['photo'] ?? user['image'];

      final String avatar = (apiImage != null && apiImage.isNotEmpty)
          ? apiImage
          : 'assets/images/defult_doc.png';

      final List<dynamic> apps =
          isUpcoming ? (patient['upcoming'] ?? []) : (patient['past'] ?? []);

      for (var app in apps) {
        appointmentsList.add(Appointment(
          id: app['scheduleId'] ?? '',
          patientName: name,
          patientAvatar: avatar,
          date: _parseDateString(app['date']),
          time: app['time'] ?? '',
          status: app['status'] ?? (isUpcoming ? 'Confirmed' : 'Completed'),
          orderId: app['orderId'] ?? '',
          isCancelled:
              (app['status'] ?? '').toString().toLowerCase() == 'cancelled',
        ));
      }
    }
    return appointmentsList;
  }

  DateTime _parseDateString(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return DateTime.now();
    try {
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        int year = int.parse(parts[0]);
        int month = int.parse(parts[1]);
        int day = int.parse(parts[2]);
        int hour = parts.length > 3 ? int.parse(parts[3]) : 0;

        return DateTime(year, month, day, hour);
      }
    } catch (e) {
      debugPrint('Date parsing error: $e');
    }
    return DateTime.now();
  }

  void onCancelAppointment(BuildContext context, Appointment appointment) {
    final index =
        _upcomingAppointments.indexWhere((apt) => apt.id == appointment.id);
    if (index != -1) {
      _upcomingAppointments[index].status = 'Cancelled';
      _upcomingAppointments[index].isCancelled = true;
      notifyListeners();
    }
  }
}
