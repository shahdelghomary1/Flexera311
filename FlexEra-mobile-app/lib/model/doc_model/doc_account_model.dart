import 'package:dio/dio.dart';

class DoctorAccountResponse {
  String? message;
  DoctorAccountModel? doctor;

  DoctorAccountResponse({this.message, this.doctor});

  DoctorAccountResponse.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    doctor = json['doctor'] != null
        ? DoctorAccountModel.fromJson(json['doctor'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (message != null) data['message'] = message;
    if (doctor != null) data['doctor'] = doctor!.toJson();
    return data;
  }
}

class DoctorAccountModel {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? dateOfBirth;
  String? gender;
  String? image;
  String? createdAt;
  String? updatedAt;
  int? v;

  DoctorAccountModel({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.dateOfBirth,
    this.gender,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  DoctorAccountModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    dateOfBirth = json['dateOfBirth'];
    gender = json['gender'];
    image = json['image'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (id != null) data['_id'] = id;
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (dateOfBirth != null) data['dateOfBirth'] = dateOfBirth;
    if (gender != null) data['gender'] = gender;
    if (image != null) data['image'] = image;
    if (createdAt != null) data['createdAt'] = createdAt;
    if (updatedAt != null) data['updatedAt'] = updatedAt;
    if (v != null) data['__v'] = v;
    return data;
  }

  Future<FormData> toFormData({String? imageFile}) async {
    final Map<String, dynamic> formDataMap = {};

    if (name != null) formDataMap['name'] = name;
    if (email != null) formDataMap['email'] = email;
    if (phone != null) formDataMap['phone'] = phone;
    if (dateOfBirth != null) formDataMap['dateOfBirth'] = dateOfBirth;
    if (gender != null) formDataMap['gender'] = gender;

    if (imageFile != null && imageFile.isNotEmpty) {
      formDataMap['image'] = await MultipartFile.fromFile(
        imageFile,
        filename: imageFile.split('/').last,
      );
    }

    return FormData.fromMap(formDataMap);
  }
}
