import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../model/auth_models/my_exercises_model.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseItem item;
  final bool isDark;
  final VoidCallback onTap;
  final Function(bool?) onCheckboxChanged;

  const ExerciseCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.onTap,
    required this.onCheckboxChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = isDark ? const Color(0xFF2C2C2E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF363438);
    final subTextColor = isDark ? Colors.grey[400] : const Color(0xFF8A8A8E);

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
            child: Row(
              children: [
                Container(
                  width: 4.w,
                  height: 45.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B80F8),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? "Exercise Name",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      if (item.category != null || item.notes != null)
                        Text(
                          item.category ?? item.notes ?? "",
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: subTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          if (item.reps != null && item.reps! > 0)
                            Text(
                              "Reps: ${item.reps}",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                          if (item.sets != null && item.sets! > 0) ...[
                            SizedBox(width: 10.w),
                            Text(
                              "Sets: ${item.sets}",
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: textColor.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => onCheckboxChanged(!item.isCompleted),
                  child: Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: BoxDecoration(
                      color: item.isCompleted
                          ? const Color(0xFF8B80F8)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: item.isCompleted
                            ? const Color(0xFF8B80F8)
                            : const Color(0xFFC5C5C7),
                        width: 1.5,
                      ),
                    ),
                    child: item.isCompleted
                        ? Icon(Icons.check, size: 18.w, color: Colors.white)
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
