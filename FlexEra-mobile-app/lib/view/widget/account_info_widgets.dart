import 'dart:io';
import 'package:flexera/view/widget/home_notification_icon.dart';
import 'package:flexera/view_model/account_info_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';

class AccountInfoAppBar extends StatelessWidget {
  const AccountInfoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 40.h, right: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Builder(builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Container(
                width: 50.w,
                height: 50.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                      color: isDark ? Colors.white24 : Colors.black12,
                      width: 1.w),
                ),
                child: Center(
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        isDark ? Colors.white : Colors.grey, BlendMode.srcIn),
                    child: Image.asset('assets/icons/arrow.png',
                        width: 25.w, height: 25.h),
                  ),
                ),
              );
            }),
          ),
          Expanded(
            child: Center(
              child: Builder(builder: (context) {
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return ColorFiltered(
                  colorFilter: ColorFilter.mode(
                      isDark ? Colors.white : Colors.black, BlendMode.srcIn),
                  child: Text("Account Information",
                      style: GoogleFonts.instrumentSans(
                          fontSize: 25.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                          height: 1.0.h)),
                );
              }),
            ),
          ),
          SizedBox(width: 16),
          const Align(
            alignment: Alignment.centerRight,
            child: HomeNotificationIcon(),
          ),
        ],
      ),
    );
  }
}

class ProfileAvatarSection extends StatelessWidget {
  const ProfileAvatarSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AccountInfoViewModel>(context);
    return Center(
      child: Stack(
        children: [
          Container(
            width: 150.w,
            height: 150.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF9FBAF9),
                  Color(0xFF590B8D),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: ClipOval(
                child: Container(
                  color: Colors.white,
                  child: _buildImage(viewModel),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -1.h,
            right: -1.w,
            child: GestureDetector(
              onTap: () => viewModel.pickProfileImage(),
              child: Container(
                width: 32.w,
                height: 32.h,
                child: cameraIcon(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget cameraIcon(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      isDark ? "assets/icons/image-adddark.png" : "assets/icons/image-add.png",
      width: 16.r,
      height: 16.r,
    );
  }
}

class BasicDetailsSection extends StatelessWidget {
  const BasicDetailsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Basic Details',
            style: GoogleFonts.inter(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          hintText: 'Full Name',
          icon: ColorFiltered(
            colorFilter: ColorFilter.mode(
              isDark ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
            child: Image.asset(AssetsManager.field_icon, width: 20, height: 20),
          ),
          fieldType: TextFieldType.fullName,
          isReadOnly: false,
        ),
        SizedBox(height: 12.h),
        const CustomTextField(
          hintText: 'Email Address',
          fieldType: TextFieldType.email,
          isReadOnly: true,
        ),
        SizedBox(height: 12.h),
        CustomTextField(
          hintText: 'Phone Number',
          icon: ColorFiltered(
            colorFilter: ColorFilter.mode(
              isDark ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
            child: Image.asset(AssetsManager.field_icon,
                width: 20.w, height: 20.h),
          ),
          fieldType: TextFieldType.phone,
        ),
        SizedBox(height: 12.h),
        CustomTextField(
          hintText: 'Date of Birth',
          icon: ColorFiltered(
            colorFilter: ColorFilter.mode(
              isDark ? Colors.white : Colors.black,
              BlendMode.srcIn,
            ),
            child: Image.asset(AssetsManager.dob, width: 20.w, height: 20.h),
          ),
          isDatePicker: true,
          fieldType: TextFieldType.dateOfBirth,
        ),
      ],
    );
  }
}

enum TextFieldType {
  fullName,
  email,
  phone,
  password,
  dateOfBirth,
  height,
  weight,
}

class CustomTextField extends StatelessWidget {
  final String hintText;
  final Widget? icon;
  final bool isPassword;
  final bool isDatePicker;
  final TextFieldType fieldType;
  final bool isReadOnly;
  final String? unit;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.icon,
    this.isPassword = false,
    this.isDatePicker = false,
    required this.fieldType,
    this.isReadOnly = false,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AccountInfoViewModel>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    TextEditingController controller;
    TextInputType keyboardType;

    switch (fieldType) {
      case TextFieldType.fullName:
        controller = viewModel.fullNameController;
        keyboardType = TextInputType.text;
        break;
      case TextFieldType.email:
        controller = viewModel.emailController;
        keyboardType = TextInputType.emailAddress;
        break;
      case TextFieldType.phone:
        controller = viewModel.phoneController;
        keyboardType = TextInputType.phone;
        break;
      case TextFieldType.password:
        controller = viewModel.passwordController;
        keyboardType = TextInputType.text;
        break;
      case TextFieldType.dateOfBirth:
        controller = viewModel.dateOfBirthController;
        keyboardType = TextInputType.text;
        break;
      case TextFieldType.height:
        controller = viewModel.heightController;
        keyboardType = TextInputType.number;
        break;
      case TextFieldType.weight:
        controller = viewModel.weightController;
        keyboardType = TextInputType.number;
        break;
    }

    Color getBackgroundColor() {
      if (isReadOnly) {
        return isDark ? Colors.white10 : Colors.grey.shade200;
      }
      return isDark ? AppColors.cardDark : Colors.white;
    }

    return SizedBox(
      width: 330.w,
      height: 50.h,
      child: Container(
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.black45,
            width: 1.w,
          ),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          readOnly: isDatePicker || isReadOnly,
          onTap: (isDatePicker && !isReadOnly)
              ? () => viewModel.selectDateOfBirth(context)
              : null,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.instrumentSans(
              fontSize: 15.sp,
              color: isDark ? Colors.white54 : Colors.black54,
              fontWeight: FontWeight.w500,
              height: 2.h,
              letterSpacing: 0,
            ),
            suffixIcon: (icon != null && unit == null)
                ? Padding(padding: const EdgeInsets.all(12.0), child: icon)
                : (unit != null && icon != null)
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            unit!,
                            style: TextStyle(
                              fontFamily: "Quicksand",
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF413434),
                            ),
                          ),
                          const SizedBox(width: 6),
                          icon!,
                        ],
                      )
                    : null,
            suffix: (unit != null && icon == null)
                ? Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      unit!,
                      style: TextStyle(
                        fontFamily: "Quicksand",
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                        color: isDark ? Colors.white : const Color(0xFF413434),
                      ),
                    ),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          ),
          style: GoogleFonts.instrumentSans(
            fontSize: 15.sp,
            color: isReadOnly
                ? (isDark ? Colors.grey : Colors.grey.shade700)
                : (isDark ? AppColors.whiteColor : AppColors.blackcolor),
            fontWeight: FontWeight.w500,
            height: 1.0.h,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class GenderSection extends StatelessWidget {
  const GenderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AccountInfoViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(width: 20.w),
            Text('Gender',
                style: GoogleFonts.instrumentSans(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        isDark ? AppColors.whiteColor : AppColors.blackcolor)),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            SizedBox(width: 50.w),
            Expanded(
              child: GenderRadioButton(
                label: 'Female',
                isSelected: viewModel.selectedGender == 'Female',
                onTap: () => viewModel.setGender('Female'),
              ),
            ),
            SizedBox(width: 30.w),
            Expanded(
              child: GenderRadioButton(
                label: 'Male',
                isSelected: viewModel.selectedGender == 'Male',
                onTap: () => viewModel.setGender('Male'),
              ),
            ),
            SizedBox(width: 50.w),
          ],
        ),
      ],
    );
  }
}

class GenderRadioButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GenderRadioButton(
      {super.key,
      required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.h,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isSelected
                  ? AppColors.purplecolor
                  : isDark
                      ? Colors.white24
                      : Colors.black54,
              width: 1.w),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: GoogleFonts.quicksand(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.whiteColor
                          : AppColors.blackcolor)),
              Container(
                width: 14.w,
                height: 14.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: isSelected
                          ? AppColors.purplecolor
                          : Colors.grey.shade400,
                      width: 2),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                            width: 6.w,
                            height: 6.h,
                            decoration: const BoxDecoration(
                                color: AppColors.purplecolor,
                                shape: BoxShape.circle)))
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MeasurementsSection extends StatelessWidget {
  const MeasurementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Height',
                    style: GoogleFonts.instrumentSans(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.whiteColor
                            : AppColors.blackcolor)),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.only(left: 30.w),
                  child: SizedBox(
                    height: 40.h,
                    child: const CustomTextField(
                      hintText: '',
                      fieldType: TextFieldType.height,
                      unit: 'cm',
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 40.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Weight',
                    style: GoogleFonts.instrumentSans(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.whiteColor
                            : AppColors.blackcolor)),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.only(right: 30.w),
                  child: SizedBox(
                    height: 40.h,
                    child: const CustomTextField(
                      hintText: '',
                      fieldType: TextFieldType.weight,
                      unit: 'kg',
                    ),
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

class MedicalFileUploadSection extends StatelessWidget {
  const MedicalFileUploadSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AccountInfoViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Upload your medical file',
          style: GoogleFonts.instrumentSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
          ),
        ),
        GestureDetector(
          onTap: () => viewModel.pickMedicalFile(),
          child: Padding(
            padding: EdgeInsets.only(right: 12.0.w),
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                isDark ? Colors.white : Colors.black,
                BlendMode.srcIn,
              ),
              child: Image.asset(
                AssetsManager.upload_file,
                width: 35.w,
                height: 35.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<AccountInfoViewModel>(context, listen: false);
    return GestureDetector(
      onTap: () => viewModel.submitForm(context),
      child: Center(
        child: Container(
          width: 330.w,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
                colors: [Color(0xFF786AC8), Color(0xFF5B5F9C)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
              child: Text('Submit',
                  style: GoogleFonts.instrumentSans(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white))),
        ),
      ),
    );
  }
}

Widget _buildImage(AccountInfoViewModel viewModel) {
  if (viewModel.profileImagePath != null) {
    return Image.file(File(viewModel.profileImagePath!), fit: BoxFit.cover);
  } else if (viewModel.networkImageUrl != null &&
      viewModel.networkImageUrl!.isNotEmpty) {
    return Image.network(viewModel.networkImageUrl!, fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
      if (loadingProgress == null) return child;
      return const Center(child: CircularProgressIndicator());
    }, errorBuilder: (context, error, stackTrace) {
      return Image.asset('assets/images/defult_doc.png', fit: BoxFit.cover);
    });
  } else {
    return Image.asset('assets/images/defult_doc.png', fit: BoxFit.cover);
  }
}
