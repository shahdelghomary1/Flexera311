import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flexera/view/screens/tips_screen.dart';
import 'package:flexera/view/widget/home_notification_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flexera/core/assets/assets_manager.dart';
import 'package:flexera/core/themes/app_colors.dart';
import 'package:flexera/core/themes/app_theme.dart';
import 'package:flexera/view/screens/booking_screen.dart';
import 'package:flexera/view/screens/exercise_screen.dart';
import 'package:flexera/view/screens/health_overview_screen.dart';
import 'package:flexera/view/widget/appointment_card.dart';
import 'package:flexera/view/widget/treatment_tile.dart';
import 'package:flexera/view_model/account_info_view_model.dart';
import 'package:flexera/view/screens/account_info_screen.dart';

class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen>
    with AutomaticKeepAliveClientMixin<HomeContentScreen> {
  @override
  bool get wantKeepAlive => true;

  late AccountInfoViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = AccountInfoViewModel();
    _viewModel.getMyData();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: AppTheme.background(
        context,
        Padding(
          padding: EdgeInsets.all(16.r),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Consumer<AccountInfoViewModel>(
                  builder: (context, vm, child) {
                    return GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AccountInfoScreen(),
                          ),
                        );
                        vm.getMyData();
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 44.w,
                            height: 44.h,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: _buildUserImage(vm),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back 👋',
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    color: AppColors.darkgraycolor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  vm.fullNameController.text.isNotEmpty
                                      ? vm.fullNameController.text
                                      : ' ',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const HomeNotificationIcon(),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Appointments',
                      style: GoogleFonts.quicksand(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                const AppointmentCard(),
                SizedBox(height: 10.h),
                Text(
                  'My Treatment',
                  style: GoogleFonts.quicksand(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8.r),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 15,
                      crossAxisSpacing: 35,
                      children: [
                        TreatmentTile(
                          title: 'Exercise',
                          subtitle: 'Your Recovery Exercises',
                          assetPath: AssetsManager.exercisedoc,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExerciseScreen(),
                              ),
                            );
                          },
                        ),
                        TreatmentTile(
                          title: 'Progress',
                          subtitle: 'Your Healing Progress',
                          assetPath: AssetsManager.progress,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HealthOverviewScreen(),
                              ),
                            );
                          },
                        ),
                        TreatmentTile(
                          title: 'Tips',
                          subtitle: 'Guidance for Faster Recovery',
                          assetPath: AssetsManager.tips,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => TipsScreen(),
                              ),
                            );
                          },
                        ),
                        TreatmentTile(
                          title: 'Booking',
                          subtitle: 'Book or Reschedule Easily',
                          assetPath: AssetsManager.booking,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const BookingScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserImage(AccountInfoViewModel vm) {
    if (vm.networkImageUrl != null && vm.networkImageUrl!.isNotEmpty) {
      return Image.network(
        vm.networkImageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Image.asset(
          AssetsManager.avatar,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Image.asset(
        AssetsManager.avatar,
        fit: BoxFit.cover,
      );
    }
  }
}
