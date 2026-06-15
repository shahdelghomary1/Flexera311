import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/themes/app_colors.dart';
import '../../model/doc_model/time_slot_model.dart';
import '../../view_model/clinic_schedule_view_model.dart';

class ClinicScheduleHeader extends StatelessWidget {
  const ClinicScheduleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
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
          SizedBox(width: 60.w),
          Expanded(
            child: Text(
              'Clinic Schedule',
              style: GoogleFonts.quicksand(
                fontSize: 24.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
              ),
            ),
          ),
          // Container(
          //   width: 40,
          //   height: 40,
          //   decoration: BoxDecoration(
          //     color: isDark ? AppColors.cardDark : Colors.white,
          //     borderRadius: BorderRadius.circular(12),
          //     boxShadow: [
          //       BoxShadow(
          //         color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
          //         blurRadius: 8,
          //         spreadRadius: 1,
          //       ),
          //     ],
          //   ),
          //   child: Stack(
          //     children: [
          //       Center(
          //         child: Icon(
          //           Icons.notifications_outlined,
          //           size: 24,
          //           color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
          //         ),
          //       ),
          //       Positioned(
          //         right: 8,
          //         top: 8,
          //         child: Container(
          //           width: 8,
          //           height: 8,
          //           decoration: const BoxDecoration(
          //             color: Colors.red,
          //             shape: BoxShape.circle,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class CalendarWidget extends StatelessWidget {
  final ClinicScheduleViewModel viewModel;

  const CalendarWidget({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMonthNavigation(context, isDark),
          SizedBox(height: 20.h),
          _buildWeekDaysHeader(isDark),
          SizedBox(height: 12.h),
          _buildCalendarGrid(context, isDark),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: viewModel.previousMonth,
          child: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.blackcolor : AppColors.backgroundcolor1,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.chevron_left,
              color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
            ),
          ),
        ),
        Text(
          DateFormat('MMMM yyyy').format(viewModel.displayedMonth),
          style: GoogleFonts.quicksand(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
          ),
        ),
        GestureDetector(
          onTap: viewModel.nextMonth,
          child: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.blackcolor : AppColors.backgroundcolor1,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.chevron_right,
              color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekDaysHeader(bool isDark) {
    final weekDays = ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekDays.map((day) {
        return Expanded(
          child: Center(
            child: Text(
              day,
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: day == 'Su' || day == 'Sa'
                    ? const Color(0xFF8B5CF6)
                    : (isDark ? AppColors.whiteColor : AppColors.blackcolor),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context, bool isDark) {
    final firstDayOfMonth = DateTime(
      viewModel.displayedMonth.year,
      viewModel.displayedMonth.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      viewModel.displayedMonth.year,
      viewModel.displayedMonth.month + 1,
      0,
    );

    final startingWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final previousMonth = DateTime(
      viewModel.displayedMonth.year,
      viewModel.displayedMonth.month - 1,
    );
    final lastDayOfPreviousMonth = DateTime(
      previousMonth.year,
      previousMonth.month + 1,
      0,
    ).day;

    List<Widget> dayWidgets = [];

    for (int i = startingWeekday - 1; i >= 0; i--) {
      final day = lastDayOfPreviousMonth - i;
      dayWidgets.add(
        _buildDayCell(
          context,
          day.toString(),
          false,
          isDark,
          isOtherMonth: true,
        ),
      );
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(
        viewModel.displayedMonth.year,
        viewModel.displayedMonth.month,
        day,
      );
      final isSelected = viewModel.isDateSelected(date);
      final isToday = viewModel.isToday(date);
      final hasAppointments = viewModel.getSchedulesForDate(date).isNotEmpty;

      dayWidgets.add(
        GestureDetector(
          onTap: () => viewModel.selectDate(date),
          child: _buildDayCell(
            context,
            day.toString(),
            isSelected,
            isDark,
            isToday: isToday,
            hasAppointments: hasAppointments,
          ),
        ),
      );
    }

    final remainingCells = 42 - dayWidgets.length;
    for (int day = 1; day <= remainingCells; day++) {
      dayWidgets.add(
        _buildDayCell(
          context,
          day.toString(),
          false,
          isDark,
          isOtherMonth: true,
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children: dayWidgets,
    );
  }

  Widget _buildDayCell(
    BuildContext context,
    String day,
    bool isSelected,
    bool isDark, {
    bool isToday = false,
    bool isOtherMonth = false,
    bool hasAppointments = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF8B5CF6)
            : (isToday
                ? (isDark
                    ? const Color(0xFF8B5CF6).withOpacity(0.2)
                    : const Color(0xFF8B5CF6).withOpacity(0.1))
                : Colors.transparent),
        borderRadius: BorderRadius.circular(12),
        border: hasAppointments && !isSelected
            ? Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.5),
                width: 2.w,
              )
            : null,
      ),
      child: Center(
        child: Text(
          day,
          style: GoogleFonts.inter(
            fontSize: 15.sp,
            fontWeight: isSelected || isToday || hasAppointments
                ? FontWeight.w600
                : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : (isOtherMonth
                    ? (isDark ? Colors.white24 : Colors.black26)
                    : (hasAppointments
                        ? const Color(0xFF8B5CF6)
                        : (isDark
                            ? AppColors.whiteColor
                            : AppColors.blackcolor))),
          ),
        ),
      ),
    );
  }
}

class ScheduleListWidget extends StatefulWidget {
  final ClinicScheduleViewModel viewModel;
  final VoidCallback onAddMore;

  const ScheduleListWidget({
    super.key,
    required this.viewModel,
    required this.onAddMore,
  });

  @override
  State<ScheduleListWidget> createState() => _ScheduleListWidgetState();
}

class _ScheduleListWidgetState extends State<ScheduleListWidget> {
  final Map<int, String> _showingTimePicker = {};
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final schedules = widget.viewModel.getSchedulesForDate(
      widget.viewModel.selectedDate,
    );

    if (schedules.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 20.w),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'No schedules for this date',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.whiteColor.withOpacity(0.7)
                    : AppColors.darkgraycolor,
              ),
            ),
            SizedBox(height: 16.h),
            _buildAddMoreButton(context, isDark),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black38, width: 1.w),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16.r,
                    color: const Color(0xFF8B5CF6),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    DateFormat(
                      'EEEE, MMMM d',
                    ).format(widget.viewModel.selectedDate),
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w500,
                      color:
                          isDark ? AppColors.whiteColor : AppColors.blackcolor,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20.r,
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            SizedBox(height: 20.h),
            ...schedules.asMap().entries.map(
                  (entry) => _buildScheduleItem(
                      context, entry.key, entry.value, isDark),
                ),
            SizedBox(height: 12.h),
            _buildAddMoreButton(context, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildScheduleItem(
    BuildContext context,
    int index,
    ScheduleItem schedule,
    bool isDark,
  ) {
    final showingPicker = _showingTimePicker[index];

    return GestureDetector(
      onTap: () {
        if (showingPicker != null) {
          setState(() {
            _showingTimePicker.remove(index);
          });
        }
      },
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 12.h),
            width: 335.w,
            height: 54.h,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Text(
                    'From',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppColors.whiteColor.withOpacity(0.7)
                          : AppColors.darkgraycolor,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_showingTimePicker[index] == 'from') {
                          _showingTimePicker.remove(index);
                        } else {
                          _showingTimePicker[index] = 'from';
                        }
                      });
                    },
                    child: Container(
                      width: 90.w,
                      height: 26.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isDark
                              ? AppColors.whiteColor.withOpacity(0.2)
                              : AppColors.blackcolor.withOpacity(0.2),
                          width: 0.5.h,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _formatTime(schedule.fromTime),
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackcolor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20.w),
                  Text(
                    'To',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppColors.whiteColor.withOpacity(0.7)
                          : AppColors.darkgraycolor,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_showingTimePicker[index] == 'to') {
                          _showingTimePicker.remove(index);
                        } else {
                          _showingTimePicker[index] = 'to';
                        }
                      });
                    },
                    child: Container(
                      width: 90.w,
                      height: 26.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isDark
                              ? AppColors.whiteColor.withOpacity(0.2)
                              : AppColors.blackcolor.withOpacity(0.2),
                          width: 0.5.w,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _formatTime(schedule.toTime),
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackcolor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  GestureDetector(
                    onTap: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor:
                              isDark ? AppColors.cardDark : Colors.white,
                          title: Text(
                            'Delete Time Slot',
                            style: GoogleFonts.quicksand(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.whiteColor
                                  : AppColors.blackcolor,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to delete this time slot?',
                            style: GoogleFonts.inter(
                              fontSize: 14.sp,
                              color: isDark
                                  ? AppColors.whiteColor.withOpacity(0.7)
                                  : AppColors.darkgraycolor,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.whiteColor
                                      : AppColors.blackcolor,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Delete',
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          await widget.viewModel.deleteTimeSlot(schedule);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Time slot deleted successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            String errorMessage = e.toString();
                            if (errorMessage.startsWith('Exception: ')) {
                              errorMessage =
                                  errorMessage.substring('Exception: '.length);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: Container(
                      width: 17.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close,
                        size: 12.r,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showingPicker != null)
            _buildTimePickerDropdown(
              context,
              index,
              schedule,
              showingPicker,
              isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildTimePickerDropdown(
    BuildContext context,
    int index,
    ScheduleItem schedule,
    String pickerType,
    bool isDark,
  ) {
    final currentTime =
        pickerType == 'from' ? schedule.fromTime : schedule.toTime;
    int selectedHour =
        currentTime.hourOfPeriod == 0 ? 12 : currentTime.hourOfPeriod;
    int selectedMinute = currentTime.minute;
    bool isAM = currentTime.period == DayPeriod.am;

    return StatefulBuilder(
      builder: (context, setTimeState) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          width: 119.w,
          height: 136.h,
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.5),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setTimeState(() {
                            selectedHour =
                                selectedHour < 12 ? selectedHour + 1 : 1;
                          });
                          final hour = isAM
                              ? (selectedHour == 12 ? 0 : selectedHour)
                              : (selectedHour == 12 ? 12 : selectedHour + 12);
                          final newTime = TimeOfDay(
                            hour: hour,
                            minute: selectedMinute,
                          );
                          if (pickerType == 'from') {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              newTime,
                              null,
                            );
                          } else {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              null,
                              newTime,
                            );
                          }
                        },
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: const Color(0xFF8B5CF6),
                          size: 16.r,
                        ),
                      ),
                      Text(
                        selectedHour.toString().padLeft(2, '0'),
                        style: GoogleFonts.inter(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.whiteColor
                              : AppColors.blackcolor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setTimeState(() {
                            selectedHour =
                                selectedHour > 1 ? selectedHour - 1 : 12;
                          });
                          final hour = isAM
                              ? (selectedHour == 12 ? 0 : selectedHour)
                              : (selectedHour == 12 ? 12 : selectedHour + 12);
                          final newTime = TimeOfDay(
                            hour: hour,
                            minute: selectedMinute,
                          );
                          if (pickerType == 'from') {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              newTime,
                              null,
                            );
                          } else {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              null,
                              newTime,
                            );
                          }
                        },
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: const Color(0xFF8B5CF6),
                          size: 16.sp,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Text(
                      ':',
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.whiteColor
                            : AppColors.blackcolor,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setTimeState(() {
                            selectedMinute = (selectedMinute + 15) % 60;
                          });
                          final hour = isAM
                              ? (selectedHour == 12 ? 0 : selectedHour)
                              : (selectedHour == 12 ? 12 : selectedHour + 12);
                          final newTime = TimeOfDay(
                            hour: hour,
                            minute: selectedMinute,
                          );
                          if (pickerType == 'from') {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              newTime,
                              null,
                            );
                          } else {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              null,
                              newTime,
                            );
                          }
                        },
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: const Color(0xFF8B5CF6),
                          size: 16.sp,
                        ),
                      ),
                      Text(
                        selectedMinute.toString().padLeft(2, '0'),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.whiteColor
                              : AppColors.blackcolor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setTimeState(() {
                            selectedMinute = (selectedMinute - 15 + 60) % 60;
                          });
                          final hour = isAM
                              ? (selectedHour == 12 ? 0 : selectedHour)
                              : (selectedHour == 12 ? 12 : selectedHour + 12);
                          final newTime = TimeOfDay(
                            hour: hour,
                            minute: selectedMinute,
                          );
                          if (pickerType == 'from') {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              newTime,
                              null,
                            );
                          } else {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              null,
                              newTime,
                            );
                          }
                        },
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: const Color(0xFF8B5CF6),
                          size: 16.r,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              // AM/PM toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setTimeState(() {
                        isAM = true;
                      });
                      final hour = selectedHour == 12 ? 0 : selectedHour;
                      final newTime = TimeOfDay(
                        hour: hour,
                        minute: selectedMinute,
                      );
                      if (pickerType == 'from') {
                        widget.viewModel.updateScheduleTime(
                          schedule,
                          newTime,
                          null,
                        );
                      } else {
                        widget.viewModel.updateScheduleTime(
                          schedule,
                          null,
                          newTime,
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: isAM
                            ? const Color(0xFF8B5CF6)
                            : (isDark
                                ? AppColors.blackcolor.withOpacity(0.3)
                                : AppColors.backgroundcolor1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'AM',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: isAM
                              ? Colors.white
                              : (isDark
                                  ? AppColors.whiteColor
                                  : AppColors.blackcolor),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  GestureDetector(
                    onTap: () {
                      setTimeState(() {
                        isAM = false;
                      });
                      final hour = selectedHour == 12 ? 12 : selectedHour + 12;
                      final newTime = TimeOfDay(
                        hour: hour,
                        minute: selectedMinute,
                      );
                      if (pickerType == 'from') {
                        widget.viewModel.updateScheduleTime(
                          schedule,
                          newTime,
                          null,
                        );
                      } else {
                        widget.viewModel.updateScheduleTime(
                          schedule,
                          null,
                          newTime,
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: !isAM
                            ? const Color(0xFF8B5CF6)
                            : (isDark
                                ? AppColors.blackcolor.withOpacity(0.3)
                                : AppColors.backgroundcolor1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'PM',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: !isAM
                              ? Colors.white
                              : (isDark
                                  ? AppColors.whiteColor
                                  : AppColors.blackcolor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimeList(
    BuildContext context,
    int index,
    ScheduleItem schedule,
    String pickerType,
    TimeOfDay currentTime,
    bool isDark,
  ) {
    final times = _generateTimeList();

    return Container(
      height: 200,
      child: ListView.builder(
        itemCount: times.length,
        itemBuilder: (context, timeIndex) {
          final time = times[timeIndex];
          final isSelected = time.hour == currentTime.hour &&
              time.minute == currentTime.minute;

          return GestureDetector(
            onTap: () {
              if (pickerType == 'from') {
                widget.viewModel.updateScheduleTime(schedule, time, null);
              } else {
                widget.viewModel.updateScheduleTime(schedule, null, time);
              }
              setState(() {
                _showingTimePicker.remove(index);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF8B5CF6).withOpacity(0.2)
                    : (isDark
                        ? AppColors.blackcolor.withOpacity(0.3)
                        : AppColors.backgroundcolor1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatTime(time),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFF8B5CF6)
                      : (isDark ? AppColors.whiteColor : AppColors.blackcolor),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<TimeOfDay> _generateTimeList() {
    final times = <TimeOfDay>[];
    for (int hour = 0; hour < 24; hour++) {
      for (int minute = 0; minute < 60; minute += 30) {
        times.add(TimeOfDay(hour: hour, minute: minute));
      }
    }
    return times;
  }

  void _showCustomTimePicker(
    BuildContext context,
    bool isDark,
    TimeOfDay initialTime,
    Function(TimeOfDay) onTimeChanged,
  ) {
    int selectedHour =
        initialTime.hourOfPeriod == 0 ? 12 : initialTime.hourOfPeriod;
    int selectedMinute = initialTime.minute;
    bool isAM = initialTime.period == DayPeriod.am;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Time',
                    style: GoogleFonts.quicksand(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? AppColors.whiteColor : AppColors.blackcolor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildNumberPicker(context, isDark, selectedHour, 1, 12, (
                        value,
                      ) {
                        setDialogState(() {
                          selectedHour = value;
                        });
                      }),
                      Text(
                        ' : ',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.whiteColor
                              : AppColors.blackcolor,
                        ),
                      ),
                      _buildNumberPicker(
                        context,
                        isDark,
                        selectedMinute,
                        0,
                        59,
                        (value) {
                          setDialogState(() {
                            selectedMinute = value;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                isAM = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isAM
                                    ? const Color(0xFF8B5CF6)
                                    : (isDark
                                        ? AppColors.blackcolor.withOpacity(
                                            0.3,
                                          )
                                        : AppColors.backgroundcolor1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'AM',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isAM
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.whiteColor
                                          : AppColors.blackcolor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                isAM = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: !isAM
                                    ? const Color(0xFF8B5CF6)
                                    : (isDark
                                        ? AppColors.blackcolor.withOpacity(
                                            0.3,
                                          )
                                        : AppColors.backgroundcolor1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PM',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: !isAM
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.whiteColor
                                          : AppColors.blackcolor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: isDark
                                ? AppColors.blackcolor.withOpacity(0.3)
                                : AppColors.backgroundcolor1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.whiteColor
                                  : AppColors.blackcolor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final hour = isAM
                                ? (selectedHour == 12 ? 0 : selectedHour)
                                : (selectedHour == 12 ? 12 : selectedHour + 12);
                            final newTime = TimeOfDay(
                              hour: hour,
                              minute: selectedMinute,
                            );
                            onTimeChanged(newTime);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF8B5CF6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'OK',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumberPicker(
    BuildContext context,
    bool isDark,
    int value,
    int min,
    int max,
    Function(int) onChanged,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (value < max) {
              onChanged(value + 1);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.keyboard_arrow_up,
              color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
            ),
          ),
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.blackcolor.withOpacity(0.3)
                : AppColors.backgroundcolor1,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (value > min) {
              onChanged(value - 1);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddMoreButton(BuildContext context, bool isDark) {
    return Center(
      child: GestureDetector(
        onTap: () {
          debugPrint('🔘 Add More button pressed');
          showDialog(
            context: context,
            builder: (context) => AddScheduleDialog(
              viewModel: widget.viewModel,
            ),
          );
        },
        child: Container(
          width: 195,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFD9D9D9).withOpacity(0.5),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                size: 16,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                'Add More',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class AddScheduleDialog extends StatefulWidget {
  final ClinicScheduleViewModel viewModel;

  const AddScheduleDialog({super.key, required this.viewModel});

  @override
  State<AddScheduleDialog> createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  late DateTime selectedDate;
  TimeOfDay fromTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay toTime = const TimeOfDay(hour: 10, minute: 0);

  @override
  void initState() {
    super.initState();
    selectedDate = widget.viewModel.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add Schedule',
              style: GoogleFonts.quicksand(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
              ),
            ),
            const SizedBox(height: 24),
            _buildDateSelector(context, isDark),
            const SizedBox(height: 16),
            _buildTimeSelector(context, isDark, true),
            const SizedBox(height: 16),
            _buildTimeSelector(context, isDark, false),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: isDark
                          ? AppColors.blackcolor.withOpacity(0.3)
                          : AppColors.backgroundcolor1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.whiteColor
                            : AppColors.blackcolor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      debugPrint('🔘 Add Schedule button pressed');
                      debugPrint('📅 Selected Date: $selectedDate');
                      debugPrint(
                          '⏰ From Time: ${fromTime.hour}:${fromTime.minute}');
                      debugPrint('⏰ To Time: ${toTime.hour}:${toTime.minute}');

                      // Format times as HH:mm for API
                      final fromFormatted =
                          '${fromTime.hour.toString().padLeft(2, '0')}:${fromTime.minute.toString().padLeft(2, '0')}';
                      final toFormatted =
                          '${toTime.hour.toString().padLeft(2, '0')}:${toTime.minute.toString().padLeft(2, '0')}';

                      debugPrint(
                          '📝 Formatted times: $fromFormatted - $toFormatted');

                      // Create time slot
                      final timeSlot = TimeSlotModel.fromJson({
                        'from': fromFormatted,
                        'to': toFormatted,
                      });

                      debugPrint(
                          '✅ TimeSlot created: ${timeSlot.from} - ${timeSlot.to}');

                      // Call API to create schedule
                      try {
                        debugPrint('📞 Calling viewModel.createSchedule...');
                        await widget.viewModel.createSchedule(
                          selectedDate,
                          [timeSlot],
                        );
                        debugPrint('✅ createSchedule completed successfully');
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Schedule added successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint('❌ Error in dialog: $e');
                        if (context.mounted) {
                          // Extract the actual error message
                          String errorMessage = e.toString();
                          if (errorMessage.startsWith('Exception: ')) {
                            errorMessage =
                                errorMessage.substring('Exception: '.length);
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(errorMessage),
                              backgroundColor: Colors.red,
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF8B5CF6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Add',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: const Color(0xFF8B5CF6),
                  onPrimary: Colors.white,
                  surface: isDark ? AppColors.cardDark : Colors.white,
                  onSurface:
                      isDark ? AppColors.whiteColor : AppColors.blackcolor,
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          setState(() {
            selectedDate = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.blackcolor.withOpacity(0.3)
              : AppColors.backgroundcolor1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 18,
              color: const Color(0xFF8B5CF6),
            ),
            const SizedBox(width: 12),
            Text(
              DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(BuildContext context, bool isDark, bool isFrom) {
    final time = isFrom ? fromTime : toTime;

    return GestureDetector(
      onTap: () => _showCustomTimePicker(context, isDark, isFrom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.blackcolor.withOpacity(0.3)
              : AppColors.backgroundcolor1,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(
              isFrom ? 'From' : 'To',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              _formatTime(time),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
              ),
            ),
            const Spacer(),
            Icon(Icons.access_time, size: 18, color: const Color(0xFF8B5CF6)),
          ],
        ),
      ),
    );
  }

  void _showCustomTimePicker(BuildContext context, bool isDark, bool isFrom) {
    final time = isFrom ? fromTime : toTime;
    int selectedHour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    int selectedMinute = time.minute;
    bool isAM = time.period == DayPeriod.am;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Select Time',
                    style: GoogleFonts.quicksand(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? AppColors.whiteColor : AppColors.blackcolor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hour picker
                      _buildNumberPicker(context, isDark, selectedHour, 1, 12, (
                        value,
                      ) {
                        setDialogState(() {
                          selectedHour = value;
                        });
                      }),
                      Text(
                        ':',
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.whiteColor
                              : AppColors.blackcolor,
                        ),
                      ),
                      _buildNumberPicker(
                        context,
                        isDark,
                        selectedMinute,
                        0,
                        59,
                        (value) {
                          setDialogState(() {
                            selectedMinute = value;
                          });
                        },
                      ),
                      const SizedBox(width: 12),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                isAM = true;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isAM
                                    ? const Color(0xFF8B5CF6)
                                    : (isDark
                                        ? AppColors.blackcolor.withOpacity(
                                            0.3,
                                          )
                                        : AppColors.backgroundcolor1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'AM',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isAM
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.whiteColor
                                          : AppColors.blackcolor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              setDialogState(() {
                                isAM = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: !isAM
                                    ? const Color(0xFF8B5CF6)
                                    : (isDark
                                        ? AppColors.blackcolor.withOpacity(
                                            0.3,
                                          )
                                        : AppColors.backgroundcolor1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'PM',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: !isAM
                                      ? Colors.white
                                      : (isDark
                                          ? AppColors.whiteColor
                                          : AppColors.blackcolor),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: isDark
                                ? AppColors.blackcolor.withOpacity(0.3)
                                : AppColors.backgroundcolor1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.whiteColor
                                  : AppColors.blackcolor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            final hour = isAM
                                ? (selectedHour == 12 ? 0 : selectedHour)
                                : (selectedHour == 12 ? 12 : selectedHour + 12);
                            final newTime = TimeOfDay(
                              hour: hour,
                              minute: selectedMinute,
                            );
                            setState(() {
                              if (isFrom) {
                                fromTime = newTime;
                              } else {
                                toTime = newTime;
                              }
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF8B5CF6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'OK',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumberPicker(
    BuildContext context,
    bool isDark,
    int value,
    int min,
    int max,
    Function(int) onChanged,
  ) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (value < max) {
              onChanged(value + 1);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.keyboard_arrow_up,
              color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
            ),
          ),
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.blackcolor.withOpacity(0.3)
                : AppColors.backgroundcolor1,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              value.toString().padLeft(2, '0'),
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            if (value > min) {
              onChanged(value - 1);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.keyboard_arrow_down,
              color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class UpcomingAppointmentsWidget extends StatefulWidget {
  final ClinicScheduleViewModel viewModel;

  const UpcomingAppointmentsWidget({super.key, required this.viewModel});

  @override
  State<UpcomingAppointmentsWidget> createState() =>
      _UpcomingAppointmentsWidgetState();
}

class _UpcomingAppointmentsWidgetState
    extends State<UpcomingAppointmentsWidget> {
  final Map<int, String> _showingTimePicker = {};
  final Map<int, bool> _expandedDates = {};

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final upcomingAppointments = widget.viewModel.getUpcomingAppointments();

    if (upcomingAppointments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Appointments',
            style: GoogleFonts.quicksand(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
            ),
          ),
          const SizedBox(height: 16),
          ...upcomingAppointments.entries.map((entry) {
            final dateIndex = entry.key.millisecondsSinceEpoch;
            return _buildDateSection(
              context,
              entry.key,
              entry.value,
              isDark,
              dateIndex,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    DateTime date,
    List<ScheduleItem> schedules,
    bool isDark,
    int dateIndex,
  ) {
    final isExpanded = _expandedDates[dateIndex] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _expandedDates[dateIndex] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black38, width: 1),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, MMMM d').format(date),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color:
                          isDark ? AppColors.whiteColor : AppColors.blackcolor,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 20,
                    color: const Color(0xFF8B5CF6),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: 12),
            ...schedules.asMap().entries.map((entry) {
              final globalIndex = date.millisecondsSinceEpoch + entry.key;
              return _buildUpcomingScheduleItem(
                context,
                globalIndex,
                entry.value,
                isDark,
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildUpcomingScheduleItem(
    BuildContext context,
    int index,
    ScheduleItem schedule,
    bool isDark,
  ) {
    final showingPicker = _showingTimePicker[index];

    return GestureDetector(
      onTap: () {
        if (showingPicker != null) {
          setState(() {
            _showingTimePicker.remove(index);
          });
        }
      },
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            width: 335,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Text(
                    'From',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppColors.whiteColor.withOpacity(0.7)
                          : AppColors.darkgraycolor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_showingTimePicker[index] == 'from') {
                          _showingTimePicker.remove(index);
                        } else {
                          _showingTimePicker[index] = 'from';
                        }
                      });
                    },
                    child: Container(
                      width: 90,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isDark
                              ? AppColors.whiteColor.withOpacity(0.2)
                              : AppColors.blackcolor.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _formatTime(schedule.fromTime),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackcolor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'To',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppColors.whiteColor.withOpacity(0.7)
                          : AppColors.darkgraycolor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_showingTimePicker[index] == 'to') {
                          _showingTimePicker.remove(index);
                        } else {
                          _showingTimePicker[index] = 'to';
                        }
                      });
                    },
                    child: Container(
                      width: 90,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: isDark
                              ? AppColors.whiteColor.withOpacity(0.2)
                              : AppColors.blackcolor.withOpacity(0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _formatTime(schedule.toTime),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.blackcolor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () async {
                      // Show confirmation dialog
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          backgroundColor:
                              isDark ? AppColors.cardDark : Colors.white,
                          title: Text(
                            'Delete Time Slot',
                            style: GoogleFonts.quicksand(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.whiteColor
                                  : AppColors.blackcolor,
                            ),
                          ),
                          content: Text(
                            'Are you sure you want to delete this time slot?',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.whiteColor.withOpacity(0.7)
                                  : AppColors.darkgraycolor,
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.whiteColor
                                      : AppColors.blackcolor,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Delete',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirmed == true) {
                        try {
                          await widget.viewModel.deleteTimeSlot(schedule);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Time slot deleted successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            String errorMessage = e.toString();
                            if (errorMessage.startsWith('Exception: ')) {
                              errorMessage =
                                  errorMessage.substring('Exception: '.length);
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 4),
                              ),
                            );
                          }
                        }
                      }
                    },
                    child: Container(
                      width: 17,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9).withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.close,
                        size: 12,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showingPicker != null)
            _buildTimePickerDropdown(
              context,
              index,
              schedule,
              showingPicker,
              isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildTimePickerDropdown(
    BuildContext context,
    int index,
    ScheduleItem schedule,
    String pickerType,
    bool isDark,
  ) {
    final currentTime =
        pickerType == 'from' ? schedule.fromTime : schedule.toTime;
    int selectedHour =
        currentTime.hourOfPeriod == 0 ? 12 : currentTime.hourOfPeriod;
    int selectedMinute = currentTime.minute;
    bool isAM = currentTime.period == DayPeriod.am;

    return StatefulBuilder(
      builder: (context, setTimeState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          width: 119,
          height: 136,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setTimeState(() {
                            selectedHour =
                                selectedHour < 12 ? selectedHour + 1 : 1;
                          });
                          final hour = isAM
                              ? (selectedHour == 12 ? 0 : selectedHour)
                              : (selectedHour == 12 ? 12 : selectedHour + 12);
                          final newTime = TimeOfDay(
                            hour: hour,
                            minute: selectedMinute,
                          );
                          if (pickerType == 'from') {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              newTime,
                              null,
                            );
                          } else {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              null,
                              newTime,
                            );
                          }
                        },
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: const Color(0xFF8B5CF6),
                          size: 16,
                        ),
                      ),
                      Text(
                        selectedHour.toString().padLeft(2, '0'),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.whiteColor
                              : AppColors.blackcolor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setTimeState(() {
                            selectedHour =
                                selectedHour > 1 ? selectedHour - 1 : 12;
                          });
                          final hour = isAM
                              ? (selectedHour == 12 ? 0 : selectedHour)
                              : (selectedHour == 12 ? 12 : selectedHour + 12);
                          final newTime = TimeOfDay(
                            hour: hour,
                            minute: selectedMinute,
                          );
                          if (pickerType == 'from') {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              newTime,
                              null,
                            );
                          } else {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              null,
                              newTime,
                            );
                          }
                        },
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: const Color(0xFF8B5CF6),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      ':',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.whiteColor
                            : AppColors.blackcolor,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setTimeState(() {
                            selectedMinute = (selectedMinute + 15) % 60;
                          });
                          final hour = isAM
                              ? (selectedHour == 12 ? 0 : selectedHour)
                              : (selectedHour == 12 ? 12 : selectedHour + 12);
                          final newTime = TimeOfDay(
                            hour: hour,
                            minute: selectedMinute,
                          );
                          if (pickerType == 'from') {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              newTime,
                              null,
                            );
                          } else {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              null,
                              newTime,
                            );
                          }
                        },
                        child: Icon(
                          Icons.keyboard_arrow_up,
                          color: const Color(0xFF8B5CF6),
                          size: 16,
                        ),
                      ),
                      Text(
                        selectedMinute.toString().padLeft(2, '0'),
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.whiteColor
                              : AppColors.blackcolor,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setTimeState(() {
                            selectedMinute = (selectedMinute - 15 + 60) % 60;
                          });
                          final hour = isAM
                              ? (selectedHour == 12 ? 0 : selectedHour)
                              : (selectedHour == 12 ? 12 : selectedHour + 12);
                          final newTime = TimeOfDay(
                            hour: hour,
                            minute: selectedMinute,
                          );
                          if (pickerType == 'from') {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              newTime,
                              null,
                            );
                          } else {
                            widget.viewModel.updateScheduleTime(
                              schedule,
                              null,
                              newTime,
                            );
                          }
                        },
                        child: Icon(
                          Icons.keyboard_arrow_down,
                          color: const Color(0xFF8B5CF6),
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      setTimeState(() {
                        isAM = true;
                      });
                      final hour = selectedHour == 12 ? 0 : selectedHour;
                      final newTime = TimeOfDay(
                        hour: hour,
                        minute: selectedMinute,
                      );
                      if (pickerType == 'from') {
                        widget.viewModel.updateScheduleTime(
                          schedule,
                          newTime,
                          null,
                        );
                      } else {
                        widget.viewModel.updateScheduleTime(
                          schedule,
                          null,
                          newTime,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isAM
                            ? const Color(0xFF8B5CF6)
                            : (isDark
                                ? AppColors.blackcolor.withOpacity(0.3)
                                : AppColors.backgroundcolor1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'AM',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isAM
                              ? Colors.white
                              : (isDark
                                  ? AppColors.whiteColor
                                  : AppColors.blackcolor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: () {
                      setTimeState(() {
                        isAM = false;
                      });
                      final hour = selectedHour == 12 ? 12 : selectedHour + 12;
                      final newTime = TimeOfDay(
                        hour: hour,
                        minute: selectedMinute,
                      );
                      if (pickerType == 'from') {
                        widget.viewModel.updateScheduleTime(
                          schedule,
                          newTime,
                          null,
                        );
                      } else {
                        widget.viewModel.updateScheduleTime(
                          schedule,
                          null,
                          newTime,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: !isAM
                            ? const Color(0xFF8B5CF6)
                            : (isDark
                                ? AppColors.blackcolor.withOpacity(0.3)
                                : AppColors.backgroundcolor1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'PM',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: !isAM
                              ? Colors.white
                              : (isDark
                                  ? AppColors.whiteColor
                                  : AppColors.blackcolor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
