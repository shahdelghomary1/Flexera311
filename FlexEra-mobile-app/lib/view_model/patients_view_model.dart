import 'package:flutter/material.dart';
import '../model/services/schedule_service.dart';
import '../model/doc_model/doctor_appointment_model.dart';

class Patient {
  final String? id;
  final String name;
  final String? avatarPath;
  final String? lastSession;
  final String? date;
  final String? time;
  final int? progress;

  Patient({
    this.id,
    required this.name,
    this.avatarPath,
    this.lastSession,
    this.date,
    this.time,
    this.progress,
  });
}

class PatientsViewModel extends ChangeNotifier {
  int _selectedNavIndex = 0;
  bool _isLoading = false;
  String? _errorMessage;

  int get selectedNavIndex => _selectedNavIndex;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<Patient> _patients = [];

  List<Patient> get patients => _patients;

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  // Fetch patients from doctor's appointments API
  Future<void> fetchPatients({required String doctorId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final appointments = await ScheduleService.getDoctorAppointmentsGet(
        doctorId: doctorId,
      );

      // Convert appointments to patients list
      Map<String, Patient> patientMap = {};

      for (var appointment in appointments) {
        final user = appointment.user;
        final userId = user.id;

        if (!patientMap.containsKey(userId)) {
          patientMap[userId] = Patient(
            id: user.id,
            name: user.name,
            avatarPath: user.image,
            lastSession: appointment.date,
            date: appointment.date,
            time: '${appointment.from} - ${appointment.to}',
            progress: null,
          );
        }
      }

      _patients = patientMap.values.toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      _patients = [];
      notifyListeners();
      debugPrint('Error fetching patients: $e');
    }
  }

  void onNavBarTap(int index, BuildContext context) {
    setNavIndex(index);

    switch (index) {
      case 0:
        Navigator.of(context).pop();
        break;
      case 1:
        debugPrint('Settings selected');
        break;
      case 2:
        debugPrint('Profile selected');
        break;
    }
  }

  void onEditPatient(BuildContext context, Patient patient) {
    debugPrint('Edit patient: ${patient.name}');
    Navigator.of(context).pushNamed('/patient-profile', arguments: patient);
  }

  void onPatientTap(BuildContext context, Patient patient) {
    debugPrint('Patient tapped: ${patient.name}');
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
