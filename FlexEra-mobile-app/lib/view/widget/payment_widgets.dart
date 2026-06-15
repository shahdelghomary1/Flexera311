import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentTextField extends StatefulWidget {
  final String hintText;
  final Widget? prefixIcon;
  final double height;
  final double width;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;

  const PaymentTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.height = 60,
    this.width = double.infinity,
    this.controller,
    this.keyboardType,
    this.validator,
    this.inputFormatters,
    this.maxLength,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  @override
  State<PaymentTextField> createState() => _PaymentTextFieldState();
}

class _PaymentTextFieldState extends State<PaymentTextField> {
  late FocusNode _focusNode;
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(() {
      setState(() => isFocused = _focusNode.hasFocus);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: widget.height.h,
      width: widget.width == double.infinity ? double.infinity : widget.width.w,
      padding: EdgeInsets.symmetric(horizontal: 3.w),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F0F0F) : Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        border: Border.all(
          color: isFocused
              ? const Color(0xFF786AC8)
              : (isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade300),
          width: isFocused ? 2.2.w : 1.2.w,
        ),
      ),
      child: TextFormField(
        focusNode: _focusNode,
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        inputFormatters: widget.inputFormatters,
        maxLength: widget.maxLength,
        textInputAction: widget.textInputAction,
        onFieldSubmitted: widget.onFieldSubmitted,
        style: GoogleFonts.quicksand(
          color: isDark ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 16.sp,
        ),
        decoration: InputDecoration(
          counterText: "",
          hintText: widget.hintText,
          hintStyle: GoogleFonts.instrumentSans(
            color: isDark ? Colors.white54 : Colors.grey,
            fontSize: 16.sp,
          ),
          prefixIcon: widget.prefixIcon,
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(horizontal: 19.w, vertical: 14.h),
        ),
      ),
    );
  }
}
