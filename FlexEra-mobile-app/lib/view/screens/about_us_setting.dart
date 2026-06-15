import 'package:flexera/view/widget/about_us_setting_widget.dart';
import 'package:flexera/view_model/about_us_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';

class AboutUsSetting extends StatefulWidget {
  const AboutUsSetting({super.key});

  @override
  State<AboutUsSetting> createState() => _AboutUsSettingState();
}

class _AboutUsSettingState extends State<AboutUsSetting> {
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

                // Positioned(
                //   bottom: -300,
                //   left: -220,
                //   child: Transform.rotate(
                //     angle: 350 * 3.14159 / 180,
                //     // child: Opacity(
                //     //   opacity: 0.9,
                //     child: Image.asset(
                //       AssetsManager.aboutDown,
                //       width: 800.39,
                //       height: 1209.65,
                //       fit: BoxFit.contain,
                //     ),
                //     // ),
                //   ),
                // ),
                Positioned(
                  bottom: 50.h,
                  left: -10.w,
                  child: Transform.rotate(
                    angle: 0,
                    // child: Opacity(
                    //   opacity: 0.9,
                    child: Image.asset(
                      'assets/images/Vector2.png',
                      width: 500.w,
                      // height: 1009.65,
                      fit: BoxFit.contain,
                    ),
                    // ),
                  ),
                ),

                Positioned(
                  top: 80.h,
                  left: 0.w,
                  right: 0.w,
                  bottom: 0.h,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MainTitleText(),
                          DescriptionText(
                            iconWidget: Image.asset(
                              'assets/icons/blueuser.png',
                              width: 25.w,
                              height: 25.h,
                            ),
                            title: "Who We Are?",
                            titleAlign: TextAlign.start,
                            description:
                                "Flexera is an AI-powered physical therapy app that helps you perform rehab exercises safely and correctly from home.",
                            showBottomBorder: true,
                          ),
                          DescriptionText(
                            iconWidget: Image.asset(
                              'assets/icons/redarrow.png',
                              width: 24.w,
                              height: 24.h,
                            ),
                            title: "Our Mission",
                            titleAlign: TextAlign.center,
                            description:
                                "To make physical therapy easier, more accurate, and accessible for everyone through smart, real-time guidance.",
                            showBottomBorder: true,
                          ),
                          DescriptionText(
                            iconWidget: Image.asset(
                              'assets/icons/blueusers.png',
                              width: 24.w,
                              height: 24.h,
                            ),
                            title: "Meet the Team",
                            titleAlign: TextAlign.start,
                            description:
                                "• Physiotherapists who review and design the exercises\n"
                                "• AI engineers who build the motion-tracking system\n"
                                "• Designers who create a smooth and friendly experience",
                            showBottomBorder: false,
                          ),
                          LogoSection(
                            subtitle:
                                "guided physical therapy made simple and safe",
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 50.h,
                  right: 0.w,
                  child: Transform.rotate(
                    angle: 0,

                    child: Image.asset(
                      'assets/images/star.gif',
                      width: 100.w,
                      height: 70.h,
                      fit: BoxFit.contain,
                    ),
                    // ),
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
