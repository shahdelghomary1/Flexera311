import 'package:flutter/material.dart';

class DocMainViewModel extends ChangeNotifier {
  int _selectedNavIndex = 0;
  int _previousNavIndex = 0;

  int get selectedNavIndex => _selectedNavIndex;
  int get previousNavIndex => _previousNavIndex;

  int get navBarIndex {
    if (_selectedNavIndex == 3) {
      return 1;
    }
    return _selectedNavIndex;
  }

  void setNavIndex(int index) {
    _previousNavIndex = _selectedNavIndex;
    _selectedNavIndex = index;
    notifyListeners();
  }

  void onNavBarTap(int index) {
    setNavIndex(index);
  }

  void navigateToAboutFlexera() {
    setNavIndex(3);
  }

  void goBackToSettings() {
    setNavIndex(1);
  }
}
