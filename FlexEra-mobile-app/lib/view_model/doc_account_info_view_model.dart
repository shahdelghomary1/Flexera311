import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../model/services/doc_account_service.dart';
import '../view/screens/doc_home_screen.dart';

class DocAccountInfoViewModel extends ChangeNotifier {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController doctorIdController = TextEditingController();

  String _selectedGender = 'Male';
  String? _profileImagePath;
  String? _currentImageUrl;
  final ImagePicker _picker = ImagePicker();
  final DocAccountService _docAccountService = DocAccountService();

  int _selectedNavIndex = 2;
  bool _isLoading = false;

  String get selectedGender => _selectedGender;

  String? get profileImagePath => _profileImagePath;

  String? get currentImageUrl => _currentImageUrl;

  int get selectedNavIndex => _selectedNavIndex;

  bool get isLoading => _isLoading;

  void setGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );

      if (image != null) {
        _profileImagePath = image.path;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking profile image: $e');
    }
  }

  Future<void> selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      dateOfBirthController.text =
          '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}';
      notifyListeners();
    }
  }

  bool _dataLoadedFromApi = false;

  Future<void> loadDoctorData() async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('📥 Loading doctor account data from API...');
      final accountResponse = await _docAccountService.getDoctorAccount();

      debugPrint('✅ API Response received');
      debugPrint('📦 Doctor data: ${accountResponse.doctor?.toJson()}');

      if (accountResponse.doctor != null) {
        final doctorData = accountResponse.doctor!;
        _dataLoadedFromApi = true;

        fullNameController.text = doctorData.name ?? '';
        emailController.text = doctorData.email ?? '';
        phoneController.text = doctorData.phone ?? '';
        doctorIdController.text = doctorData.id ?? '';
        _currentImageUrl = doctorData.image;

        if (doctorData.image != null && doctorData.image!.isNotEmpty) {
          debugPrint('🖼️ Image URL loaded: ${doctorData.image}');
        } else {
          debugPrint('🖼️ No image URL from API');
        }

        if (doctorData.gender != null) {
          String g = doctorData.gender!;
          _selectedGender = g[0].toUpperCase() + g.substring(1);
        }

        if (doctorData.dateOfBirth != null) {
          String apiDate = doctorData.dateOfBirth!;
          DateTime parsedDate = DateTime.parse(apiDate);
          dateOfBirthController.text =
              '${parsedDate.day.toString().padLeft(2, '0')}-${parsedDate.month.toString().padLeft(2, '0')}-${parsedDate.year}';
        }

        debugPrint('✅ Doctor data loaded successfully');
      } else {
        debugPrint('⚠️ No doctor data in response');
      }
    } catch (e) {
      debugPrint('❌ Error loading doctor data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void onNavBarTap(int index, BuildContext context) {
    setNavIndex(index);

    switch (index) {
      case 0:
        // Navigate to DocHomeScreen
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const DocHomeScreen()),
          (route) => false,
        );
        break;
      case 1:
        debugPrint('Settings selected');
        break;
      case 2:
        // Already on profile
        debugPrint('Profile selected');
        break;
    }
  }

  String? _validateEmail(String email) {
    if (!email.endsWith('@gmail.com')) {
      return 'Email must be a Gmail address (@gmail.com)';
    }
    return null;
  }

  String? _validatePhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanPhone.length != 11) {
      return 'Phone must be 11 digits (Egyptian number)';
    }
    return null;
  }

  Future<void> submitForm(BuildContext context) async {
    final emailError = _validateEmail(emailController.text);
    if (emailError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(emailError),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    final phoneError = _validatePhone(phoneController.text);
    if (phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(phoneError),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (!_dataLoadedFromApi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              '⚠️ Data not loaded from API! Please login again and reload this page.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
      debugPrint('❌ Cannot submit: Data not loaded from API');
      debugPrint('❌ Current name: ${fullNameController.text}');
      debugPrint('❌ This looks like placeholder data, not real API data');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      String? formattedDob = _formatDateForApi(dateOfBirthController.text);
      debugPrint('📅 Original DOB: ${dateOfBirthController.text}');
      debugPrint('📅 Formatted DOB: $formattedDob');

      await _docAccountService.updateDoctorAccount(
        name: fullNameController.text,
        email: emailController.text,
        phone: phoneController.text,
        dateOfBirth: formattedDob,
        gender: _selectedGender,
        imageFile: _profileImagePath,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Update Error: $e');
      String errorMessage = 'Failed to update account';

      final errorString = e.toString();
      if (errorString.contains('Email must be a Gmail address')) {
        errorMessage = 'Email must be a Gmail address (@gmail.com)';
      } else if (errorString
          .contains('Phone number must be a valid Egyptian number')) {
        errorMessage = 'Phone must be 11 digits (Egyptian number)';
      } else if (errorString.contains('Exception:')) {
        errorMessage = errorString.replaceAll('Exception:', '').trim();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String? _formatDateForApi(String date) {
    if (date.isEmpty) return null;
    try {
      // Input format: DD-MM-YYYY (from UI)
      // Output format: YYYY-MM-DD (ISO format for API)
      var parts = date.split('-');
      if (parts.length == 3) {
        String day = parts[0].padLeft(2, '0');
        String month = parts[1].padLeft(2, '0');
        String year = parts[2];

        // Convert to YYYY-MM-DD format
        return '$year-$month-$day';
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error formatting date: $e');
      return null;
    }
  }

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    dateOfBirthController.dispose();
    doctorIdController.dispose();
    super.dispose();
  }
}
