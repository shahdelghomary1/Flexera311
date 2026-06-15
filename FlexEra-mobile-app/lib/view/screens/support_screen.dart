import 'package:flexera/core/assets/assets_manager.dart';
import 'package:flexera/core/themes/app_colors.dart';
import 'package:flexera/core/themes/app_theme.dart';
import 'package:flexera/view/screens/about_us_screen.dart';
import 'package:flexera/view/widget/faq_tile.dart';
import 'package:flexera/view_model/support_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  Future<void> _openWebsite() async {
    final Uri url = Uri.parse('https://flexera-gamma.vercel.app');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch website')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SupportViewModel>(context);
    // ignore: unused_local_variable
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppTheme.supportBackground(
      context,
      Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  height: 433.h,
                  padding: const EdgeInsets.fromLTRB(16, 60, 16, 30),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.black : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(23),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 4.h),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 54.w,
                              height: 54.h,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.grey[800] : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    offset: Offset(2.w, 3.h),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 24.r,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                "Support & Help",
                                style: GoogleFonts.quicksand(
                                  fontSize: 45.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.only(left: 30.w),
                        child: Text(
                          "We’re here to guide you every step of the way",
                          style: GoogleFonts.quicksand(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.whiteColor
                                : AppColors.blackcolor,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildSimpleLink(
                            context,
                            iconPath: isDark
                                ? AssetsManager.websiteDark
                                : AssetsManager.websiteLight,
                            text: "Go to our Website",
                            isDark: isDark,
                            onTap: _openWebsite,
                          ),
                          SizedBox(height: 6.h),
                          Container(
                            width: double.infinity,
                            height: 2.h,
                            color:
                                isDark ? Colors.white : const Color(0xFF777272),
                            margin: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                          _buildSimpleLink(
                            context,
                            iconPath: isDark
                                ? AssetsManager.contactSupportDark
                                : AssetsManager.contactSupportLight,
                            text: "Contact Us",
                            isDark: isDark,
                            onTap: () => Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration:
                                    const Duration(milliseconds: 300),
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        const AboutUsScreen(),
                                transitionsBuilder: (context, animation,
                                    secondaryAnimation, child) {
                                  final offsetAnimation = Tween(
                                    begin: const Offset(0, 1),
                                    end: Offset.zero,
                                  ).animate(animation);
                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -140.h,
                  left: 15.w,
                  right: -100.w,
                  child: IgnorePointer(
                    child: Image.asset(
                      isDark
                          ? AssetsManager.backsupportdark
                          : AssetsManager.backsupportdark,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: viewModel.faqs.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.w),
                  itemBuilder: (context, index) =>
                      FAQTile(faq: viewModel.faqs[index]),
                ),
              ),
            ),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleLink(
    BuildContext context, {
    required String iconPath,
    required String text,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Image.asset(iconPath, width: 24.w, height: 24.h),
            SizedBox(width: 8.w),
            Text(
              text,
              style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w600,
                fontSize: 20.sp,
                color: isDark ? Colors.white : AppColors.mainColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
