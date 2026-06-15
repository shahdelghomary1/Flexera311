import 'package:flutter/material.dart';
import '../widget/patient_profile_widgets.dart';
import '../../view_model/patients_view_model.dart';

class PatientProfileScreen extends StatelessWidget {
  final Patient patient;

  const PatientProfileScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return PatientProfileScaffold(patient: patient);
  }
}
