import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flexera/core/assets/assets_manager.dart';
import 'package:flexera/core/themes/app_colors.dart';

import '../network/cache_helper.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8F8F9),
    appBarTheme:
        const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.black,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
    ),
  );

  static final darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF131313),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    appBarTheme:
        const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF000000),
      unselectedItemColor: Colors.white,
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 12,
    ),
  );

  static Widget background(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: isDark ? const Color(0xFF131313) : const Color(0xFFF8F8F9),
      child: Stack(
        children: [
          Positioned(
            // top: 1.h,
            left: -10.w,
            right: -10.w,
            child: Image.asset(
              AssetsManager.backhometopdark,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: -80.h,
            left: -45.w,
            right: -30.w,
            child: Image.asset(
              isDark ? AssetsManager.backhomedark : AssetsManager.backhome,
              fit: BoxFit.cover,
            ),
          ),
          if (isDark) Container(color: Colors.black.withOpacity(0.25)),
          child,
        ],
      ),
    );
  }

  static Widget supportBackground(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF131313) : const Color(0xFFF8F8F9),
      child: Stack(
        children: [
          Positioned(
            bottom: -80.h,
            left: -45.w,
            right: -30.w,
            child: Image.asset(
              isDark
                  ? AssetsManager.backsupportmiddeldark
                  : AssetsManager.backSupportmiddellighit,
              fit: BoxFit.cover,
            ),
          ),
          if (isDark) Container(color: Colors.black.withOpacity(0.3)),
          child,
        ],
      ),
    );
  }

  static Widget bookingBackground(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF131313) : const Color(0xFFF8F8F9),
      child: Stack(
        children: [
          Positioned(
            // top: 10.h,
            left: -10.w,
            right: -10.w,
            child: Image.asset(
              AssetsManager.backhometopdark,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: -60.h,
            left: -20.w,
            right: 12.w,
            child: Image.asset(
              AssetsManager.bookingback,
            ),
          ),
          if (isDark) Container(color: Colors.black.withOpacity(0.3)),
          child,
        ],
      ),
    );
  }

  static Widget chooseDoctorsBackground(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF131313) : const Color(0xFFF8F8F9),
      child: Stack(
        children: [
          Positioned(
            // top: 10.h,
            left: -10.w,
            right: -10.w,
            child: Image.asset(
              AssetsManager.backhometopdark,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: -180.h,
            left: -85.w,
            right: 85.w,
            child: Image.asset(
              AssetsManager.choosedoctorback,
            ),
          ),
          if (isDark) Container(color: Colors.black.withOpacity(0.3)),
          child,
        ],
      ),
    );
  }

  static Widget bookingReviewBackground(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF131313) : const Color(0xFFF7F7FB),
      child: Stack(
        children: [
          Positioned(
            // top: 10.h,
            left: -10.w,
            right: -10.w,
            child: Image.asset(
              "assets/images/appointmentbackgroungheader.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: -60.h,
            left: -20.w,
            right: 12.w,
            child: Image.asset(
              "assets/images/paymentbackground.png",
            ),
          ),
          if (isDark) Container(color: Colors.black.withOpacity(0.3)),
          child,
        ],
      ),
    );
  }

  static Widget bookingSuccessBackground(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF131313) : const Color(0xFFF7F7FB),
      child: Stack(
        children: [
          Positioned(
            // top: 10.h,
            left: -10.w,
            right: -10.w,
            child: Image.asset(
              "assets/images/successbgheader.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 0.h,
            left: 0.w,
            right: 0.w,
            child: Image.asset(
              "assets/images/successbg.png",
              fit: BoxFit.cover,
            ),
          ),
          if (isDark) Container(color: Colors.black.withOpacity(0.3)),
          child,
        ],
      ),
    );
  }

  static Widget progressBackground(BuildContext context, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF131313) : const Color(0xFFF8F8F9),
      child: Stack(
        children: [
          Positioned(
            // top: 10.h,
            left: -10.w,
            right: -10.w,
            child: Image.asset(
              "assets/images/progressheader.png",
              fit: BoxFit.cover,
            ),
          ),
          // Positioned(
          //   top: -90,
          //   left: -230,
          //   right: -10,
          //   child: Image.asset(
          //     isDark
          //         ? "assets/images/progresscircel.png"
          //         : "assets/images/progresscircellight.png",
          //   ),
          // ),
          Positioned(
            bottom: 0.h,
            left: 0.w,
            right: 0.w,
            child: Image.asset(
              "assets/images/progressBackground.png",
              fit: BoxFit.cover,
            ),
          ),
          if (isDark) Container(color: Colors.black.withOpacity(0.3)),
          child,
        ],
      ),
    );
  }
}

extension GradientScheme on ThemeData {
  LinearGradient get appointmentGradient {
    final isDark = brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [
              AppColors.darkpurplecolor,
              AppColors.darkpurplecolor,
            ]
          : [
              AppColors.botton2color,
              AppColors.lightpurplecolor,
            ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeProvider({bool? startDark}) {
    if (startDark != null) {
      _themeMode = startDark ? ThemeMode.dark : ThemeMode.light;
    }
  }

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    CacheHelper.saveData(key: 'isDark', value: _themeMode == ThemeMode.dark);
    notifyListeners();
  }
}
