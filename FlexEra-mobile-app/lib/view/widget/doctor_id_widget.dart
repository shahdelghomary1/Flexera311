import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';
import '../../view_model/doctor_id_view_model.dart';
import '../screens/login_screen.dart';

class DoctorIdWidget extends StatefulWidget {
  const DoctorIdWidget({super.key});

  @override
  State<DoctorIdWidget> createState() => _DoctorIdWidgetState();
}

class _DoctorIdWidgetState extends State<DoctorIdWidget> {
  static const int digits = 6;
  final List<FocusNode> _focusNodes = List.generate(digits, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<DoctorIdViewModel>();
    for (int i = 0; i < digits; i++) {
      viewModel.idControllers[i].addListener(() {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  Widget _buildOtpBox(int index, DoctorIdViewModel viewModel) {
    return SizedBox(
      width: 50.w,
      height: 53.h,
      child: TextField(
        controller: viewModel.idControllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style:
            GoogleFonts.quicksand(fontSize: 18.sp, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: AppColors.graycolor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide:
                BorderSide(color: AppColors.darkpurplecolor, width: 2.w),
          ),
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: (v) {
          viewModel.clearError();
          if (v.isNotEmpty && index < digits - 1) {
            _focusNodes[index + 1].requestFocus();
          } else if (v.isEmpty && index > 0) {
            _focusNodes[index - 1].requestFocus();
          }
        },
      ),
    );
  }

  Future<void> _onContinue(
      BuildContext context, DoctorIdViewModel viewModel) async {
    if (!viewModel.isIdComplete) return;

    final isValid = await viewModel.validateId();

    if (isValid && context.mounted) {
      final doctorId = viewModel.currentId;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            isDoctorLogin: true,
            doctorId: doctorId,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Consumer<DoctorIdViewModel>(
      builder: (context, viewModel, child) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: bottomPadding + 20.h),
            child: Column(
              children: [
                SizedBox(height: 150.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Welcome to',
                      style: GoogleFonts.quicksand(
                        fontSize: 28.sp,
                        color: AppColors.blackcolor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'F',
                      style: GoogleFonts.grandHotel(
                        fontSize: 40.sp,
                        color: AppColors.lightblackcolor,
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(-6.w, 0),
                      child: Image.asset(
                        AssetsManager.logoIcon,
                        width: 65.w,
                        height: 65.w,
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(-6.w, 0),
                      child: Text(
                        'exera',
                        style: GoogleFonts.grandHotel(
                          fontSize: 40.sp,
                          color: AppColors.lightblackcolor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Before you start using your account, please enter your Doctor ID registered with the medical center.',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 14.sp,
                        color: AppColors.darkgraycolor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 60.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Enter Your ID',
                      style: GoogleFonts.instrumentSans(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: AppColors.idcolor,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(digits, (i) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: _buildOtpBox(i, viewModel),
                    );
                  }),
                ),
                SizedBox(height: 10.h),
                if (viewModel.showError)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h, left: 24.w),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red, size: 16.w),
                        SizedBox(width: 6.w),
                        Text(
                          viewModel.errorText,
                          style: GoogleFonts.instrumentSans(
                            fontSize: 10.sp,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 18.h),
                SizedBox(
                  width: 210.w,
                  height: 50.h,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: viewModel.isIdComplete && !viewModel.isLoading
                          ? const LinearGradient(
                              colors: [
                                AppColors.botton2color,
                                AppColors.lightpurplecolor,
                              ],
                            )
                          : null,
                      color: !viewModel.isIdComplete || viewModel.isLoading
                          ? AppColors.graycolor.withOpacity(0.3)
                          : null,
                      borderRadius: BorderRadius.circular(15.r),
                    ),
                    child: ElevatedButton(
                      onPressed: viewModel.isIdComplete && !viewModel.isLoading
                          ? () => _onContinue(context, viewModel)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                      ),
                      child: viewModel.isLoading
                          ? SizedBox(
                              width: 20.w,
                              height: 20.w,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Continue',
                              style: GoogleFonts.instrumentSans(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    "If you don't have a Doctor ID, please contact the center's administration to get one",
                    style: GoogleFonts.instrumentSans(
                      fontSize: 15.sp,
                      color: AppColors.darkgraycolor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                SizedBox(height: 18.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, size: 15.w, color: Colors.red),
                      SizedBox(width: 4.w),
                      Text(
                        'Do not share your Doctor ID with anyone',
                        style: GoogleFonts.instrumentSans(
                          fontSize: 15.sp,
                          color: AppColors.darkgraycolor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        );
      },
    );
  }
}
