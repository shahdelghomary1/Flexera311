import 'package:flexera/core/themes/app_theme.dart';
import 'package:flexera/view/screens/appointment_screen.dart';
import 'package:flexera/view/widget/booking_stepper.dart';
import 'package:flexera/view/widget/doctor_tile.dart';
import 'package:flexera/view/widget/home_notification_icon.dart';
import 'package:flexera/view_model/booking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChooseDoctorsScreen extends StatelessWidget {
  const ChooseDoctorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = Provider.of<BookingViewModel>(context);
    final allDoctors = viewModel.allDoctors;

    return AppTheme.chooseDoctorsBackground(
      context,
      Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 30.h),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                          color: isDark ? Colors.black : Colors.white,
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
                          "Choose Doctors",
                          style: GoogleFonts.quicksand(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Color(0xFF363738)),
                        ),
                      ),
                    ),
                    Stack(
                      children: [
                        const HomeNotificationIcon(),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              const BookingStepper(currentStep: 1),
              SizedBox(height: 50.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Our Doctors",
                      style: GoogleFonts.quicksand(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF383838),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 15.h),
              Expanded(
                child: GridView.builder(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  itemCount: allDoctors.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 35,
                    mainAxisExtent: 140,
                  ),
                  itemBuilder: (context, index) {
                    final doc = allDoctors[index];
                    return DoctorTile(
                      doctorName: doc.name,
                      image: doc.image,
                      isCompact: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppointmentScreen(
                              doctor: doc,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
