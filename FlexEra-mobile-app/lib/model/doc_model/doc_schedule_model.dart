import 'time_slot_model.dart';

class UserInfo {
  final String id;
  final String name;

  UserInfo({
    required this.id,
    required this.name,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['_id'] as String,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
    };
  }
}

class DocScheduleModel {
  final String id;
  final String doctor;
  final String date;
  final List<TimeSlotModel> timeSlots;
  final List<dynamic> exercises;
  final String createdAt;
  final String updatedAt;
  final UserInfo? user;

  DocScheduleModel({
    required this.id,
    required this.doctor,
    required this.date,
    required this.timeSlots,
    required this.exercises,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory DocScheduleModel.fromJson(Map<String, dynamic> json) {
    return DocScheduleModel(
      id: json['_id'] as String,
      doctor: json['doctor'] as String,
      date: json['date'] as String,
      timeSlots: json['timeSlots'] != null
          ? (json['timeSlots'] as List)
              .map((slot) =>
                  TimeSlotModel.fromJson(slot as Map<String, dynamic>))
              .toList()
          : [],
      exercises: json['exercises'] as List? ?? [],
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      user: (json['user'] != null && json['user'] is Map<String, dynamic>)
          ? UserInfo.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'doctor': doctor,
      'date': date,
      'timeSlots': timeSlots.map((slot) => slot.toJson()).toList(),
      'exercises': exercises,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      if (user != null) 'user': user!.toJson(),
    };
  }

  DocScheduleModel copyWith({
    String? id,
    String? doctor,
    String? date,
    List<TimeSlotModel>? timeSlots,
    List<dynamic>? exercises,
    String? createdAt,
    String? updatedAt,
    UserInfo? user,
  }) {
    return DocScheduleModel(
      id: id ?? this.id,
      doctor: doctor ?? this.doctor,
      date: date ?? this.date,
      timeSlots: timeSlots ?? this.timeSlots,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}
