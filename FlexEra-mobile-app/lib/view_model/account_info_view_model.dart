import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../model/auth_models/update_profile_model.dart';
import '../model/repository/account_repository.dart';

class AccountInfoViewModel extends ChangeNotifier {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  String _selectedGender = 'Female';
  String? _profileImagePath;
  String? _medicalFilePath;
  String? _networkImageUrl;
  final ImagePicker _picker = ImagePicker();

  final AccountRepository _repository = AccountRepository();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String get selectedGender => _selectedGender;

  String? get profileImagePath => _profileImagePath;

  String? get networkImageUrl => _networkImageUrl;

  void setGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  String? _validateEmail(String email) {
    if (!email.endsWith('@gmail.com')) {
      return 'Email must be a Gmail address (@gmail.com)';
    }
  }

  Future<void> getMyData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _repository.getProfileData();

      final userData = response.data['user'] ?? response.data;

      fullNameController.text = userData['name'] ?? '';
      phoneController.text = userData['phone'] ?? '';
      emailController.text = userData['email'] ?? '';
      heightController.text = userData['height']?.toString() ?? '';
      weightController.text = userData['weight']?.toString() ?? '';

      if (userData['gender'] != null) {
        String g = userData['gender'].toString();
        _selectedGender = g[0].toUpperCase() + g.substring(1);
      }

      if (userData['dob'] != null) {
        String apiDate = userData['dob'];
        DateTime parsedDate = DateTime.parse(apiDate);
        dateOfBirthController.text =
            '${parsedDate.day}/${parsedDate.month}/${parsedDate.year}';
      }
      if (userData['image'] != null) {
        _networkImageUrl = userData['image'];
      }
    } catch (e) {
      debugPrint('Error fetching data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitForm(BuildContext context) async {
    double? height = double.tryParse(heightController.text);
    double? weight = double.tryParse(weightController.text);

    if (height != null && height > 250) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Height cannot exceed 250 cm"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (weight != null && weight > 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Weight cannot exceed 400 kg"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      String? apiDob = _formatDateForApi(dateOfBirthController.text);

      final model = UpdateProfileModel(
        name: fullNameController.text,
        phone: phoneController.text,
        gender: _selectedGender,
        dob: apiDob,
        height: heightController.text,
        weight: weightController.text,
        password: passwordController.text,
        imagePath: _profileImagePath,
        medicalFilePath: _medicalFilePath,
      );

      await _repository.updateAccount(model);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );

      // Navigator.of(context).pop();
    } catch (e) {
      if (e is DioException) {
        debugPrint("Server Error Data: ${e.response?.data}");
        debugPrint("Server Error Message: ${e.message}");
      } else {
        debugPrint("Update Error: $e");
      }
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _formatDateForApi(String date) {
    if (date.isEmpty) return null;
    try {
      var parts = date.split('/');
      if (parts.length == 3) {
        return "${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}";
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> pickMedicalFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'doc'],
    );
    if (result != null) {
      _medicalFilePath = result.files.single.path;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    dateOfBirthController.dispose();
    heightController.dispose();
    weightController.dispose();
    super.dispose();
  }
}
