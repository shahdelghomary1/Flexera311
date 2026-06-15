import 'package:flexera/core/assets/assets_manager.dart';
import 'package:flexera/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class DocNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DocNavBar({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    final lightIcons = [
      AssetsManager.homelight,
      AssetsManager.setting,
      AssetsManager.profilenav,
    ];

    final darkIcons = [
      AssetsManager.home,
      AssetsManager.settingdark,
      AssetsManager.profilenavdark,
    ];

    final labels = ['Home', 'Setting', 'Profile'];

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 60.h,
            width: 219.w,
            decoration: BoxDecoration(
              color: theme.bottomNavigationBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(23.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                  blurRadius: 25.r,
                  spreadRadius: 2.r,
                  offset: Offset(0, 6.h),
                ),
                BoxShadow(
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white.withOpacity(0.5),
                  blurRadius: 10.r,
                  offset: Offset(0, -4.h),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                final isSelected = index == currentIndex;
                final iconPath = isDark ? darkIcons[index] : lightIcons[index];

                return GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: SizedBox(
                    width: 70.w,
                    height: 60.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        // Icon Circle Animation
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          bottom: isSelected ? 30.h : 18.h,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            height: isSelected ? 55.w : 45.w,
                            width: isSelected ? 55.w : 45.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: isSelected
                                  ? const LinearGradient(
                                      colors: [
                                        Color(0xFF9FBAF9),
                                        Color(0xFF590B8D),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    )
                                  : null,
                              color: isSelected ? null : Colors.transparent,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.4),
                                        blurRadius: 10.r,
                                        offset: Offset(0, 4.h),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Image.asset(
                                iconPath,
                                height: isSelected ? 36.w : 32.w,
                                color: isSelected
                                    ? Colors.white
                                    : isDark
                                        ? AppColors.whiteColor
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        // Text Animation
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          bottom: isSelected ? 8.h : 8.h,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: isSelected ? 1 : 0.7,
                            child: Text(
                              labels[index],
                              style: GoogleFonts.lato(
                                fontSize: 10.sp,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isSelected
                                    ? const Color(0xFF6929C4)
                                    : isDark
                                        ? AppColors.subtitel
                                        : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
