import 'package:flexera/model/auth_models/booking_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class BookingReceiptCard extends StatelessWidget {
  final BookingModel doctor;
  final DateTime date;
  final String time;
  final double consultationFee;
  final double adminFee;
  final double total;
  final Widget logoWidget;
  final String cardHolderName;
  final String last4Digits;

  final bool isSelected;
  final VoidCallback onCardTap;

  const BookingReceiptCard({
    super.key,
    required this.doctor,
    required this.date,
    required this.time,
    required this.consultationFee,
    required this.adminFee,
    required this.total,
    required this.logoWidget,
    required this.cardHolderName,
    required this.last4Digits,
    required this.isSelected,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF514F53);
    final purpleColor =  Color(0xFF590B8D);

    final formattedDate = DateFormat('EEE, MMMM d').format(date);

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF000000) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: isDark ? Colors.white24 : Colors.grey.shade300),
        boxShadow: [
          if (!isDark)
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: Offset(0, 5.h))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              logoWidget,
              Text("Details",
                  style: GoogleFonts.instrumentSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2F2F33))),
            ],
          ),
          SizedBox(height: 5.h),
          const Divider(),
          SizedBox(height: 10.h),
          _buildInfoRow("Doctor", "${doctor.name}", textColor),
          _buildInfoRow("Appointment", "$formattedDate - $time", textColor),
          _buildFeeRow("Confirmation Fee", "EGP $consultationFee", textColor,
              purpleColor),
          // _buildFeeRow(
          //     "Administrative Fees", "EGP $adminFee", textColor, purpleColor),
          SizedBox(height: 15.h),
          const Divider(),
          SizedBox(height: 5.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Total:",
                  style: GoogleFonts.quicksand(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: textColor)),
              Text("EGP $total",
                  style: GoogleFonts.quicksand(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: purpleColor)),
            ],
          ),
          SizedBox(height: 15.h),
          Center(
            child: Text(
              "Your payment is secured and encrypted.",
              style: GoogleFonts.instrumentSans(
                fontSize: 11.sp,
                color: const Color(0xFF353637),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color textColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text("$label :",
                style: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: textColor)),
          ),
          Expanded(
            child: Text(value,
                style: GoogleFonts.quicksand(
                  fontSize: 13.sp,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow(
      String label, String value, Color textColor, Color priceColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0.h),
      child: Row(
        children: [
          Text("$label :  ",
              style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                  color: textColor)),
          Text(value,
              style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                  color: priceColor)),
        ],
      ),
    );
  }
}
