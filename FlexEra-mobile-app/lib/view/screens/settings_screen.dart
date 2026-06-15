import 'package:flexera/view/widget/settings_widgets.dart';
import 'package:flexera/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';
import 'dart:math' as math;

class SettingsContainer extends StatelessWidget {
  const SettingsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            NotificationsToggle(),
            DarkModeToggle(),
            ResetMoodItem(),
            SupportHelpItem(),
            AboutFlexeraItem(),
            LogoutItem(),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return ChangeNotifierProvider(
      create: (_) => SettingsViewModel(),
      child: Scaffold(
        extendBody: true,
        backgroundColor:
            isDarkMode ? AppColors.blackcolor : AppColors.backgroundcolor1,
        body: Consumer<SettingsViewModel>(
          builder: (context, viewModel, _) {
            return Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: isDarkMode ? AppColors.blackcolor : Colors.white,
                  ),
                ),
                Positioned(
                  bottom: -1.h,
                  left: 0,
                  child: Image.asset(
                    isDarkMode
                        ? AssetsManager.backSetting
                        : AssetsManager.backSetting,
                    width: 420.w,
                    height: 650.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: -388.3.h,
                  left: 0,
                  child: Transform.rotate(
                    angle: 240 * math.pi / 180,
                    child: Image.asset(
                      AssetsManager.backgroundBlob,
                      width: 554.w,
                      height: 750.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: 60.h,
                  left: 27.w,
                  right: 27.w,
                  child: const SettingsAppBar(),
                ),
                Positioned.fill(
                  top: 160.h,
                  child: SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 70.h),
                          SectionTitle(title: 'Account information'),
                          ProfileHeader(),
                          SizedBox(height: 28.h),
                          SectionTitle(title: 'Other settings'),
                          SettingsContainer(),
                          SizedBox(height: 120.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
