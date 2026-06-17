import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/themes/app_colors.dart';
import '../../core/assets/assets_manager.dart';
import 'login_screen.dart';
import 'doc_home_screen.dart';
import 'package:flexera/view/screens/doctor_id_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundcolor1,
      body: Stack(
        children: [
          Positioned(
            top: -268.3.h,
            left: 42.6.w,
            child: Transform.rotate(
              angle: 260 * 3.14159 / 180,
              child: Image.asset(
                AssetsManager.backgroundBlob,
                width: 554.w,
                height: 750.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: -160.h,
            child: Image.asset(
              AssetsManager.decorativeShape,
              width: 420.15.w,
              height: 520.52.h,
              fit: BoxFit.contain,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: Column(
              children: [
                SizedBox(height: 80.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 80.w),
                      child: Text(
                        'Choose',
                        style: GoogleFonts.homemadeApple(
                          fontSize: 48.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColors.darkpurplecolor,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 95.w),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'your role',
                          style: GoogleFonts.quicksand(
                            fontSize: 33.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.blackcolor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 70.h),
                Text(
                  'Please select your role to continue',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.quicksand(
                    fontSize: 16.sp,
                    color: AppColors.blackcolor.withOpacity(0.8),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 50.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRoleOption(
                      context: context,
                      imagePath: AssetsManager.userGif,
                      label: 'Patient',
                      roleId: 'user',
                      isSelected: selectedRole == 'user',
                      onTap: () {
                        setState(() {
                          selectedRole = 'user';
                        });

                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        }
                      },
                    ),
                    _buildRoleOption(
                      context: context,
                      imagePath: AssetsManager.doctorGif,
                      label: 'Doctor',
                      roleId: 'doctor',
                      isSelected: selectedRole == 'doctor',
                      onTap: () {
                        setState(() {
                          selectedRole = 'doctor';
                        });

                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DoctorIdScreen(),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required BuildContext context,
    required String imagePath,
    required String label,
    required String roleId,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 160.w,
                height: 160.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isSelected
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF9FBAF9), Color(0xFF590B8D)],
                        )
                      : null,
                  border: !isSelected
                      ? Border.all(
                          color: AppColors.purplecolor.withOpacity(0.3),
                          width: 1.w,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.purplecolor.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(4.0.r),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.whiteColor,
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: EdgeInsets.all(1.0.r),
                        child: Image.asset(imagePath, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ),
              ),
              if (isSelected)
                Positioned(
                  bottom: -15.h,
                  left: 64.w,
                  child: Container(
                    width: 32.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.purplecolor,
                    ),
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20.r,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 19.h),
          Text(
            label,
            style: GoogleFonts.quicksand(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.lightblackcolor,
            ),
          ),
        ],
      ),
    );
  }
}
