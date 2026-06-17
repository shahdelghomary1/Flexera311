import 'package:flexera/view/screens/booking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_theme.dart';
import '../../view_model/appointment_card_view_model.dart';

class AppointmentCard extends StatelessWidget {
  const AppointmentCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppointmentCardViewModel(),
      child: Consumer<AppointmentCardViewModel>(
        builder: (context, viewModel, child) {
          if (!viewModel.hasAppointment) {
            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BookingScreen()),
                );
                viewModel.getAppointmentSummary();
              },
              child: _buildNoAppointmentCard(context),
            );
          }

          return GestureDetector(
            onTap: () => _showAppointmentsHistory(context, viewModel),
            child: Container(
              constraints: BoxConstraints(minHeight: 140.h),
              decoration: BoxDecoration(
                gradient: Theme.of(context).appointmentGradient,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDoctorInfo(viewModel),
                  SizedBox(height: 16.h),
                  _buildDateTimeInfo(viewModel),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAppointmentsHistory(
    BuildContext context,
    AppointmentCardViewModel viewModel,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DefaultTabController(
          length: 2,
          child: Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              gradient: Theme.of(context).appointmentGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            ),
            child: Column(
              children: [
                SizedBox(height: 12.h),
                Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 20.h, bottom: 10.h),
                  child: Text(
                    "My Appointments",
                    style: GoogleFonts.quicksand(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                TabBar(
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withOpacity(0.6),
                  labelStyle: GoogleFonts.quicksand(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                  tabs: const [
                    Tab(text: "Upcoming"),
                    Tab(text: "Past"),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildTabContent(viewModel.upcomingAppointments, false),
                      _buildTabContent(viewModel.pastAppointments, true),
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

  Widget _buildTabContent(List<dynamic> appointments, bool isPast) {
    if (appointments.isEmpty) {
      return Center(
        child: Text(
          "No appointments found",
          style: GoogleFonts.quicksand(color: Colors.white70, fontSize: 16.sp),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(20.r),
      itemCount: appointments.length,
      itemBuilder: (context, index) =>
          _buildAppointmentTile(appointments[index], isPast: isPast),
    );
  }

  Widget _buildAppointmentTile(dynamic apt, {bool isPast = false}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25.r,
            backgroundImage: apt['doctor']['image'] != null
                ? NetworkImage(apt['doctor']['image'])
                : const AssetImage(AssetsManager.avatar) as ImageProvider,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  apt['doctor']['name'] ?? 'Doctor',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "${apt['date']} • ${apt['time']}",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13.sp,
                  ),
                ),
              ],
            ),
          ),
          if (isPast) const Icon(Icons.check_circle, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildNoAppointmentCard(BuildContext context) {
    return Container(
      height: 140.h,
      decoration: BoxDecoration(
        gradient: Theme.of(context).appointmentGradient,
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "No Appointments",
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.white.withOpacity(0.5)),
                ),
                child: Row(
                  children: [
                    Text(
                      "Book Now",
                      style: GoogleFonts.quicksand(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(width: 5.w),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Icon(Icons.calendar_today_rounded, color: Colors.white, size: 30.sp),
        ],
      ),
    );
  }

  Widget _buildDoctorInfo(AppointmentCardViewModel viewModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30.r,
          backgroundImage: viewModel.doctorImage.isNotEmpty
              ? NetworkImage(viewModel.doctorImage)
              : const AssetImage(AssetsManager.doctor) as ImageProvider,
        ),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                viewModel.doctorName,
                style: GoogleFonts.quicksand(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "Physiotherapy Session",
                style: GoogleFonts.quicksand(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 40.w,
          width: 40.w,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Image.asset(
            "assets/images/rehab.png",
            width: 24.w,
            height: 24.h,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeInfo(AppointmentCardViewModel viewModel) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  color: Colors.white,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    viewModel.dateDisplay,
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.w),
            width: 1.5.w,
            height: 20.h,
            color: Colors.white.withOpacity(0.4),
          ),
          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    viewModel.timeDisplay,
                    style: GoogleFonts.quicksand(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
