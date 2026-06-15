import 'package:flutter/material.dart';

/// ViewModel for Doctor Home Screen
/// Handles business logic and navigation for the doctor dashboard
class DocHomeViewModel extends ChangeNotifier {
  // Navigation state
  int _selectedNavIndex = 0;

  // Getters
  int get selectedNavIndex => _selectedNavIndex;

  void setNavIndex(int index) {
    _selectedNavIndex = index;
    notifyListeners();
  }

  void navigateToPatients(BuildContext context) {
    debugPrint('Navigate to My Patients screen');
    Navigator.of(context).pushNamed('/patients');
  }

  /// Navigate to Appointments screen
  void navigateToAppointments(BuildContext context) {
    debugPrint('Navigate to Appointments screen');
    Navigator.of(context).pushNamed('/doc-appointment');
  }

  /// Navigate to Clinic Schedule screen
  void navigateToClinicSchedule(BuildContext context) {
    debugPrint('Navigate to Clinic Schedule screen');
    Navigator.of(context).pushNamed('/clinic-schedule');
  }

  /// Navigate to Messages screen
  void navigateToMessages(BuildContext context) {
    // TODO: Navigate to messages screen
    debugPrint('Navigate to Messages screen');
    // Example:
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => const MessagesScreen(),
    //   ),
    // );
  }

  /// Handle search action
  void onSearchTap(BuildContext context) {
    // TODO: Implement search functionality
    debugPrint('Search tapped');
    // Example:
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => const SearchScreen(),
    //   ),
    // );
  }

  /// Handle notification icon tap
  void onNotificationTap(BuildContext context) {
    // TODO: Navigate to notifications screen
    debugPrint('Notification tapped');
    // Example:
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => const NotificationsScreen(),
    //   ),
    // );
  }

  /// Handle navigation bar item tap
  void onNavBarTap(int index, BuildContext context) {
    setNavIndex(index);

    // Handle navigation based on index
    switch (index) {
      case 0:
        // Home - already here
        debugPrint('Home selected');
        break;
      case 1:
        // Settings
        debugPrint('Settings selected');
        // TODO: Navigate to settings screen
        break;
      case 2:
        // Profile
        debugPrint('Profile selected');
        // TODO: Navigate to profile screen
        break;
      case 3:
        // Contact us
        debugPrint('Contact us selected');
        // TODO: Navigate to contact us screen
        break;
    }
  }
}
