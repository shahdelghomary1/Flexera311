import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class BannerBookingWidget extends StatelessWidget {
  const BannerBookingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 150.h,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Stack(
        children: [
          Transform.rotate(
            angle: -180 * 3.1415926535 / 180,
            child: Image.asset(
              "assets/images/bannerbooking.jpg",
              fit: BoxFit.cover,
              width: screenWidth,
              height: 150.h,
            ),
          ),
          Positioned(
            left: 30,
            top: 30,
            child: SizedBox(
              width: screenWidth * 0.45,
              child: Text(
                "Get your 15% \noff in your frist booking",
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontSize: 25.sp,
                  height: 1.3.h,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Positioned(
            right: 30.w,
            top: 25.h,
            child: Transform.rotate(
              angle: 0.2,
              child: ClipOval(
                child: Image.asset(
                  "assets/images/bookingoff3.png",
                  width: 45.49.w,
                  height: 44.97.h,
                ),
              ),
            ),
          ),
          Positioned(
            right: 110.w,
            top: 33.h,
            child: Transform.rotate(
              angle: -0.1,
              child: ClipOval(
                child: Image.asset(
                  "assets/images/bookingoff2.png",
                  width: 45.w,
                  height: 45.h,
                ),
              ),
            ),
          ),
          Positioned(
            right: 57.w,
            bottom: 25.h,
            child: ClipOval(
              child: Image.asset(
                "assets/images/bookingoff4.png",
                width: 45.51.w,
                height: 44.95.h,
              ),
            ),
          ),
          Positioned(
            right: 132.w,
            bottom: 20.h,
            child: Transform.rotate(
              angle: -0.2,
              child: ClipOval(
                child: Image.asset(
                  "assets/images/bookingoff1.png",
                  width: 45.5.w,
                  height: 44.97.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
