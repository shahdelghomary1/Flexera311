import 'package:flutter/material.dart';
import '../model/services/doc_auth_service.dart';

class DoctorIdViewModel extends ChangeNotifier {
  final DocAuthService _authService = DocAuthService();

  // Controllers for ID mode (6 digits)
  final List<TextEditingController> idControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  bool _showError = false;
  bool _isLoading = false;
  String _errorText = '';

  bool get showError => _showError;
  bool get isLoading => _isLoading;
  String get errorText => _errorText;

  // Check if ID fields are complete (all 6 digits filled)
  bool get isIdComplete => idControllers.every((c) => c.text.trim().isNotEmpty);

  // Get current ID as string
  String get currentId => idControllers.map((c) => c.text).join();

  // Clear error state
  void clearError() {
    _showError = false;
    _errorText = '';
    notifyListeners();
  }

  // Set error
  void setError(String error) {
    _showError = true;
    _errorText = error;
    notifyListeners();
  }

  // Validate doctor ID with API
  Future<bool> validateId() async {
    if (!isIdComplete) {
      setError('Please fill in all fields');
      return false;
    }

    _isLoading = true;
    _showError = false;
    notifyListeners();

    try {
      final isValid = await _authService.validateDoctorId(currentId);

      if (!isValid) {
        setError('Wrong ID number');
      }

      return isValid;
    } catch (e) {
      debugPrint('ID Validation Error: $e');
      setError('Error validating ID');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final controller in idControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
