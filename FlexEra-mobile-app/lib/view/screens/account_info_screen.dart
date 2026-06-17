import 'package:flexera/view/widget/account_info_widgets.dart';
import 'package:flexera/view_model/account_info_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';

class AccountInfoScreen extends StatefulWidget {
  const AccountInfoScreen({super.key});

  @override
  State<AccountInfoScreen> createState() => _AccountInfoScreenState();
}

class _AccountInfoScreenState extends State<AccountInfoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AccountInfoViewModel>(context, listen: false).getMyData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: Consumer<AccountInfoViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isPageLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF786AC8)),
            );
          }
          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  color: isDark ? const Color(0xFF131313) : Colors.white,
                ),
              ),

              Positioned(
                bottom: 0,
                right: 0,
                child: Image.asset(
                  AssetsManager.backAccountDown,
                  width: 250.w,
                  fit: BoxFit.contain,
                ),
              ),

              SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Positioned(
                          top: -25.h,
                          left: 0.w,
                          child: Image.asset(
                            AssetsManager.backgroundBlobstting,
                            width: 422.w,
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 27.0.w),
                              child: const AccountInfoAppBar(),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 30.h),
                                  const ProfileAvatarSection(),
                                  SizedBox(height: 10.h),
                                  const BasicDetailsSection(),
                                  SizedBox(height: 12.h),
                                  const GenderSection(),
                                  SizedBox(height: 12.h),
                                  const MeasurementsSection(),
                                  SizedBox(height: 24.h),
                                  const MedicalFileUploadSection(),
                                  SizedBox(height: 30.h),
                                  const SubmitButton(),
                                  SizedBox(height: 120.h),
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
        },
      ),
    );
  }
}
