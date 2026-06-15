class NotificationModel {
  String? id;
  String? type;
  String? message;
  NotificationData? data;
  bool? isRead;
  String? createdAt;

  NotificationModel(
      {this.id,
      this.type,
      this.message,
      this.data,
      this.isRead,
      this.createdAt});

  NotificationModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    type = json['type'];
    message = json['message'];
    data =
        json['data'] != null ? NotificationData.fromJson(json['data']) : null;
    isRead = json['isRead'];
    createdAt = json['createdAt'];
  }
}

class NotificationData {
  String? doctorName;
  String? doctorId;


  NotificationData.fromJson(Map<String, dynamic> json) {
    doctorName = json['doctorName'];
    doctorId = json['doctorId'];
  }
}
