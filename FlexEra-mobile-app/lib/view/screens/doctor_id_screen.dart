import 'package:flexera/view/widget/doctor_id_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';
import '../../view_model/doctor_id_view_model.dart';

class DoctorIdScreen extends StatelessWidget {
  const DoctorIdScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final topImageSize = MediaQuery.of(context).size.width * 0.55;

    final lightTheme = ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundcolor1,
      primaryColor: Colors.white,
      useMaterial3: true,
      textTheme:
          GoogleFonts.instrumentSansTextTheme(ThemeData.light().textTheme),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF786AC8),
        brightness: Brightness.light,
      ),
    );

    return Theme(
      data: lightTheme,
      child: ChangeNotifierProvider(
        create: (_) => DoctorIdViewModel(),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.backgroundcolor1,
          body: SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Positioned(
                  top: -300.h,
                  right: -290.w,
                  child: Transform.rotate(
                    angle: 5 * 3.14 / 180,
                    child: Image.asset(
                      AssetsManager.backgroundBlob,
                      width: 650.w,
                      height: 700.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  top: -80.h,
                  right: -9.5.w,
                  child: Image.asset(
                    AssetsManager.topCorner3,
                    width: topImageSize,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  bottom: -390.h,
                  left: -195.w,
                  child: Transform.rotate(
                    angle: 328 * 3.14 / 180,
                    child: Image.asset(
                      AssetsManager.backgroundBlob,
                      width: 554.w,
                      height: 750.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SafeArea(
                  child: DoctorIdWidget(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
