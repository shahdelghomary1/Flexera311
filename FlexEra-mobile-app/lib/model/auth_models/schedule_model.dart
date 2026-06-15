import '../doc_model/time_slot_model.dart';

class ScheduleModel {
  String? id;
  String? dateString;
  DateTime? date;
  num? price;
  List<TimeSlotModel> timeSlots = [];

  ScheduleModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    dateString = json['date'];

    if (dateString != null) {
      try {
        date = DateTime.parse(dateString!.trim());
      } catch (e) {
        print("Date Error for $dateString: $e");
        date = DateTime.now();
      }
    }

    if (json['doctor'] != null) {
      if (json['doctor'] is Map) {
        price = json['doctor']['price'];
      } else {
        price = 0;
      }
    }

    if (json['timeSlots'] != null) {
      json['timeSlots'].forEach((v) {
        timeSlots.add(TimeSlotModel.fromJson(v));
      });
    }
  }
}
