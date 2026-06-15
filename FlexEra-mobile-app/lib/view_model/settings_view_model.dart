import 'package:flexera/model/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../core/network/cache_helper.dart';
import '../core/network/dio_helper.dart';
import '../core/network/end_points.dart';

import '../view/screens/about_us_setting.dart';
import '../view/screens/account_info_screen.dart';
import '../view/screens/support_screen.dart';
import '../view/screens/role_selection_screen.dart';

class SettingsViewModel extends ChangeNotifier {
  bool notificationsEnabled = true;

  final ImagePicker _picker = ImagePicker();

  String userName = 'User';
  String userEmail = '';
  String? userImage;

  SettingsViewModel() {
    getProfileData();
    _loadNotificationState();
  }

  void _loadNotificationState() {
    notificationsEnabled =
        CacheHelper.getData(key: 'isNotificationsEnabled') ?? true;
    notifyListeners();
  }

  void toggleNotifications(bool value) {
    notificationsEnabled = value;
    CacheHelper.saveData(key: 'isNotificationsEnabled', value: value);
    notifyListeners();
    debugPrint("🔔 Notifications turned: ${value ? 'ON' : 'OFF'}");
  }

  Future<void> getProfileData() async {
    userName = CacheHelper.getData(key: 'userName') ?? 'User';
    userEmail = CacheHelper.getData(key: 'email') ?? '';
    userImage = CacheHelper.getData(key: 'photo');

    notifyListeners();

    try {
      final token = CacheHelper.getData(key: 'token');

      final response = await DioHelper.getData(
        url: EndPoints.updateAccount,
        token: token,
      );

      if (response.data != null &&
          (response.data['success'] == true || response.statusCode == 200)) {
        final data = response.data['user'] ?? response.data;

        userName = data['name'] ?? userName;
        userEmail = data['email'] ?? userEmail;
        userImage = data['photo'];

        await CacheHelper.saveData(key: 'userName', value: userName);
        await CacheHelper.saveData(key: 'email', value: userEmail);
        if (userImage != null) {
          await CacheHelper.saveData(key: 'photo', value: userImage);
        }

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error fetching profile data silently: $e');
    }
  }

  void navigateToAccountInfo(BuildContext context) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (context) => const AccountInfoScreen(),
      ),
    )
        .then((_) {
      getProfileData();
    });
  }

  void navigateToSecuritySettings(BuildContext context) {
    debugPrint('Navigate to Security Settings');
  }

  void navigateToSupportHelp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SupportScreen(),
      ),
    );
  }

  void navigateToAboutFlexera(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AboutUsSetting(),
      ),
    );
  }

  Future<void> resetMoodOverlay() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('mood_overlay_seen', false);
    notifyListeners();
  }

  void logout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _buildLogoutDialog(context),
    );
  }

  Widget _buildLogoutDialog(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to log out?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () async {
                    // 1. Loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) =>
                          const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final GoogleSignIn googleSignIn = GoogleSignIn();
                      if (await googleSignIn.isSignedIn()) {
                        await googleSignIn.disconnect();
                      }
                    } catch (e) {
                      await GoogleSignIn().signOut();
                    }
                    await NotificationService.logout();
                    await CacheHelper.removeData(key: 'token');
                    await CacheHelper.removeData(key: 'userName');
                    await CacheHelper.removeData(key: 'email');
                    await CacheHelper.removeData(key: 'photo');
                    await CacheHelper.removeData(key: 'userId');
                    await CacheHelper.removeData(key: 'fcmToken');
                    await CacheHelper.removeData(key: 'id');
                    await CacheHelper.removeData(key: 'isDoctor');

                    userName = 'User';
                    userEmail = '';
                    userImage = null;

                    if (context.mounted) {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const RoleSelectionScreen(),
                        ),
                        (route) => false,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [Color(0xFF786AC8), Color(0xFF5B5F9C)],
                      ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Yes, Logout',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
