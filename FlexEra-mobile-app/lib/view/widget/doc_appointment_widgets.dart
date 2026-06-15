import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../../core/assets/assets_manager.dart';
import '../../view_model/doc_appointment_view_model.dart';

class DocAppointmentScaffold extends StatelessWidget {
  const DocAppointmentScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => DocAppointmentViewModel(),
      child: Scaffold(
        extendBody: true,
        backgroundColor:
            isDark ? AppColors.blackcolor : AppColors.backgroundcolor1,
        body: const DocAppointmentBody(),
        // bottomNavigationBar: Consumer<DocAppointmentViewModel>(
        //   builder: (context, viewModel, _) {
        //     return DocNavBar(
        //       currentIndex: viewModel.selectedNavIndex,
        //       onTap: (index) => viewModel.onNavBarTap(index, context),
        //     );
        //   },
        // ),
      ),
    );
  }
}

class DocAppointmentBody extends StatelessWidget {
  const DocAppointmentBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<DocAppointmentViewModel>(
      builder: (context, viewModel, _) {
        return Stack(
          children: [
            Positioned.fill(
              child: Container(
                color:
                    isDark ? const Color(0xFF131313) : const Color(0xFFF8F8F9),
              ),
            ),
            Positioned(
              top: -10.h,
              left: -10.w,
              right: -10.w,
              child: Image.asset(
                AssetsManager.backhometopdark,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: 69.h,
              left: -10.w,
              child: Opacity(
                opacity: 0.99,
                child: Image.asset(
                  AssetsManager.appointment_image,
                  width: 422.w,
                  height: 700.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    const DocAppointmentHeader(),
                    SizedBox(height: 20.h),
                    const AppointmentTabBar(),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: AppointmentList(
                        appointments: viewModel.currentAppointments,
                        onCancel: (apt) =>
                            viewModel.onCancelAppointment(context, apt),
                        isPast: viewModel.selectedTabIndex == 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class DocAppointmentHeader extends StatelessWidget {
  const DocAppointmentHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(left: 20.w, right: 10.w, top: 40.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                'My Appointments',
                style: GoogleFonts.quicksand(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w700,
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

class AppointmentTabBar extends StatefulWidget {
  const AppointmentTabBar({super.key});

  @override
  State<AppointmentTabBar> createState() => _AppointmentTabBarState();
}

class _AppointmentTabBarState extends State<AppointmentTabBar> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<DocAppointmentViewModel>(
      builder: (context, viewModel, _) {
        final isUpcomingSelected = viewModel.selectedTabIndex == 0;

        return Center(
          child: Container(
            width: 330.w,
            height: 55.h,
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardDark
                  : const Color.fromARGB(240, 230, 230, 229),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => viewModel.setTabIndex(0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: isUpcomingSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.cardDark
                                : const Color.fromARGB(240, 230, 230, 229)),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: isUpcomingSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  offset: Offset(0, 4.h),
                                  blurRadius: 6.r,
                                  spreadRadius: 1.r,
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          'Upcoming',
                          style: GoogleFonts.quicksand(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: isUpcomingSelected
                                ? AppColors.blackcolor
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () => viewModel.setTabIndex(1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: !isUpcomingSelected
                            ? Colors.white
                            : (isDark
                                ? AppColors.cardDark
                                : const Color.fromARGB(240, 230, 230, 229)),
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: !isUpcomingSelected
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4.r,
                                  offset: Offset(0, 2.h),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: Text(
                          'Past',
                          style: GoogleFonts.quicksand(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: !isUpcomingSelected
                                ? AppColors.blackcolor
                                : (isDark ? Colors.white70 : Colors.black54),
                          ),
                        ),
                      ),
                    ),
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

class AppointmentList extends StatelessWidget {
  final List<Appointment> appointments;
  final Function(Appointment) onCancel;
  final bool isPast;

  const AppointmentList({
    super.key,
    required this.appointments,
    required this.onCancel,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const EmptyAppointmentState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Center(
            child: AppointmentCard(
              appointment: appointments[index],
              isPast: isPast,
            ),
          ),
        );
      },
    );
  }
}

class EmptyAppointmentState extends StatelessWidget {
  const EmptyAppointmentState({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 64.w,
            color: isDark ? Colors.white38 : Colors.black26,
          ),
          SizedBox(height: 16.h),
          Text(
            'No appointments',
            style: GoogleFonts.quicksand(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final bool isPast;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 320.w,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.blackcolor.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 10.r,
            spreadRadius: 2.r,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppointmentDateColumn(appointment: appointment),
          SizedBox(width: 12.w),
          CircleAvatar(
            radius: 22.r,
            backgroundImage: appointment.patientAvatar.startsWith('http')
                ? NetworkImage(appointment.patientAvatar) as ImageProvider
                : AssetImage(appointment.patientAvatar),
            onBackgroundImageError: (_, __) {},
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: AppointmentDetails(
              appointment: appointment,
              isPast: isPast,
            ),
          ),
        ],
      ),
    );
  }
}

class AppointmentDateColumn extends StatelessWidget {
  final Appointment appointment;

  const AppointmentDateColumn({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          appointment.month,
          style: GoogleFonts.quicksand(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        Text(
          '${appointment.day}',
          style: GoogleFonts.quicksand(
            fontSize: 35.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
          ),
        ),
        Text(
          appointment.dayOfWeek,
          style: GoogleFonts.quicksand(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }
}

class AppointmentDetails extends StatelessWidget {
  final Appointment appointment;
  final bool isPast;

  const AppointmentDetails({
    super.key,
    required this.appointment,
    required this.isPast,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          appointment.patientName,
          style: GoogleFonts.quicksand(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
          ),
        ),
        SizedBox(height: 4.h),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timing : ${appointment.time}',
              style: GoogleFonts.quicksand(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Status: ${appointment.status}',
              style: GoogleFonts.quicksand(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
      ],
    );
  }
}
