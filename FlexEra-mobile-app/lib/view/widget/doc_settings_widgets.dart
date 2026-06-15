import 'dart:io';
import 'dart:math' as math;
import 'package:flexera/view/screens/about_us_setting.dart';
import 'package:flexera/view/screens/support_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_theme.dart';
import '../../view_model/doc_account_info_view_model.dart';
import '../../view_model/doc_settings_view_model.dart';
import '../../view_model/doc_main_view_model.dart';
import 'doctor_image_widget.dart';

class DocSettingsBody extends StatelessWidget {
  const DocSettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<DocSettingsViewModel>(
      builder: (context, viewModel, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color: isDark ? AppColors.blackcolor : Colors.white,
              ),
            ),
            Positioned(
              bottom: -1.h,
              left: 0,
              child: Image.asset(
                AssetsManager.backSetting,
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
              child: const DocSettingsAppBar(),
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
                      const DocSectionTitle(title: 'Account information'),
                      const DocProfileHeader(),
                      SizedBox(height: 28.h),
                      const DocSectionTitle(title: 'Other settings'),
                      const DocSettingsContainer(),
                      SizedBox(height: 120.h),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DocSettingsAppBar extends StatelessWidget {
  const DocSettingsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        SizedBox(width: 110.w),
        Expanded(
          child: Text(
            'Settings',
            style: GoogleFonts.quicksand(
              fontSize: 29.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF383838),
              letterSpacing: 0.1,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}

class DocSectionTitle extends StatelessWidget {
  final String title;

  const DocSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 12.h),
      child: Text(
        title,
        style: GoogleFonts.instrumentSans(
          fontSize: 15.sp,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white70 : AppColors.settingColor,
        ),
      ),
    );
  }
}

class DocProfileHeader extends StatelessWidget {
  const DocProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer2<DocAccountInfoViewModel, DocMainViewModel>(
      builder: (context, accountProvider, mainViewModel, child) {
        final doctorName = accountProvider.fullNameController.text.isNotEmpty
            ? accountProvider.fullNameController.text
            : 'Dr. ...';

        final doctorEmail = accountProvider.emailController.text.isNotEmpty
            ? accountProvider.emailController.text
            : 'loading...';

        final imageUrl = accountProvider.currentImageUrl ?? '';

        return GestureDetector(
          onTap: () {
            mainViewModel.setNavIndex(2);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
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
                    child: DoctorImageWidget(
                      imageUrl: imageUrl,
                      defaultImage: AssetsManager.doctor,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctorName,
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : AppColors.blackcolor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        doctorEmail,
                        style: GoogleFonts.instrumentSans(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : AppColors.blackcolor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Image.asset(
                  'assets/icons/setting_arrow.png',
                  width: 18.w,
                  height: 18.w,
                  color: isDark ? Colors.white : AppColors.blackcolor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DocSettingsContainer extends StatelessWidget {
  const DocSettingsContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            DocDarkModeToggle(),
            DocSupportHelpItem(),
            DocAboutFlexeraItem(),
            DocLogoutItem(),
          ],
        ),
      ),
    );
  }
}

class DocSettingsToggleItem extends StatelessWidget {
  final String icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const DocSettingsToggleItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              color: isDark ? Colors.white : null,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.notifications,
                  size: 24.w,
                  color: isDark ? Colors.white : AppColors.blackcolor,
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
                  color: isDark ? Colors.white : AppColors.settingColor,
                ),
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeTrackColor: isDark ? AppColors.primaryDark : Colors.blue,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor:
                  isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ],
        ),
      ),
    );
  }
}

class DocSettingsMenuItem extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;
  final bool isLogout;

  const DocSettingsMenuItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                color: isLogout ? Colors.red : (isDark ? Colors.white : null),
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    isLogout ? Icons.logout : Icons.settings,
                    size: 24.w,
                    color: isLogout
                        ? Colors.red
                        : (isDark ? Colors.white : AppColors.blackcolor),
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
                        : (isDark ? Colors.white : AppColors.graycolor),
                  ),
                ),
              ),
              Image.asset(
                'assets/icons/setting_arrow.png',
                width: 18.w,
                height: 18.w,
                color: isDark ? Colors.white : AppColors.blackcolor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class DocDarkModeToggle extends StatelessWidget {
  const DocDarkModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return DocSettingsToggleItem(
      icon: 'assets/icons/dark_Mode.png',
      title: 'Dark mode',
      value: themeProvider.themeMode == ThemeMode.dark,
      onChanged: (value) => themeProvider.toggleTheme(),
    );
  }
}

class DocSupportHelpItem extends StatelessWidget {
  const DocSupportHelpItem({super.key});

  @override
  Widget build(BuildContext context) {
    return DocSettingsMenuItem(
      icon: 'assets/icons/support.png',
      title: 'Support & Help',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SupportScreen(),
          ),
        );
      },
    );
  }
}

class DocAboutFlexeraItem extends StatelessWidget {
  const DocAboutFlexeraItem({super.key});

  @override
  Widget build(BuildContext context) {

    return DocSettingsMenuItem(
      icon: 'assets/icons/about.png',
      title: 'About Flexera',
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AboutUsSetting(),
          ),
        );
      },
    );
  }
}

class DocLogoutItem extends StatelessWidget {
  const DocLogoutItem({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DocSettingsViewModel>(context, listen: false);

    return DocSettingsMenuItem(
      icon: 'assets/icons/logout.png',
      title: 'Logout',
      onTap: () => viewModel.logout(context),
      isLogout: true,
    );
  }
}

class DocAboutFlexeraBody extends StatelessWidget {
  const DocAboutFlexeraBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: isDark ? const Color(0xFF131313) : Colors.white,
          ),
        ),
        Positioned(
          top: -200.h,
          left: 100.w,
          right: -320.w,
          child: Transform.rotate(
            angle: 140 * math.pi / 180,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                AssetsManager.aboutUp,
                width: 800.99.w,
                height: 1000.28.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -300.h,
          left: -220.w,
          child: Transform.rotate(
            angle: 350 * math.pi / 180,
            child: Image.asset(
              AssetsManager.aboutDown,
              width: 800.39.w,
              height: 1209.65.h,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: 60.h,
          left: 27.w,
          child: const DocSubPageBackButton(title: 'About Flexera'),
        ),
        Positioned(
          top: 120.h,
          left: 0,
          right: 0,
          bottom: 0,
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 28.h),
                  Text(
                    'How can we\nhelp you?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.instrumentSans(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Our team is always ready to support you on your recovery journey.\nWhether you have a question about your treatment plan, need technical assistance, or just want to share feedback, we\'re happy to help.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.quicksand(
                      fontSize: 17.sp, // Font -> .sp
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.blackcolor,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 38.h),
                  Text(
                    'Email: support@flexera.com',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? Colors.white70 : AppColors.lightblackcolor,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Phone: +1 (234) 567-890',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color:
                          isDark ? Colors.white70 : AppColors.lightblackcolor,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  const DocLiveChatButton(),
                  SizedBox(height: 15.h),
                  const DocSocialMediaSection(),
                  SizedBox(height: 120.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DocSubPageBackButton extends StatelessWidget {
  final String title;

  const DocSubPageBackButton({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainViewModel = Provider.of<DocMainViewModel>(context, listen: false);

    return Row(
      children: [
        GestureDetector(
          onTap: () => mainViewModel.goBackToSettings(),
          child: Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(50.r),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.white,
                width: 1.w,
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/arrow.png',
                width: 25.w,
                height: 25.w,
                color: isDark ? Colors.white : null,
              ),
            ),
          ),
        ),
        SizedBox(width: 20.w),
        Text(
          title,
          style: GoogleFonts.quicksand(
            fontSize: 29.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF383838),
            letterSpacing: 0.1,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class DocLiveChatButton extends StatelessWidget {
  const DocLiveChatButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: () {
        debugPrint('Navigate to Live Chat');
      },
      child: Center(
        child: Container(
          width: 330.w,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment(-1.2, -1.0),
              end: Alignment(1.0, 1.2),
              colors: [Color(0xFF590B8D), Color(0xFF786AC8)],
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 50.w),
              Image.asset(
                'assets/icons/chat.png',
                width: 30.w,
                height: 30.w,
                color: Colors.white,
              ),
              SizedBox(width: 50.w),
              Text(
                'Live Chat',
                style: GoogleFonts.instrumentSans(
                  fontSize: 24.sp, // Font -> .sp
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DocSocialMediaSection extends StatelessWidget {
  const DocSocialMediaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Center(
          child: Text(
            'Our Social',
            style: GoogleFonts.instrumentSans(
              fontSize: 17.sp,
              color: isDark ? Colors.white70 : AppColors.lightblackcolor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DocSocialIcon(imagePath: 'assets/icons/facebook.png', onTap: () {}),
            DocSocialIcon(imagePath: 'assets/icons/insta.png', onTap: () {}),
            DocSocialIcon(imagePath: 'assets/icons/linkedin.png', onTap: () {}),
            DocSocialIcon(
              imagePath: 'assets/icons/google_icon.png',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class DocSocialIcon extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const DocSocialIcon({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 35.w,
        height: 35.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        child: Padding(
          padding: EdgeInsets.all(1.0.r),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
