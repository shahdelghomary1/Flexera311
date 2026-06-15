import 'package:flexera/core/themes/app_colors.dart';
import 'package:flexera/view/widget/home_notification_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flexera/core/assets/assets_manager.dart';
import '../../core/network/cache_helper.dart';

class HealthHeader extends StatelessWidget {
  final String userName;
  final String? imageUrl;
  final bool isDark;

  const HealthHeader({
    super.key,
    this.userName = '',
    this.imageUrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final String finalName = userName.isNotEmpty
        ? userName
        : (CacheHelper.getData(key: 'userName') ?? 'User');

    final String? cachedImage = CacheHelper.getData(key: 'photo');
    final String? finalImage =
        (imageUrl != null && imageUrl!.isNotEmpty) ? imageUrl : cachedImage;

    ImageProvider imageProvider;
    if (finalImage != null &&
        finalImage.isNotEmpty &&
        finalImage.startsWith('http')) {
      imageProvider = NetworkImage(finalImage);
    } else {
      imageProvider = const AssetImage(AssetsManager.avatar);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage: imageProvider,
              onBackgroundImageError: (_, __) {},
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("My Progress",
                        style: GoogleFonts.inter(
                          color: AppColors.graycolor,
                          fontSize: 15.sp,
                        )),
                    SizedBox(width: 4.w),
                    Image.asset(
                      "assets/icons/chart-column.png",
                      height: 20.w,
                      width: 20.w,
                    ),
                  ],
                ),
                Text(
                  finalName,
                  style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black),
                ),
              ],
            ),
          ],
        ),
        Stack(
          children: [
            const HomeNotificationIcon(),
          ],
        )
      ],
    );
  }
}

class HealthBackButton extends StatelessWidget {
  final bool isDark;

  const HealthBackButton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Container(
        height: 44.w,
        width: 44.w,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: Offset(0, 4.h),
                blurRadius: 8.r),
          ],
          color: isDark ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.0.r),
          child: Image.asset('assets/icons/arrow.png',
              color: isDark ? Colors.white : Colors.black),
        ),
      ),
    );
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  final double percent;
  final double strokeWidth;
  final bool isDark;

  GradientCircularProgressPainter({
    required this.percent,
    required this.strokeWidth,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = isDark ? Colors.white10 : Colors.grey.shade300
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawCircle(center, radius, backgroundPaint);

    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF590B8D),
        Color(0xFF9FBAF9),
      ],
    ).createShader(rect);

    final progressPaint = Paint()
      ..shader = gradient
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -3.14159 / 2,
      2 * 3.14159 * percent,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ProgressSection extends StatelessWidget {
  final double progressPercent;
  final bool isDark;
  final String characterImage;
  final Color textColor;

  const ProgressSection({
    super.key,
    required this.progressPercent,
    required this.isDark,
    required this.characterImage,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280.h,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 50.h,
            child: SizedBox(
              width: 217.w,
              height: 207.h,
              child: CustomPaint(
                painter: GradientCircularProgressPainter(
                  percent: progressPercent,
                  strokeWidth: 30.w,
                  isDark: isDark,
                ),
              ),
            ),
          ),
          Positioned(
            right: 0,
            left: 240.w,
            top: 20.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  characterImage,
                  height: 116.h,
                  width: 155.w,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF9FBAF9),
                              Color(0xFF590B8D),
                            ],
                          )),
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      "Progress",
                      style: GoogleFonts.quicksand(
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Text(
                  "${(progressPercent * 100).toInt()}%",
                  style: GoogleFonts.instrumentSans(
                      fontSize: 17.sp,
                      color: const Color(0xFF76757F),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
