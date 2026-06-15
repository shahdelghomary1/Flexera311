import 'package:flexera/core/assets/assets_manager.dart';
import 'package:flexera/core/themes/app_theme.dart';
import 'package:flexera/model/auth_models/booking_model.dart';
import 'package:flexera/view/screens/booking_success_screen.dart';
import 'package:flexera/view/screens/paymob_webview_screen.dart';
import 'package:flexera/view/widget/booking_receipt_card.dart';
import 'package:flexera/view/widget/booking_stepper.dart';
import 'package:flexera/view_model/appointment_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BookingReviewScreen extends StatelessWidget {
  final BookingModel doctor;

  const BookingReviewScreen({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = Provider.of<AppointmentViewModel>(context);

    final logoColor = isDark ? Colors.white : Colors.black;

    return AppTheme.bookingReviewBackground(
      context,
      Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 25.h),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 44.h,
                            width: 44.w,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Image.asset(
                                'assets/icons/arrow.png',
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              "Payment",
                              style: GoogleFonts.quicksand(
                                fontSize: 26.sp,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 44.w),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    const BookingStepper(currentStep: 3),
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          child: BookingReceiptCard(
                            doctor: doctor,
                            date:
                                viewModel.nextDays[viewModel.selectedDateIndex],
                            time: viewModel
                                    .availableTimes[
                                        viewModel.selectedTimeIndex ?? 0]
                                    .from ??
                                "",
                            consultationFee: viewModel.consultationFee,
                            adminFee: viewModel.adminFee,
                            total: viewModel.totalAmount,
                            cardHolderName: viewModel.cardHolderName,
                            last4Digits: viewModel.cardLast4Digits,
                            isSelected: viewModel.isCardSelected,
                            onCardTap: () {
                              viewModel.toggleCardSelection();
                            },
                            logoWidget: Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "F",
                                  style: GoogleFonts.grandHotel(
                                    fontSize: 40.sp,
                                    color: logoColor,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(width: 2.w),
                                Transform.translate(
                                  offset: Offset(0, -2.h),
                                  child: Image.asset(
                                    AssetsManager.logoIcon,
                                    width: 35.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                Transform.translate(
                                  offset: const Offset(0, 0),
                                  child: Text(
                                    "exera",
                                    style: GoogleFonts.grandHotel(
                                      fontSize: 40.sp,
                                      color: logoColor,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 235.w,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          String? paymentUrl =
                              await viewModel.initiatePaymobBooking(
                            doctorId: doctor.id.toString(),
                          );

                          if (paymentUrl != null && context.mounted) {
                            final bool? result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PaymobWebViewScreen(paymentUrl: paymentUrl),
                              ),
                            );

                            // if (result == true) {
                            //   if (context.mounted) {
                            //     Navigator.pushNamedAndRemoveUntil(
                            //       context,
                            //       "/success",
                            //           (route) => false,
                            //     );
                            //   }
                            // }
                            // else {
                            //   debugPrint("Payment Cancelled or Failed");
                            // }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                        child: viewModel.isPaymobLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Ink(
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [
                                    Color(0xFF786AC8),
                                    Color(0xFF5B5F9C)
                                  ]),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Confirm",
                                    style: GoogleFonts.quicksand(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25.sp,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
