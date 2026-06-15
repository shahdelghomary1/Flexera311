import 'package:flexera/view_model/about_us_view_model.dart';
import 'package:flexera/view/screens/settings_screen.dart';
import 'package:flexera/view/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/themes/app_colors.dart';

class BackButtonHeader extends StatelessWidget {
  final AboutUsViewModel viewModel;

  const BackButtonHeader({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          child: Container(
            width: 50.w,
            height: 50.h,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.white,
                width: 1.w,
              ),
            ),
            child: Center(
              child: Image.asset(
                'assets/icons/arrow.png',
                width: 25.w,
                height: 25.h,
                color: isDark ? AppColors.whiteColor : null,
              ),
            ),
          ),
        ),
        SizedBox(width: 20.w),
        Expanded(
          child: Text(
            "We're Here for You",
            style: GoogleFonts.quicksand(
              fontSize: 29.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.whiteColor : const Color(0xFF383838),
              letterSpacing: 0.1,
              height: 1.0.h,
            ),
          ),
        ),
      ],
    );
  }
}

class MainTitleText extends StatelessWidget {
  const MainTitleText({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      'How can we\nhelp you?',
      textAlign: TextAlign.center,
      style: GoogleFonts.instrumentSans(
        fontSize: 40.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.whiteColor : Colors.black,
        height: 1.2.h,
      ),
    );
  }
}

class DescriptionText extends StatelessWidget {
  const DescriptionText({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      'Our team is always ready to support you on your recovery journey.\nWhether you have a question about your treatment plan, need technical assistance, or just want to share feedback, we\'re happy to help.',
      textAlign: TextAlign.center,
      style: GoogleFonts.quicksand(
        fontSize: 17.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
        height: 1.25.h,
      ),
    );
  }
}

class ContactInfoSection extends StatelessWidget {
  const ContactInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          'Email: support@flexera.com',
          style: GoogleFonts.instrumentSans(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.whiteColor.withOpacity(0.9)
                : AppColors.lightblackcolor,
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          'Phone: +1 (234) 567-890',
          style: GoogleFonts.instrumentSans(
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppColors.whiteColor.withOpacity(0.9)
                : AppColors.lightblackcolor,
          ),
        ),
      ],
    );
  }
}

class LiveChatButton extends StatelessWidget {
  final AboutUsViewModel viewModel;
  final VoidCallback? onTap;

  const LiveChatButton({super.key, required this.viewModel, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatScreen()),
            );
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
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 50.w),
              Image.asset(
                'assets/icons/chat.png',
                width: 30.w,
                height: 30.h,
                color: AppColors.whiteColor,
              ),
              SizedBox(width: 50.w),
              Text(
                'Live Chat',
                style: GoogleFonts.instrumentSans(
                  fontSize: 24.sp,
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

class SocialMediaSection extends StatelessWidget {
  const SocialMediaSection({super.key});

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
              color: isDark
                  ? AppColors.whiteColor.withOpacity(0.9)
                  : AppColors.lightblackcolor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 2.w),
            SocialImageIcon(
              imagePath: 'assets/icons/facebook.png',
              onTap: () {},
            ),
            SizedBox(width: 2.w),
            SocialImageIcon(imagePath: 'assets/icons/insta.png', onTap: () {}),
            SizedBox(width: 2.w),
            SocialImageIcon(
              imagePath: 'assets/icons/google_icon.png',
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

class SocialImageIcon extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const SocialImageIcon({
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
        height: 35.h,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        child: Padding(
          padding: EdgeInsets.all(1.0.r),
          child: Image.asset(imagePath, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
