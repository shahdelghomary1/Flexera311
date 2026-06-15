import 'package:flexera/model/auth_models/booking_model.dart';
import 'package:flexera/view/screens/booking_review_screen.dart';
import 'package:flexera/view/widget/appointment_widgets.dart';
import 'package:flexera/view_model/appointment_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class AppointmentBottomSheet extends StatelessWidget {
  final String doctorId;
  final BookingModel doctor;

  const AppointmentBottomSheet(
      {super.key, required this.doctorId, required this.doctor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<AppointmentViewModel>(
      builder: (context, viewModel, child) {
        final sheetColor = isDark ? const Color(0xFF0D0D0D) : Colors.white;

        final currentMonth = viewModel.availableDates.isNotEmpty &&
                viewModel.selectedDateIndex < viewModel.availableDates.length
            ? DateFormat('MMMM yyyy')
                .format(viewModel.availableDates[viewModel.selectedDateIndex])
            : DateFormat('MMMM yyyy').format(DateTime.now());

        return Container(
          height: MediaQuery.of(context).size.height * 0.55,
          decoration: BoxDecoration(
            color: sheetColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(50),
              topRight: Radius.circular(50),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: Offset(0, -5.h))
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40)),
            child: Stack(
              children: [
                Positioned(
                  left: 3.w,
                  top: 130.h,
                  child: Image.asset(
                    "assets/images/sheet_bg.png",
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
                  child: Column(
                    children: [
                      SectionHeader(
                          title: "Select Date",
                          iconPath: "assets/icons/calendar-02.png",
                          subtitle: currentMonth),
                      SizedBox(height: 15.h),
                      SizedBox(
                        height: 75.h,
                        child: viewModel.isScheduleLoading
                            ? const Center(child: CircularProgressIndicator())
                            : viewModel.availableDates.isEmpty
                                ? Center(
                                    child: Text(
                                      "No dates available",
                                      style: GoogleFonts.quicksand(
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.grey),
                                    ),
                                  )
                                : ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: viewModel.availableDates.length,
                                    separatorBuilder: (_, __) =>
                                        SizedBox(width: 12.w),
                                    itemBuilder: (context, index) {
                                      return DateItem(
                                        date: viewModel.availableDates[index],
                                        isSelected:
                                            viewModel.selectedDateIndex ==
                                                index,
                                        onTap: () =>
                                            viewModel.selectDate(index),
                                      );
                                    },
                                  ),
                      ),
                      SizedBox(height: 5.h),
                      const SectionHeader(
                        title: "Select Time",
                        iconPath: 'assets/icons/stopwatch-04.png',
                      ),
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 15.w,
                            vertical: 9.h,
                          ),
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withOpacity(0.05)
                                : Colors.black.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: viewModel.isScheduleLoading
                              ? const Center(child: CircularProgressIndicator())
                              : viewModel.availableTimes.isEmpty
                                  ? Center(
                                      child: Text(
                                        "No times available",
                                        style: GoogleFonts.quicksand(
                                            color: isDark
                                                ? Colors.white70
                                                : Colors.grey),
                                      ),
                                    )
                                  : GridView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount:
                                          viewModel.availableTimes.length,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 9,
                                        childAspectRatio: 2.4,
                                      ),
                                      itemBuilder: (context, index) {
                                        final slotObject =
                                            viewModel.availableTimes[index];

                                        final String timeText =
                                            slotObject.from ?? "";
                                        final bool isBooked =
                                            slotObject.isBooked;

                                        return TimeItem(
                                          time: timeText,
                                          isBooked: isBooked,
                                          isSelected: !isBooked &&
                                              viewModel.selectedTimeIndex ==
                                                  index,
                                          onTap: isBooked
                                              ? null
                                              : () =>
                                                  viewModel.selectTime(index),
                                        );
                                      },
                                    ),
                        ),
                      ),
                      SizedBox(
                        width: 235.w,
                        height: 54.h,
                        child: ElevatedButton(
                          onPressed: viewModel.selectedTimeIndex != null
                              ? () async {
                                  await viewModel.checkUserHasCard();
                                  if (context.mounted) {
                                    {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BookingReviewScreen(
                                              doctor: doctor),
                                        ),
                                      );
                                    }
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14))),
                          child: Ink(
                            decoration: BoxDecoration(
                                gradient: viewModel.selectedTimeIndex != null
                                    ? const LinearGradient(colors: [
                                        Color(0xFF786AC8),
                                        Color(0xFF5B5F9C)
                                      ])
                                    : const LinearGradient(
                                        colors: [Colors.grey, Colors.grey]),
                                borderRadius: BorderRadius.circular(14)),
                            child: Container(
                              alignment: Alignment.center,
                              child: Text("Continue",
                                  style: GoogleFonts.quicksand(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 25.sp,
                                  )),
                            ),
                          ),
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
