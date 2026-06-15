class TimeSlotModel {
  final String? id;
  final String? from;
  final String? to;
  final bool isBooked;

  TimeSlotModel({
    this.id,
    required this.from,
    required this.to,
    this.isBooked = false,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['_id'] as String?,
      from: json['from'] as String?,
      to: json['to'] as String?,
      isBooked: json['isBooked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'from': from,
      'to': to,
    };
  }

  TimeSlotModel copyWith({
    String? id,
    String? from,
    String? to,
  }) {
    return TimeSlotModel(
      id: id ?? this.id,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }
}
