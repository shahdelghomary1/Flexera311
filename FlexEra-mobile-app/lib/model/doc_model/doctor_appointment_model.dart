class DoctorAppointmentModel {
  final String date;
  final String from;
  final String to;
  final UserInfo user;
  final String slotId;

  DoctorAppointmentModel({
    required this.date,
    required this.from,
    required this.to,
    required this.user,
    required this.slotId,
  });

  factory DoctorAppointmentModel.fromJson(Map<String, dynamic> json) {
    return DoctorAppointmentModel(
      date: json['date'] as String,
      from: json['from'] as String,
      to: json['to'] as String,
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      slotId: json['slotId'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'from': from,
      'to': to,
      'user': user.toJson(),
      'slotId': slotId,
    };
  }
}

class UserInfo {
  final String id;
  final String name;
  final String? image;
  final String? medicalFile;

  UserInfo({
    required this.id,
    required this.name,
    this.image,
    this.medicalFile,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] as String,
      name: json['name'] as String,
      image: json['image'] as String?,
      medicalFile: json['medicalFile'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      if (image != null) 'image': image,
      if (medicalFile != null) 'medicalFile': medicalFile,
    };
  }
}

class DoctorAppointmentsResponse {
  final String message;
  final List<DoctorAppointmentModel> appointments;

  DoctorAppointmentsResponse({
    required this.message,
    required this.appointments,
  });

  factory DoctorAppointmentsResponse.fromJson(Map<String, dynamic> json) {
    final appointmentsJson = json['appointments'] as List;
    final appointments = appointmentsJson
        .map((item) => DoctorAppointmentModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return DoctorAppointmentsResponse(
      message: json['message'] as String,
      appointments: appointments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'appointments': appointments.map((appointment) => appointment.toJson()).toList(),
    };
  }
}