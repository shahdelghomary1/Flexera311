class DoctorAppointmentsResponse {
  final bool success;
  final List<PatientData> patients;

  DoctorAppointmentsResponse({required this.success, required this.patients});

  factory DoctorAppointmentsResponse.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentsResponse(
      success: json['success'] ?? false,
      patients: (json['patients'] as List? ?? [])
          .map((e) => PatientData.fromJson(e))
          .toList(),
    );
  }
}

class PatientData {
  final UserInfo user;
  // دي هنستخدمها سواء كانت upcoming او past
  final List<AppointmentInfo> appointments;

  PatientData({required this.user, required this.appointments});

  factory PatientData.fromJson(Map<String, dynamic> json) {
    // الـ API بترجع يا "upcoming" يا "past"، فاحنا هنشوف مين فيهم اللي موجود
    List rawList = [];
    if (json['upcoming'] != null) rawList = json['upcoming'];
    else if (json['past'] != null) rawList = json['past'];

    return PatientData(
      user: UserInfo.fromJson(json['user'] ?? {}),
      appointments: rawList.map((e) => AppointmentInfo.fromJson(e)).toList(),
    );
  }
}

class UserInfo {
  final String id;
  final String name;
  final String? photo;

  UserInfo({required this.id, required this.name, this.photo});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'Unknown',
      photo: json['photo'],
    );
  }
}

class AppointmentInfo {
  final String scheduleId;
  final String dateString; // "2025-12-07-15"
  final String timeRange;  // "11:00 - 12:00"
  final String status;
  final String orderId;

  AppointmentInfo({
    required this.scheduleId,
    required this.dateString,
    required this.timeRange,
    required this.status,
    required this.orderId,
  });

  factory AppointmentInfo.fromJson(Map<String, dynamic> json) {
    return AppointmentInfo(
      scheduleId: json['scheduleId'] ?? '',
      dateString: json['date'] ?? '',
      timeRange: json['time'] ?? '',
      status: json['status'] ?? 'Pending',
      orderId: json['orderId'] ?? '',
    );
  }
}