import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';
import '../../view_model/doc_account_info_view_model.dart';
import 'doc_navbar.dart';

class DocAccountInfoScaffold extends StatelessWidget {
  const DocAccountInfoScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => DocAccountInfoViewModel(),
      child: Scaffold(
        extendBody: true,
        backgroundColor: isDark ? const Color(0xFF131313) : Colors.white,
        body: const DocAccountInfoBody(),
        bottomNavigationBar: Consumer<DocAccountInfoViewModel>(
          builder: (context, viewModel, _) {
            return DocNavBar(
              currentIndex: viewModel.selectedNavIndex,
              onTap: (index) => viewModel.onNavBarTap(index, context),
            );
          },
        ),
      ),
    );
  }
}

class DocAccountInfoBody extends StatelessWidget {
  const DocAccountInfoBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            color: isDark ? const Color(0xFF131313) : Colors.white,
          ),
        ),
        Theme.of(context).brightness == Brightness.dark
            ? Positioned(
                top: -130.h,
                left: -150.w,
                child: Image.asset(
                  AssetsManager.backAccountUpDark,
                  width: 500.w,
                  fit: BoxFit.cover,
                ),
              )
            : Positioned(
                top: -30.h,
                left: 0,
                right: 50.w,
                child: Image.asset(
                  AssetsManager.backAccountUp,
                  width: 450.w,
                  fit: BoxFit.cover,
                ),
              ),
        Theme.of(context).brightness == Brightness.dark
            ? Positioned(
                top: 510.h,
                left: 90.w,
                child: Image.asset(
                  AssetsManager.backAccountUpDark,
                  width: 500.w,
                  fit: BoxFit.cover,
                ),
              )
            : Positioned(
                top: 480.h,
                left: 120.w,
                child: Image.asset(
                  AssetsManager.backAccountDown,
                  width: 300.w,
                  fit: BoxFit.cover,
                ),
              ),
        SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                children: [
                  Positioned(
                    top: -360.h,
                    left: -10.w,
                    child: Transform.rotate(
                      angle: 240 * math.pi / 180,
                      child: Image.asset(
                        AssetsManager.backgroundBlob,
                        width: 554.w,
                        height: 750.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 27.w),
                        child: const DocAccountInfoAppBar(),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 40.h),
                            const DocProfileAvatarSection(),
                            SizedBox(height: 10.h),
                            const DocBasicDetailsSection(),
                            SizedBox(height: 12.h),
                            const DocGenderSection(),
                            SizedBox(height: 16.h),
                            const DocIdSection(),
                            SizedBox(height: 30.h),
                            const DocSubmitButton(),
                            SizedBox(height: 130.h),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DocAccountInfoAppBar extends StatelessWidget {
  const DocAccountInfoAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(top: 50.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Account Information',
                style: GoogleFonts.instrumentSans(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DocProfileAvatarSection extends StatelessWidget {
  const DocProfileAvatarSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DocAccountInfoViewModel>(context);

    return Center(
      child: Stack(
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.purplecolor, width: 0.1.w),
            ),
            child: ClipOval(
              child: viewModel.profileImagePath != null
                  ? Image.file(
                      File(viewModel.profileImagePath!),
                      fit: BoxFit.cover,
                    )
                  : viewModel.currentImageUrl != null &&
                          viewModel.currentImageUrl!.isNotEmpty
                      ? Image.network(
                          viewModel.currentImageUrl!,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.lightpurplecolor,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.purplecolor,
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.lightpurplecolor,
                              child: Icon(
                                Icons.person,
                                size: 60.w,
                                color: AppColors.purplecolor,
                              ),
                            );
                          },
                        )
                      : Image.asset(
                          AssetsManager.doctor,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.lightpurplecolor,
                              child: Icon(
                                Icons.person,
                                size: 60.w,
                                color: AppColors.purplecolor,
                              ),
                            );
                          },
                        ),
            ),
          ),
          Positioned(
            bottom: 5.h,
            right: 5.w,
            child: GestureDetector(
              onTap: () => viewModel.pickProfileImage(),
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.purplecolor, width: 2.w),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 16.w,
                  color: AppColors.purplecolor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DocBasicDetailsSection extends StatelessWidget {
  const DocBasicDetailsSection({super.key});

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
        const DocCustomTextField(
          hintText: 'Full Name',
          fieldType: DocTextFieldType.fullName,
        ),
        SizedBox(height: 12.h),
        const DocCustomTextField(
          hintText: 'Email Address',
          fieldType: DocTextFieldType.email,
        ),
        SizedBox(height: 12.h),
        const DocCustomTextField(
          hintText: 'Phone Number',
          fieldType: DocTextFieldType.phone,
        ),
        SizedBox(height: 12.h),
        const DocCustomTextField(
          hintText: 'Date of Birth',
          isDatePicker: true,
          fieldType: DocTextFieldType.dateOfBirth,
        ),
      ],
    );
  }
}

enum DocTextFieldType {
  fullName,
  email,
  phone,
  password,
  dateOfBirth,
  doctorId,
}

class DocCustomTextField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final bool isDatePicker;
  final DocTextFieldType fieldType;

  const DocCustomTextField({
    super.key,
    required this.hintText,
    this.isPassword = false,
    this.isDatePicker = false,
    required this.fieldType,
  });

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DocAccountInfoViewModel>(
      context,
      listen: false,
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    bool isStaticField = fieldType == DocTextFieldType.email ||
        fieldType == DocTextFieldType.doctorId;

    bool isReadOnly = isStaticField || isDatePicker;

    TextEditingController controller;
    TextInputType keyboardType;

    switch (fieldType) {
      case DocTextFieldType.fullName:
        controller = viewModel.fullNameController;
        keyboardType = TextInputType.text;
        break;
      case DocTextFieldType.email:
        controller = viewModel.emailController;
        keyboardType = TextInputType.emailAddress;
        break;
      case DocTextFieldType.phone:
        controller = viewModel.phoneController;
        keyboardType = TextInputType.phone;
        break;
      case DocTextFieldType.password:
        controller = viewModel.passwordController;
        keyboardType = TextInputType.text;
        break;
      case DocTextFieldType.dateOfBirth:
        controller = viewModel.dateOfBirthController;
        keyboardType = TextInputType.text;
        break;
      case DocTextFieldType.doctorId:
        controller = viewModel.doctorIdController;
        keyboardType = TextInputType.text;
        break;
    }

    Widget? suffixIcon;
    if (isDatePicker) {
      suffixIcon = Padding(
        padding: EdgeInsets.all(12.0.r),
        child: Icon(
          Icons.calendar_today_outlined,
          size: 20.w,
          color: isDark ? Colors.white : Colors.black,
        ),
      );
    } else if (fieldType == DocTextFieldType.email) {
      suffixIcon = null;
    } else {
      suffixIcon = Padding(
        padding: EdgeInsets.all(12.0.r),
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(
            isDark ? Colors.white : Colors.black,
            BlendMode.srcIn,
          ),
          child:
              Image.asset(AssetsManager.field_icon, width: 20.w, height: 20.w),
        ),
      );
    }

    return SizedBox(
      width: 330.w,
      height: 50.h,
      child: Container(
        decoration: BoxDecoration(
          color: isStaticField
              ? (isDark ? Colors.grey[800] : Colors.grey[200])
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isDark ? Colors.white24 : Colors.black45,
            width: 1.w,
          ),
        ),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          readOnly: isReadOnly,
          onTap:
              isDatePicker ? () => viewModel.selectDateOfBirth(context) : null,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.instrumentSans(
              fontSize: 15.sp,
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.w500,
              height: 2,
              letterSpacing: 0,
            ),
            suffixIcon: suffixIcon,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 20.w,
              vertical: 10.h,
            ),
          ),
          style: GoogleFonts.instrumentSans(
            fontSize: 15.sp,
            color: isStaticField
                ? Colors.grey
                : (isDark ? AppColors.whiteColor : AppColors.blackcolor),
            fontWeight: FontWeight.w500,
            height: 1.0,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class DocGenderSection extends StatelessWidget {
  const DocGenderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DocAccountInfoViewModel>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.w),
          child: Text(
            'Gender',
            style: GoogleFonts.instrumentSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DocGenderRadioButton(
              label: 'Female',
              isSelected: viewModel.selectedGender == 'Female',
              onTap: () => viewModel.setGender('Female'),
            ),
            SizedBox(width: 30.w),
            DocGenderRadioButton(
              label: 'Male',
              isSelected: viewModel.selectedGender == 'Male',
              onTap: () => viewModel.setGender('Male'),
            ),
          ],
        ),
      ],
    );
  }
}

class DocGenderRadioButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const DocGenderRadioButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: isSelected
                ? AppColors.purplecolor
                : isDark
                    ? Colors.white24
                    : Colors.black54,
            width: 1.w,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.quicksand(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
                ),
              ),
              Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? AppColors.purplecolor
                        : Colors.grey.shade400,
                    width: 2.w,
                  ),
                ),
                child: isSelected
                    ? Center(
                        child: Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: AppColors.purplecolor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DocIdSection extends StatelessWidget {
  const DocIdSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final viewModel = Provider.of<DocAccountInfoViewModel>(
      context,
      listen: false,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10.w),
          child: Text(
            'Your ID',
            style: GoogleFonts.instrumentSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.whiteColor : AppColors.blackcolor,
            ),
          ),
        ),
        SizedBox(height: 10.h),
        Center(
          child: SizedBox(
            width: 330.w,
            height: 50.h,
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[200],
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isDark ? Colors.white24 : Colors.black45,
                  width: 1.w,
                ),
              ),
              child: TextField(
                controller: viewModel.doctorIdController,
                keyboardType: TextInputType.text,
                readOnly: true,
                decoration: InputDecoration(
                  hintText: '',
                  hintStyle: GoogleFonts.instrumentSans(
                    fontSize: 15.sp,
                    color: isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                ),
                style: GoogleFonts.instrumentSans(
                  fontSize: 15.sp,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class DocSubmitButton extends StatelessWidget {
  const DocSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<DocAccountInfoViewModel>(
      context,
      listen: false,
    );

    return Center(
      child: GestureDetector(
        onTap: () => viewModel.submitForm(context),
        child: Container(
          width: 330.w,
          height: 54.h,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerRight,
              end: Alignment.centerLeft,
              colors: [Color(0xFF786AC8), Color(0xFF5B5F9C)],
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Center(
            child: Text(
              'Submit',
              style: GoogleFonts.instrumentSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
