import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/themes/app_colors.dart';
import '../../core/assets/assets_manager.dart';

class MainTitleText extends StatelessWidget {
  const MainTitleText({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 10.w,
        top: 40.h,
        bottom: 10.h,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
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
          Expanded(
            child: Center(
              child: Text(
                'About Us',
                style: GoogleFonts.quicksand(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.2.h,
                  color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
                ),
              ),
            ),
          ),
          SizedBox(width: 50.w),
        ],
      ),
    );
  }
}

class DescriptionText extends StatelessWidget {
  final Widget? iconWidget;
  final String? title;
  final TextAlign titleAlign;
  final String description;
  final bool showBottomBorder;

  const DescriptionText({
    super.key,
    this.iconWidget,
    this.title,
    this.titleAlign = TextAlign.center,
    required this.description,
    this.showBottomBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.0.w, vertical: 25.0.h),
          child: Column(
            crossAxisAlignment: titleAlign == TextAlign.center
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (iconWidget != null || title != null)
                Row(
                  mainAxisAlignment: titleAlign == TextAlign.center
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (iconWidget != null) iconWidget!,
                    if (iconWidget != null && title != null)
                      SizedBox(width: 8.w),
                    if (title != null)
                      Transform.translate(
                        offset: Offset(-2.w, 4.h),
                        child: Text(
                          title!,
                          style: GoogleFonts.getFont(
                            'Annapurna SIL',
                            fontSize: 26.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                            height: 1.h,
                          ),
                        ),
                      ),
                  ],
                ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.only(left: 35.0.w),
                child: Text(
                  description,
                  style: GoogleFonts.quicksand(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.black87,
                    height: 1.25.h,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showBottomBorder)
          Container(
            height: 3.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF590B8D),
                  Color(0xFF6B48FF),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class LogoSection extends StatelessWidget {
  final String? subtitle;

  const LogoSection({super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 25.0.w),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'F',
                style: GoogleFonts.grandHotel(
                  fontSize: 40.sp,
                  color:
                      isDark ? AppColors.whiteColor : AppColors.lightblackcolor,
                ),
              ),
              Transform.translate(
                offset: Offset(-3.w, -5.h),
                child: Image.asset(
                  AssetsManager.logoIcon,
                  width: 50.w,
                  height: 50.h,
                ),
              ),
              Transform.translate(
                offset: Offset(-6.w, 0),
                child: Text(
                  'exera',
                  style: GoogleFonts.grandHotel(
                    fontSize: 40.sp,
                    color: isDark
                        ? AppColors.whiteColor
                        : AppColors.lightblackcolor,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 1.h),
            LayoutBuilder(
              builder: (context, constraints) {
                final text = subtitle!;
                final textStyle = GoogleFonts.getFont(
                  'Homemade Apple',
                  fontSize: 15.sp,
                );

                final textPainter = TextPainter(
                  text: TextSpan(text: text, style: textStyle),
                  textDirection: TextDirection.ltr,
                )..layout();

                return Text(
                  text,
                  textAlign: TextAlign.center,
                  style: textStyle.copyWith(
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [Color(0xFF590B8D), Color(0xFF6B48FF)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ).createShader(
                        Rect.fromLTWH(
                          0,
                          0,
                          textPainter.width,
                          textPainter.height,
                        ),
                      ),
                  ),
                );
              },
            ),
          ]
        ],
      ),
    );
  }
}
