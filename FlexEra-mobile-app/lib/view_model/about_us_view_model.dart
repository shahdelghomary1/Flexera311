import 'package:flutter/material.dart';

class AboutUsViewModel extends ChangeNotifier {
  // Add any state management logic here if needed
  // For example: navigation, data fetching, etc.

  void navigateBack(BuildContext context) {
    Navigator.of(context).pop();
  }
}
