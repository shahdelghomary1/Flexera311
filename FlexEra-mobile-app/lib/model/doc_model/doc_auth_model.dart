class DocAuthModel {
  String? message;
  String? token;
  DoctorModel? doctor;

  DocAuthModel.fromJson(Map<String, dynamic> json) {
    message = json['message'];
    token = json['token'];
    doctor =
        json['doctor'] != null ? DoctorModel.fromJson(json['doctor']) : null;
  }
}

class DoctorModel {
  String? id;
  String? name;
  String? email;
  String? phone;
  String? image;
  String? specialization;
  String? dateOfBirth;
  String? gender;
  String? createdAt;
  String? updatedAt;

  DoctorModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    name = json['name'];
    email = json['email'];
    phone = json['phone'];
    image = json['image'];
    specialization = json['specialization'];
    dateOfBirth = json['dateOfBirth'];
    gender = json['gender'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'specialization': specialization,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
