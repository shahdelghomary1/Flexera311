import 'package:flexera/view/widget/doctor_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flexera/core/themes/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class DoctorTile extends StatefulWidget {
  final String doctorName;
  final String image;
  final VoidCallback? onTap;
  final bool isCompact;

  const DoctorTile({
    super.key,
    required this.doctorName,
    required this.image,
    this.onTap,
    this.isCompact = false,
  });

  @override
  State<DoctorTile> createState() => _DoctorTileState();
}

class _DoctorTileState extends State<DoctorTile>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _bounce = Tween<double>(begin: 0.0, end: 1.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? Colors.black : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;

    final double imgHeight = (widget.isCompact ? 130 : 180).h;
    final double imgTop = (widget.isCompact ? -35 : -40).h;
    final double fontSize = (widget.isCompact ? 10 : 13).sp;

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
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular((widget.isCompact ? 16 : 23).r),
            border: Border.all(
              width: 2.w,
              color: _isPressed
                  ? AppColors.darkpurplecolor
                  : (isDark
                      ? Colors.white12
                      : AppColors.primary.withOpacity(0.1)),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8.r,
                  offset: Offset(0, 4.h),
                ),
            ],
          ),
          padding: EdgeInsets.fromLTRB((widget.isCompact ? 8 : 16).w, 8.h,
              (widget.isCompact ? 8 : 16).w, (widget.isCompact ? 10 : 16).h),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: imgTop,
                left: -15.w,
                right: -2.w,
                child: ScaleTransition(
                  scale: _bounce,
                  child: Center(
                    child: Container(
                      height: imgHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: DoctorImageWidget(
                        imageUrl: widget.image,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.doctorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontWeight: FontWeight.w700,
                        fontSize: fontSize,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
