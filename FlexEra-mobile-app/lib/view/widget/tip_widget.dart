import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';

class TipItem {
  final String icon;
  final String title;
  final String shortDescription;
  final String fullDescription;
  final String image;
  final String link;
  final Color color;
  final bool disclaimer;

  TipItem({
    required this.icon,
    required this.title,
    required this.shortDescription,
    required this.fullDescription,
    required this.image,
    required this.link,
    required this.color,
    required this.disclaimer,
  });
}

class TipCard extends StatelessWidget {
  final TipItem item;
  final VoidCallback onTap;
  final bool isDark;

  const TipCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.6) : Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 20.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: item.color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.r),
                  bottomLeft: Radius.circular(10.r),
                ),
              ),
            ),

            SizedBox(width: 16.w),

            // TITLE + ICON + DESCRIPTION
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 5.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TITLE + ICON
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          item.icon,
                          style: TextStyle(fontSize: 20.sp),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            item.title,
                            style: GoogleFonts.quicksand(
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),

                    // DESCRIPTION
                    Text(
                      item.shortDescription,
                      style: GoogleFonts.instrumentSans(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ARROW BUTTON AT FAR RIGHT
            Container(
              margin: EdgeInsets.only(right: 12.w, top: 12.h),
              padding: EdgeInsets.all(6.r),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isDark ? Colors.white30 : Colors.black26,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.north_east,
                size: 20.r,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TipDetailsScreen extends StatelessWidget {
  final TipItem item;
  final bool isDark;

  const TipDetailsScreen({super.key, required this.item, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        isDark ? const Color(0xFF131313) : const Color(0xfff7f7f7);
    final containerColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor =
        isDark ? Colors.white24 : const Color.fromRGBO(96, 95, 95, 1);
    final textColor = isDark ? Colors.white70 : Colors.black87;
    final secondaryTextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -10.h,
            left: -25.w,
            child: Transform.rotate(
              angle: 0,
              child: Image.asset(
                isDark
                    ? 'assets/images/Ellipse8dark.png'
                    : 'assets/images/Ellipse8.png',
                width: 450.w,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            bottom: -10.h,
            left: 0,
            child: Transform.rotate(
              angle: 0,
              child: Image.asset(
                'assets/images/Ellipse1.png',
                width: 450.w,
                fit: BoxFit.contain,
                color: isDark ? Colors.white10 : null,
                colorBlendMode: isDark ? BlendMode.modulate : null,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 100.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  child: Row(
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: 50.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E1E1E).withOpacity(1)
                                    : Colors.white.withOpacity(1),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: isDark ? Colors.white24 : Colors.white,
                                  width: 1.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4,
                                    offset: Offset(0, 4.h),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/arrow.png',
                                  width: 25.w,
                                  height: 25.h,
                                  color: isDark ? Colors.white : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Centered "tips" title
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final text = "tips";
                          final textStyle = GoogleFonts.homemadeApple(
                            fontSize: 44.sp,
                            fontWeight: FontWeight.bold,
                          );

                          // Measure exact text size
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
                                  colors: [
                                    Color(0xFF590B8D),
                                    Color(0xFF786AC8)
                                  ],
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

                      const Spacer(),
                      SizedBox(width: 50.w),
                      SizedBox(height: 50.w),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),

                // Tip Title with Happy Monkey + Gradient
                LayoutBuilder(
                  builder: (context, constraints) {
                    final shader = LinearGradient(
                      colors: [Color(0xFF590B8D), Color(0xFF786AC8)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(
                        Rect.fromLTWH(0, 0, constraints.maxWidth, 0));
                    return Text(
                      "${item.icon} ${item.title}",
                      style: GoogleFonts.happyMonkey(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.w900,
                        foreground: Paint()..shader = shader,
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),

                // Description + Image Container
                Container(
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderColor, width: 0.75.w),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Description
                      Text(
                        "⭐ ${item.fullDescription}",
                        style: GoogleFonts.instrumentSans(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Image centered
                      Container(
                        height: 400.h,
                        alignment: Alignment.center,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.asset(
                            item.image,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                if (item.disclaimer == false) SizedBox(height: 20.h),

                if (item.disclaimer == true)
                  Padding(
                    padding: EdgeInsets.only(bottom: 24.h),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Plain red icon (no circle)
                        SizedBox(width: 13.w),

                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 18.sp,
                        ),
                        SizedBox(width: 3.w),

                        // Text
                        Expanded(
                          child: Text(
                            "Please consult your doctor before activating the exercises",
                            style: GoogleFonts.instrumentSans(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w400,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // More Source
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(18.r),
                  decoration: BoxDecoration(
                    color: containerColor,
                    borderRadius: BorderRadius.circular(24.r),
                    border: Border.all(color: borderColor, width: 0.75.w),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        "⭐ More Source:",
                        style: GoogleFonts.happyMonkey(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 8.h),

                      // Clickable link
                      GestureDetector(
                        onTap: () => launchUrl(Uri.parse(item.link)),
                        child: Text(
                          item.link,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.blue[200]
                                : const Color.fromRGBO(118, 113, 113, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 50.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
