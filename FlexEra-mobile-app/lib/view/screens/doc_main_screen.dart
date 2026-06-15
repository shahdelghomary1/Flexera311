import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../widget/doc_navbar.dart';
import '../widget/doc_home_widgets.dart';
import '../widget/doc_account_info_widgets.dart';
import '../widget/doc_settings_widgets.dart';
import '../../view_model/doc_main_view_model.dart';
import '../../view_model/doc_home_view_model.dart';
import '../../view_model/doc_account_info_view_model.dart';
import '../../view_model/doc_settings_view_model.dart';
import '../../view_model/clinic_schedule_view_model.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';

class DocMainScreen extends StatefulWidget {
  const DocMainScreen({super.key});

  @override
  State<DocMainScreen> createState() => _DocMainScreenState();
}

class _DocMainScreenState extends State<DocMainScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DocMainViewModel()),
        ChangeNotifierProvider(create: (_) => DocHomeViewModel()),
        ChangeNotifierProvider(
          create: (_) => DocAccountInfoViewModel()..loadDoctorData(),
        ),
        ChangeNotifierProvider(create: (_) => DocSettingsViewModel()),
        ChangeNotifierProvider(
          create: (_) => ClinicScheduleViewModel()..fetchSchedules(),
        ),
      ],
      child: Consumer<DocMainViewModel>(
        builder: (context, mainViewModel, _) {
          return Scaffold(
            extendBody: true,
            backgroundColor:
                isDark ? AppColors.blackcolor : AppColors.backgroundcolor1,
            body: IndexedStack(
              index: mainViewModel.selectedNavIndex,
              children: const [
                DocHomeBody(),
                DocSettingsBody(),
                DocAccountInfoBody(),
                DocAboutFlexeraBody(),
              ],
            ),
            bottomNavigationBar: DocNavBar(
              currentIndex: mainViewModel.navBarIndex,
              onTap: (index) => mainViewModel.onNavBarTap(index),
            ),
          );
        },
      ),
    );
  }
}

/// Home body widget
class DocHomeBody extends StatelessWidget {
  const DocHomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<DocHomeViewModel>(
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
              left: -10.w,
              right: -10.w,
              child: Image.asset(
                AssetsManager.backhometopdark,
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              bottom: -39.h,
              left: -21.w,
              child: Opacity(
                opacity: 0.99,
                child: Image.asset(
                  AssetsManager.homedocdown,
                  width: 487.w,
                  height: 420.h,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Positioned.fill(
              child: SafeArea(
                child: Column(
                  children: [
                    const DocHomeHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 20.h,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const DocOverviewHeader(),
                            SizedBox(height: 30.h),
                            Center(
                              child: MyPatientsCard(
                                onTap: () =>
                                    viewModel.navigateToPatients(context),
                              ),
                            ),
                            SizedBox(height: 40.h),
                            Center(
                              child: AppointmentsCard(
                                onTap: () =>
                                    viewModel.navigateToAppointments(context),
                              ),
                            ),
                            SizedBox(height: 40.h),
                            Center(
                              child: ClinicSchedule(
                                onTap: () =>
                                    viewModel.navigateToClinicSchedule(context),
                              ),
                            ),
                            SizedBox(height: 40.h),
                            SizedBox(height: 80.h),
                          ],
                        ),
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
