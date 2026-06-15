import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widget/patients_widgets.dart';
import '../../view_model/patients_view_model.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';
import '../../core/network/cache_helper.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  bool _isInit = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => PatientsViewModel(),
      child: Consumer<PatientsViewModel>(
        builder: (context, viewModel, _) {
          if (_isInit) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _fetchPatients(viewModel);
            });
            _isInit = false;
          }

          return Scaffold(
            extendBody: true,
            backgroundColor:
                isDark ? AppColors.blackcolor : AppColors.backgroundcolor1,
            body: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    color: isDark
                        ? const Color(0xFF131313)
                        : const Color(0xFFF8F8F9),
                  ),
                ),
                Positioned(
                  top: 10.h,
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
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 20.h,
                          ),
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
                                    color:
                                        isDark ? Colors.white10 : Colors.white,
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
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  'My Patients',
                                  style: GoogleFonts.quicksand(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.whiteColor
                                        : AppColors.blackcolor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: 12.w),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        const Center(child: PatientsSearchBar()),
                        SizedBox(height: 20.h),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (viewModel.isLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (viewModel.errorMessage != null) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.wifi_off,
                                          size: 50.sp, color: Colors.redAccent),
                                      SizedBox(height: 10.h),
                                      Text(
                                        'Connection Failed',
                                        style: GoogleFonts.quicksand(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 5.h),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20.w),
                                        child: Text(
                                          'Could not fetch patients. Please check internet.\n${viewModel.errorMessage}',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12.sp),
                                        ),
                                      ),
                                      SizedBox(height: 20.h),
                                      ElevatedButton(
                                        onPressed: () {
                                          viewModel.clearError();
                                          _fetchPatients(viewModel);
                                        },
                                        child: const Text('Retry'),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              if (viewModel.patients.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_off,
                                          size: 50.sp, color: Colors.grey),
                                      SizedBox(height: 10.h),
                                      Text(
                                        "No patients yet",
                                        style: GoogleFonts.quicksand(
                                          fontSize: 20.sp,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20.w,
                                  vertical: 10.h,
                                ),
                                itemCount: viewModel.patients.length,
                                itemBuilder: (context, index) {
                                  final patient = viewModel.patients[index];
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 16.h),
                                    child: Center(
                                      child: PatientCard(
                                        patient: patient,
                                        onEdit: () => viewModel.onEditPatient(
                                          context,
                                          patient,
                                        ),
                                        onTap: () => viewModel.onPatientTap(
                                          context,
                                          patient,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 80.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _fetchPatients(PatientsViewModel viewModel) async {
    final doctorId = CacheHelper.getData(key: 'doctor_id');

    if (doctorId != null) {
      await viewModel.fetchPatients(doctorId: doctorId);
    } else {
      viewModel.clearError();
      viewModel.fetchPatients(doctorId: "333333");
    }
  }
}
