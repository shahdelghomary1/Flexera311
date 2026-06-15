// import 'package:flutter/material.dart';
//
// class PaymentViewModel extends ChangeNotifier {
//   final cardHolderController = TextEditingController();
//   final cardNumberController = TextEditingController();
//   final expiryController = TextEditingController();
//   final cvvController = TextEditingController();
//   final nameFocusNode = FocusNode();
//   final numberFocusNode = FocusNode();
//   final expiryFocusNode = FocusNode();
//   final cvvFocusNode = FocusNode();
//   final formKey = GlobalKey<FormState>();
//
//   @override
//   void dispose() {
//     nameFocusNode.dispose();
//     numberFocusNode.dispose();
//     expiryFocusNode.dispose();
//     cvvFocusNode.dispose();
//     cardHolderController.dispose();
//     cardNumberController.dispose();
//     expiryController.dispose();
//     cvvController.dispose();
//     super.dispose();
//   }
//   String? validateCardNumber(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return "Required";
//     }
//
//     String digits = value.replaceAll(RegExp(r'\D'), '');
//
//     if (digits.length < 13 || digits.length > 22) {
//       return "Invalid card length";
//     }
//
//     int sum = 0;
//     bool alternate = false;
//
//     for (int i = digits.length - 1; i >= 0; i--) {
//       int n = int.parse(digits[i]);
//
//       if (alternate) {
//         n *= 2;
//         if (n > 9) {
//           n -= 9;
//         }
//       }
//       sum += n;
//       alternate = !alternate;
//     }
//
//     if (sum % 10 != 0) {
//       return "Invalid card number (Check digits)";
//     }
//
//     return null;
//   }
//
//   String? validateExpiry(String? value) {
//     if (value == null || value.isEmpty) {
//       return "Required";
//     }
//
//     if (!value.contains("/")) {
//       return "Invalid format (MM/YY)";
//     }
//
//     List<String> split = value.split(RegExp(r'(/)'));
//
//     if (split.length != 2) {
//       return "Invalid Date";
//     }
//
//     int? month = int.tryParse(split[0]);
//     int? year = int.tryParse(split[1]);
//
//     if (month == null || year == null) {
//       return "Invalid Date";
//     }
//
//     if (month < 1 || month > 12) {
//       return "Invalid month (01-12)";
//     }
//
//     final now = DateTime.now();
//     final int currentYearLast2Digits = now.year % 100; // 24
//
//     if (year < currentYearLast2Digits) {
//       return "Card expired";
//     }
//
//     if (year == currentYearLast2Digits && month < now.month) {
//       return "Card expired";
//     }
//
//     if (year > currentYearLast2Digits + 20) {
//       return "Invalid year";
//     }
//
//     return null;
//   }
//
//   String? validateCVV(String? value) {
//     if (value == null || value.isEmpty) {
//       return "Required";
//     }
//
//     String cvv = value.replaceAll(RegExp(r'\D'), '');
//
//     if (cvv.length < 3 || cvv.length > 4) {
//       return "Invalid CVV (3 or 4 digits)";
//     }
//     return null;
//   }
//
//   String? validateName(String? value) {
//     if (value == null || value.isEmpty) {
//       return "Required";
//     }
//     if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
//       return "Enter a valid name (Letters only)";
//     }
//
//     List<String> names = value.trim().split(" ");
//     if (names.length < 2 && value.length < 4) {
//       return "Enter full name";
//     }
//     return null;
//   }
//
//   bool submitPayment() {
//     if (formKey.currentState!.validate()) {
//       // API
//       return true;
//     }
//     return false;
//   }
// }
