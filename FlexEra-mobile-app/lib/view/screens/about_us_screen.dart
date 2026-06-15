import 'package:flexera/main.dart';
import 'package:flexera/view/widget/about_us_widget.dart';
import 'package:flexera/view_model/about_us_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';

class AboutUsScreen extends StatefulWidget {
  const AboutUsScreen({super.key});

  @override
  State<AboutUsScreen> createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => AboutUsViewModel(),
      child: Scaffold(
        extendBody: true,
        backgroundColor:
            isDark ? const Color(0xFF131313) : AppColors.backgroundcolor1,
        body: Consumer<AboutUsViewModel>(
          builder: (context, viewModel, _) {
            return Stack(
              children: [
                Positioned(
                  child: Container(
                    color: isDark ? const Color(0xFF131313) : Colors.white,
                  ),
                ),

                Positioned(
                  top: -200.h,
                  left: 100.w,
                  right: -320.w,
                  child: Transform.rotate(
                    angle: 140 * 3.14 / 180,
                    child: Opacity(
                      opacity: 0.8,
                      child: Image.asset(
                        AssetsManager.aboutUp,
                        width: 800.99.w,
                        height: 1000.28.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: -300.h,
                  left: -220.w,
                  child: Transform.rotate(
                    angle: 350 * 3.14159 / 180,
                    // child: Opacity(
                    //   opacity: 0.9,
                    child: Image.asset(
                      AssetsManager.aboutDown,
                      width: 800.39.w,
                      height: 1209.65.h,
                      fit: BoxFit.contain,
                    ),
                    // ),
                  ),
                ),

                // Positioned(
                //   top: 50,
                //   left: 27,
                //   right: 27,
                //   child: BackButtonHeader(viewModel: viewModel),
                // ),
                Positioned(
                  top: 120.h,
                  left: 0.w,
                  right: 0.w,
                  bottom: 0.h,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 28.h),
                          const MainTitleText(),
                          SizedBox(height: 30.h),
                          const DescriptionText(),
                          SizedBox(height: 38.h),
                          const ContactInfoSection(),
                          SizedBox(height: 20.h),
                          LiveChatButton(viewModel: viewModel),
                          SizedBox(height: 15.h),
                          const SocialMediaSection(),
                          SizedBox(height: 120.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
