import 'package:flexera/view_model/forgot_password_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/themes/app_colors.dart';
import '../widget/forgot_password_widget.dart';
import '../widget/enter_code_widget.dart';
import '../widget/create_password_widget.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final vm = ForgotPasswordViewModel();
        vm.setRole(isDoctor: false);
        return vm;
      },
      child: Consumer<ForgotPasswordViewModel>(
        builder: (context, vm, _) {
          return Scaffold(
            backgroundColor: AppColors.backgroundcolor1,
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 16.h,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        children: List.generate(3, (index) {
                          final isActive = index == vm.currentPage;
                          return Expanded(
                            flex: 1,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 350),
                              margin: EdgeInsets.symmetric(horizontal: 8.w),
                              height: 9.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                gradient: isActive
                                    ? const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          AppColors.darkpurplecolor,
                                          AppColors.lightpurplecolor,
                                        ],
                                      )
                                    : LinearGradient(
                                        colors: [
                                          AppColors.graycolor.withOpacity(0.18),
                                          AppColors.graycolor.withOpacity(0.18),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: 80.h),
                    Expanded(
                      child: PageView(
                        controller: vm.pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (index) {
                          vm.currentPage = index;
                          vm.notifyListeners();
                        },
                        children: const [
                          ForgotPasswordWidget(),
                          EnterCodeWidget(),
                          CreatePasswordWidget(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
