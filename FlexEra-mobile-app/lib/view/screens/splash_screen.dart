import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';
import '../widget/splash_background.dart';
import 'onboarding_screen.dart';
import '../../core/network/cache_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentPage = 0;

  void _nextPage() async {
    if (currentPage < 2) {
      setState(() => currentPage++);
    } else {
      await CacheHelper.saveData(key: 'onBoarding', value: true);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final centerImage =
        currentPage == 1 ? AssetsManager.logoIcon2 : AssetsManager.logoIcon;

    return GestureDetector(
      onTap: _nextPage,
      child: Scaffold(
        backgroundColor: AppColors.backgroundcolor1,
        body: Stack(
          children: [
            SplashBackground(pageIndex: currentPage),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "F",
                        style: GoogleFonts.grandHotel(
                          fontSize: 50.sp,
                          color: AppColors.blackcolor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Transform.translate(
                        offset: Offset(-9.w, 0),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(opacity: animation, child: child),
                          child: Image.asset(
                            centerImage,
                            key: ValueKey(centerImage),
                            width: 57.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(-9.w, 0),
                        child: Text(
                          "exera",
                          style: GoogleFonts.grandHotel(
                            fontSize: 50.sp,
                            color: AppColors.blackcolor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Restore Your Balance',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 13.sp,
                      color: AppColors.graycolor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
