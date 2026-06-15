import 'package:flexera/core/themes/app_theme.dart';
import 'package:flexera/model/auth_models/booking_model.dart';
import 'package:flexera/view/widget/appointment_bottom_sheet.dart';
import 'package:flexera/view/widget/appointment_widgets.dart';
import 'package:flexera/view/widget/booking_stepper.dart';
import 'package:flexera/view/widget/doctor_image_widget.dart';
import 'package:flexera/view_model/appointment_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class AppointmentScreen extends StatefulWidget {
  final BookingModel doctor;

  const AppointmentScreen({super.key, required this.doctor});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppointmentViewModel>(context, listen: false)
          .fetchDoctorSchedule(widget.doctor.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AppTheme.bookingBackground(
      context,
      Scaffold(
        body: Stack(
          children: [
            Positioned(
              left: 0.w,
              right: 0.w,
              child: Image.asset(
                "assets/images/appointmentbackgroungheader.png",
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    const AppointmentHeader(),
                    SizedBox(height: 20.h),
                    const BookingStepper(currentStep: 2),
                  ],
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.28,
              left: 15.w,
              child: SizedBox(
                width: size.width * 0.55,
                child: DoctorInfoCard(doctor: widget.doctor),
              ),
            ),
            Positioned(
              right: -30.w,
              top: size.height * 0.24,
              child: SizedBox(
                height: size.height * 0.35,
                child: DoctorImageWidget(
                  imageUrl: widget.doctor.image,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: size.height * 0.45,
                child: AppointmentBottomSheet(
                  doctorId: widget.doctor.id,
                  doctor: widget.doctor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
