import 'package:flexera/core/themes/app_colors.dart';
import 'package:flexera/model/auth_models/booking_model.dart';
import 'package:flexera/view_model/appointment_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AppointmentHeader extends StatelessWidget {
  const AppointmentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            height: 44.h,
            width: 44.w,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(0, 4.h),
                    blurRadius: 8),
              ],
              color: isDark ? Colors.white10 : Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(12.0.r),
              child: Image.asset('assets/icons/arrow.png',
                  color: isDark ? Colors.white : Colors.black),
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: Text(
              "Make your appointment",
              style: GoogleFonts.quicksand(
                fontSize: 26.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DoctorInfoCard extends StatelessWidget {
  final BookingModel doctor;

  const DoctorInfoCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AppointmentViewModel>(
      builder: (context, viewModel, child) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0.w),
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 29.w),
                Text(
                  doctor.name,
                  style: GoogleFonts.quicksand(
                    fontSize: 33.sp,
                    fontWeight: FontWeight.bold,
                    height: 1.2.h,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: 10.h),
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.quicksand(
                        fontSize: 18.sp,
                        color:
                            isDark ? Colors.white70 : AppColors.lightgraycolor,
                        fontWeight: FontWeight.bold),
                    children: [
                      const TextSpan(text: "Consultation Fee: "),
                      TextSpan(
                        text: "\n${viewModel.consultationFee.toInt()} EGP",
                        style: GoogleFonts.quicksand(
                          color: const Color(0xFF786AC8),
                          fontWeight: FontWeight.bold,
                          fontSize: 20.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String iconPath;
  final String? subtitle;

  const SectionHeader(
      {super.key, required this.title, required this.iconPath, this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              iconPath,
              color: isDark ? Colors.white : Colors.black,
            ),
            SizedBox(width: 8.w),
            Text(title,
                style: GoogleFonts.quicksand(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black)),
          ],
        ),
        if (subtitle != null)
          Row(
            children: [
              Icon(Icons.arrow_back_ios, size: 12.r, color: Colors.grey),
              Text(" $subtitle ",
                  style: GoogleFonts.quicksand(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.grey)),
              Icon(Icons.arrow_forward_ios, size: 12.r, color: Colors.grey),
            ],
          )
      ],
    );
  }
}

class DateItem extends StatefulWidget {
  final DateTime date;
  final bool isSelected;
  final VoidCallback onTap;

  const DateItem({
    super.key,
    required this.date,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<DateItem> createState() => _DateItemState();
}

class _DateItemState extends State<DateItem> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const gradient = LinearGradient(
      colors: [Color(0xFF786AC8), Color(0xFF5B5F9C)],
      begin: Alignment.centerRight,
      end: Alignment.centerLeft,
    );

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 45.w,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: widget.isSelected
                ? AppColors.purplecolor
                : (isDark ? Colors.white24 : Colors.grey.shade300),
            width: widget.isSelected ? 1.5 : 1.0,
          ),
          boxShadow: widget.isSelected
              ? [
                  BoxShadow(
                    color: AppColors.purplecolor.withOpacity(0.3),
                    blurRadius: 9,
                    offset: Offset(0, 6.h),
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              DateFormat('E').format(widget.date),
              style: GoogleFonts.quicksand(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: widget.isSelected
                    ? Color(0xFF3A393C)
                    : (isDark ? Colors.white54 : Colors.grey),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.isSelected ? gradient : null,
                color: widget.isSelected
                    ? null
                    : (isDark ? Colors.white10 : const Color(0xFFF4F3FD)),
              ),
              child: Center(
                child: Text(
                  DateFormat('d').format(widget.date),
                  style: GoogleFonts.quicksand(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: widget.isSelected
                        ? Colors.white
                        : (isDark ? Colors.white : Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeItem extends StatelessWidget {
  final String time;
  final bool isSelected;
  final bool isBooked;
  final VoidCallback? onTap;

  const TimeItem({
    super.key,
    required this.time,
    required this.isSelected,
    this.isBooked = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: isBooked ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isSelected && !isBooked
              ? const LinearGradient(
                  colors: [Color(0xFF786AC8), Color(0xFF5B5F9C)])
              : null,
          color: isBooked
              ? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey.shade300)
              : isSelected
                  ? null
                  : (isDark ? const Color(0xFF0F0F0F) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: isSelected || isBooked
              ? null
              : Border.all(
                  color:
                      isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade300,
                  width: 1.2.w,
                ),
        ),
        child: Center(
          child: Text(
            time,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
              decoration: isBooked ? TextDecoration.lineThrough : null,
              decorationColor: Colors.grey,
              color: isBooked
                  ? Colors.grey
                  : isSelected
                      ? Colors.white
                      : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }
}
