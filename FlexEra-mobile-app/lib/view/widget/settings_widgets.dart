import 'dart:io';
import 'package:flexera/core/themes/app_theme.dart';
import 'package:flexera/view/screens/account_info_screen.dart';
import 'package:flexera/view/widget/mood_overlay.dart';
import 'package:flexera/view_model/account_info_view_model.dart';
import 'package:flexera/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';

class LogoutDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const LogoutDialog({super.key, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to log out?',
              textAlign: TextAlign.center,
              style: GoogleFonts.instrumentSans(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.blackcolor,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25.r),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1.5.w,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackcolor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    onConfirm();
                  },
                  child: Container(
                    width: 101.w,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [Color(0xFF786AC8), Color(0xFF5B5F9C)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'Yes, Logout',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
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

class SettingsAppBar extends StatelessWidget {
  const SettingsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SettingsViewModel>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              "Settings",
              style: GoogleFonts.instrumentSans(
                fontSize: 34.sp,
                fontWeight: FontWeight.w600,
                color: isDarkMode ? Colors.white : const Color(0xFF383838),
                letterSpacing: 0.1,
                height: 1.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountInfoViewModel>(context, listen: false).getMyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AccountInfoViewModel>(
      builder: (context, accountVm, child) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        final settingsVm =
            Provider.of<SettingsViewModel>(context, listen: false);

        ImageProvider userAvatar;
        if (accountVm.networkImageUrl != null &&
            accountVm.networkImageUrl!.isNotEmpty) {
          userAvatar = NetworkImage(accountVm.networkImageUrl!);
        } else {
          userAvatar = const AssetImage('assets/images/defult_doc.png');
        }

        return GestureDetector(
          onTap: () {
            settingsVm.navigateToAccountInfo(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10.r,
                  offset: Offset(0, 2.h),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: AppColors.purplecolor, width: 2.w),
                  ),
                  child: ClipOval(
                    child: SizedBox(
                      width: 70.w,
                      height: 70.w,
                      child: CircleAvatar(
                        radius: 35.r,
                        backgroundImage: userAvatar,
                        backgroundColor: Colors.transparent,
                        onBackgroundImageError: (_, __) {},
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        accountVm.fullNameController.text.isNotEmpty
                            ? accountVm.fullNameController.text
                            : 'User',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              isDarkMode ? Colors.white : AppColors.blackcolor,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        accountVm.emailController.text.isNotEmpty
                            ? accountVm.emailController.text
                            : 'No Contact Info',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode
                              ? Colors.white70
                              : AppColors.blackcolor,
                        ),
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/icons/setting_arrow.png',
                  width: 18.w,
                  height: 18.w,
                  color: isDarkMode ? Colors.white : AppColors.blackcolor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
      child: Text(
        title,
        style: GoogleFonts.instrumentSans(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: isDarkMode ? Colors.white70 : AppColors.settingColor,
        ),
      ),
    );
  }
}

class SettingsToggleItem extends StatelessWidget {
  final String icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsToggleItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 1.5.h),
      child: SizedBox(
        height: 50.h,
        child: Row(
          children: [
            Image.asset(
              icon,
              width: 30.w,
              height: 30.w,
              color: isDarkMode ? Colors.white : null,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.notifications,
                  size: 24.w,
                  color: isDarkMode ? Colors.white : AppColors.blackcolor,
                );
              },
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.instrumentSans(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w500,
                  color: isDarkMode ? Colors.white : AppColors.settingColor,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor:
                  isDarkMode ? AppColors.primaryDark : Colors.blue,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor:
                  isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsMenuItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  const SettingsMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
        child: SizedBox(
          height: 44.h,
          child: Row(
            children: [
              Image.asset(
                icon,
                width: 24.w,
                height: 24.w,
                color:
                    isLogout ? Colors.red : (isDarkMode ? Colors.white : null),
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    isLogout ? Icons.logout : Icons.settings,
                    size: 24.w,
                    color: isLogout
                        ? Colors.red
                        : (isDarkMode ? Colors.white : AppColors.blackcolor),
                  );
                },
              ),
              SizedBox(width: 15.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.instrumentSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color: isLogout
                        ? Colors.red
                        : (isDarkMode ? Colors.white : AppColors.graycolor),
                  ),
                ),
              ),
              Image.asset(
                'assets/icons/setting_arrow.png',
                width: 18.w,
                height: 18.w,
                color: isDarkMode ? Colors.white : AppColors.blackcolor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationsToggle extends StatelessWidget {
  const NotificationsToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, _) => SettingsToggleItem(
        icon: 'assets/icons/notification.png',
        title: 'Notifications',
        value: viewModel.notificationsEnabled,
        onChanged: (value) => viewModel.toggleNotifications(value),
      ),
    );
  }
}

class DarkModeToggle extends StatelessWidget {
  const DarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return SettingsToggleItem(
      icon: 'assets/icons/dark_Mode.png',
      title: 'Dark mode',
      value: themeProvider.themeMode == ThemeMode.dark,
      onChanged: (value) {
        themeProvider.toggleTheme();
      },
    );
  }
}

class SecuritySettingsItem extends StatelessWidget {
  const SecuritySettingsItem({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SettingsViewModel>(context, listen: false);
    return SettingsMenuItem(
      icon: 'assets/icons/security_setting.png',
      title: 'Security settings',
      onTap: () => viewModel.navigateToSecuritySettings(context),
    );
  }
}

class SupportHelpItem extends StatelessWidget {
  const SupportHelpItem({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SettingsViewModel>(context, listen: false);
    return SettingsMenuItem(
      icon: 'assets/icons/support.png',
      title: 'Support & Help',
      onTap: () => viewModel.navigateToSupportHelp(context),
    );
  }
}

class AboutFlexeraItem extends StatelessWidget {
  const AboutFlexeraItem({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SettingsViewModel>(context, listen: false);
    return SettingsMenuItem(
      icon: 'assets/icons/about.png',
      title: 'About Flexera',
      onTap: () => viewModel.navigateToAboutFlexera(context),
    );
  }
}

class LogoutItem extends StatelessWidget {
  const LogoutItem({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SettingsViewModel>(context, listen: false);
    return SettingsMenuItem(
      icon: 'assets/icons/logout.png',
      title: 'Logout',
      onTap: () => viewModel.logout(context),
      isLogout: true,
    );
  }
}

class ResetMoodItem extends StatelessWidget {
  const ResetMoodItem({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SettingsViewModel>(context, listen: false);

    return SettingsMenuItem(
      icon: 'assets/icons/refresh.png',
      title: "Reset Mood Sheet",
      onTap: () async {
        await viewModel.resetMoodOverlay();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: MoodOverlay(
              onDismissed: () {},
            ),
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Mood sheet reset! It will appear now."),
            duration: Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
