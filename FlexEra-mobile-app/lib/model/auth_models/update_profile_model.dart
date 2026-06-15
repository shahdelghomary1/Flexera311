import 'package:dio/dio.dart';

class UpdateProfileModel {
  final String name;
  final String phone;
  final String gender;
  final String? dob;
  final String? height;
  final String? weight;
  final String? password;
  final String? imagePath;
  final String? medicalFilePath;

  UpdateProfileModel({
    required this.name,
    required this.phone,
    required this.gender,
    this.dob,
    this.height,
    this.weight,
    this.password,
    this.imagePath,
    this.medicalFilePath,
  });

  Future<FormData> toFormData() async {
    Map<String, dynamic> dataMap = {
      "name": name,
      "phone": phone,
      "gender": gender.toLowerCase(),
    };

    if (dob != null) dataMap["dob"] = dob;
    if (height != null && height!.isNotEmpty)
      dataMap["height"] = int.tryParse(height!);
    if (weight != null && weight!.isNotEmpty)
      dataMap["weight"] = int.tryParse(weight!);
    if (password != null && password!.isNotEmpty)
      dataMap["password"] = password;

    FormData formData = FormData.fromMap(dataMap);

    if (imagePath != null) {
      String fileName = imagePath!.split('/').last;
      formData.files.add(MapEntry(
        "image",
        await MultipartFile.fromFile(imagePath!, filename: fileName),
      ));
    }
    if (medicalFilePath != null) {
      String fileName = medicalFilePath!.split('/').last;
      formData.files.add(MapEntry(
        "medicalFile",
        await MultipartFile.fromFile(medicalFilePath!, filename: fileName),
      ));
    }

    return formData;
  }
}
