import 'package:flexera/core/assets/assets_manager.dart';
import 'package:flexera/core/themes/app_colors.dart';
import 'package:flexera/core/themes/app_theme.dart';
import 'package:flexera/view/screens/appointment_screen.dart';
import 'package:flexera/view/screens/choose_doctors_screen.dart';
import 'package:flexera/view/widget/banner_booking_widget.dart';
import 'package:flexera/view/widget/doctor_tile.dart';
import 'package:flexera/view/widget/home_notification_icon.dart';
import 'package:flexera/view_model/account_info_view_model.dart';
import 'package:flexera/view_model/booking_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BookingViewModel>(context, listen: false).fetchAllDoctors();

      Provider.of<AccountInfoViewModel>(context, listen: false).getMyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppTheme.bookingBackground(
      context,
      Material(
        color: Colors.transparent,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Consumer<AccountInfoViewModel>(
                  builder: (context, accountVm, child) {
                    ImageProvider userAvatar;
                    if (accountVm.networkImageUrl != null &&
                        accountVm.networkImageUrl!.isNotEmpty) {
                      userAvatar = NetworkImage(accountVm.networkImageUrl!);
                    } else {
                      userAvatar = const AssetImage(AssetsManager.avatar);
                    }

                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 24.r,
                            backgroundImage: userAvatar,
                            backgroundColor: Colors.grey.shade200,
                            onBackgroundImageError: (_, __) {},
                          ),
                          SizedBox(width: 12.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Welcome back 👋',
                                    style: GoogleFonts.inter(
                                      fontSize: 15.sp,
                                      color: AppColors.darkgraycolor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                accountVm.fullNameController.text.isNotEmpty
                                    ? accountVm.fullNameController.text
                                        .split(' ')[0]
                                    : 'User',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Stack(
                            children: [
                              const HomeNotificationIcon(),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                Consumer<BookingViewModel>(
                  builder: (context, viewModel, child) {
                    final displayDoctors = _searchText.isEmpty
                        ? viewModel.topDoctors
                        : viewModel.searchDoctors(_searchText);

                    return Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
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
                                    color: isDark ? Colors.black : Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0.r),
                                    child: Image.asset('assets/icons/arrow.png',
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          offset: Offset(0, 4.h),
                                          blurRadius: 10),
                                    ],
                                  ),
                                  child: TextField(
                                    onChanged: (val) {
                                      setState(() {
                                        _searchText = val;
                                      });
                                    },
                                    style: TextStyle(
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black),
                                    decoration: InputDecoration(
                                      hintText:
                                          "Search for your favorite doctor...",
                                      hintStyle: GoogleFonts.instrumentSans(
                                          fontSize: 14.sp,
                                          color: isDark
                                              ? Colors.white54
                                              : const Color(0xFF383838)),
                                      filled: true,
                                      fillColor:
                                          isDark ? Colors.black : Colors.white,
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 12.h, horizontal: 16.w),
                                      suffixIcon: Padding(
                                        padding: EdgeInsets.all(6.0.r),
                                        child: Container(
                                          width: 32.w,
                                          height: 32.h,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFF786AC8),
                                                Color(0xFF5B5F9C)
                                              ],
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Image.asset(
                                                "assets/icons/searchbooking.png",
                                                width: 16.w,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          borderSide: BorderSide.none),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                        const BannerBookingWidget(),
                        SizedBox(height: 20.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: Row(
                            children: [
                              Text(
                                _searchText.isEmpty
                                    ? "Our Doctors"
                                    : "Search Results",
                                style: GoogleFonts.quicksand(
                                  fontSize: 35,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF383838),
                                ),
                              ),
                              const Spacer(),
                              if (_searchText.isEmpty)
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                const ChooseDoctorsScreen()));
                                  },
                                  child: Row(
                                    children: [
                                      ShaderMask(
                                        shaderCallback: (Rect bounds) {
                                          return const LinearGradient(
                                            colors: [
                                              AppColors.gradientStart,
                                              AppColors.darkpurplecolor
                                            ],
                                            begin: Alignment.centerRight,
                                            end: Alignment.centerLeft,
                                          ).createShader(bounds);
                                        },
                                        child: Text(
                                          "See All",
                                          style: GoogleFonts.quicksand(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14.sp,
                                              color: Colors.white),
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                    ],
                                  ),
                                )
                            ],
                          ),
                        ),
                        SizedBox(height: 15.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                          child: viewModel.isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : viewModel.errorMessage.isNotEmpty
                                  ? Center(child: Text(viewModel.errorMessage))
                                  : displayDoctors.isEmpty
                                      ? Center(
                                          child: Padding(
                                            padding:
                                                EdgeInsets.only(top: 50.0.h),
                                            child: Text(
                                              "No doctors found",
                                              style: GoogleFonts.quicksand(
                                                  fontSize: 16.sp,
                                                  color: isDark
                                                      ? Colors.white70
                                                      : Colors.black54),
                                            ),
                                          ),
                                        )
                                      : GridView.builder(
                                          shrinkWrap: true,
                                          itemCount: displayDoctors.length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 20,
                                            mainAxisSpacing: 25,
                                            mainAxisExtent: 190,
                                          ),
                                          itemBuilder: (context, index) {
                                            final doc = displayDoctors[index];
                                            return DoctorTile(
                                              doctorName: doc.name,
                                              image: doc.image,
                                              isCompact: false,
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        AppointmentScreen(
                                                      doctor: doc,
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                        ),
                        SizedBox(height: 30.h),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
