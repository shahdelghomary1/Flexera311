import 'package:flexera/core/assets/assets_manager.dart';
import 'package:flexera/core/themes/app_colors.dart';
import 'package:flexera/view/screens/account_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final lightIcons = [
      AssetsManager.homelight,
      // AssetsManager.search,
      AssetsManager.setting,
      AssetsManager.profilenav,
      AssetsManager.contactus,
    ];

    final darkIcons = [
      AssetsManager.home,
      // AssetsManager.searchdark,
      AssetsManager.settingdark,
      AssetsManager.profilenavdark,
      AssetsManager.contactusdark,
    ];

    final labels = ['Home', 'Setting', 'Profile', 'Contact'];

    return Padding(
      padding: EdgeInsets.only(left: 30.w, right: 30.w, bottom: 20.h),
      child: Container(
        height: 72.h,
        width: 337.w,
        decoration: BoxDecoration(
          color: theme.bottomNavigationBarTheme.backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(4, (index) {
            final isSelected = index == currentIndex;
            final iconPath = isDark ? darkIcons[index] : lightIcons[index];

            return GestureDetector(
              onTap: () {
                onTap(index);
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 70.w,
                height: 80.h,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      bottom: isSelected ? 35 : 22,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        height: isSelected ? 60 : 48,
                        width: isSelected ? 60 : 48,
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
                        ),
                        child: Center(
                          child: Image.asset(
                            iconPath,
                            height: isSelected ? 40 : 36,
                            color: isSelected
                                ? Colors.white
                                : isDark
                                ? AppColors.whiteColor
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      bottom: isSelected ? 15 : 10,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isSelected ? 1 : 0.7,
                        child: Text(
                          labels[index],
                          style: GoogleFonts.lato(
                            fontSize: 12.sp,
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
    );
  }
}
