import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class MotivationalFooter extends StatelessWidget {
  final Color textColor;

  const MotivationalFooter({
    super.key,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(right: 30.w),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Text(
                  "Consistency beats intensity.",
                  style: GoogleFonts.homemadeApple(
                    fontSize: 18.sp,
                    color: textColor,
                  ),
                ),
                Positioned(
                  bottom: -30.h,
                  right: -60.w,
                  child: Text(
                    "Keep going!",
                    style: GoogleFonts.homemadeApple(
                      fontSize: 18.sp,
                      color: Colors.amberAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: 0.80.h,
              child: Image.asset(
                "assets/images/prorgessend.gif",
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
