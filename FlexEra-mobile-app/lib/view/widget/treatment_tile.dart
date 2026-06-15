import 'package:flexera/core/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class TreatmentTile extends StatefulWidget {
  final String title;
  final String subtitle;
  final String assetPath;
  final VoidCallback? onTap;

  const TreatmentTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.assetPath,
    this.onTap,
  });

  @override
  State<TreatmentTile> createState() => _TreatmentTileState();
}

class _TreatmentTileState extends State<TreatmentTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() => _isPressed = false);
        });
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(23.r),
            border: Border.all(
              width: 2.w,
              color: _isPressed
                  ? AppColors.darkpurplecolor
                  : (isDark
                      ? Colors.white24
                      : AppColors.primary.withOpacity(0.2)),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8.r,
                  offset: Offset(0, 4.h),
                ),
            ],
          ),
          padding: EdgeInsets.all(18.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: OverflowBox(
                    maxWidth: 180.w,
                    maxHeight: 180.h,
                    child: Image.asset(
                      widget.assetPath,
                      height: 110.h,
                      width: 150.w,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                widget.title,
                style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w600,
                  fontSize: 22.sp,
                ),
              ),
              Text(
                widget.subtitle,
                style: GoogleFonts.quicksand(
                  fontSize: 10.sp,
                  color: AppColors.subtitel,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
