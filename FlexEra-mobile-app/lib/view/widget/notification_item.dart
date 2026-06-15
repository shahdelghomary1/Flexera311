import 'package:flexera/model/auth_models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flexera/core/assets/assets_manager.dart';

class NotificationItem extends StatelessWidget {
  final NotificationModel model;
  final Function(String) onDelete;
  final Function(String) onRead;

  const NotificationItem({
    super.key,
    required this.model,
    required this.onDelete,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isRead = model.isRead ?? false;

    Color backgroundColor;
    if (isDark) {
      backgroundColor = isRead
          ? Colors.black.withOpacity(0.7)
          : const Color(0xFF0D0D0D);
    } else {
      backgroundColor = isRead ? Colors.white.withOpacity(0.7) : Colors.white;
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
      child: Dismissible(
        key: Key(model.id ?? UniqueKey().toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          if (model.id != null) {
            onDelete(model.id!);
          }
        },
        background: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            color: Colors.red.withOpacity(0.1),
          ),
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20.w),
          child: Image.asset(
            AssetsManager.deleteIcon,
            width: 24.w,
            color: Colors.red,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            if (!isRead && model.id != null) {
              onRead(model.id!);
            }
          },
          child: Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16.r),
              border: !isRead
                  ? Border.all(color: Colors.purple.withOpacity(0.1), width: 1)
                  : Border.all(color: Colors.transparent),
              boxShadow: !isRead
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Text(
                          model.createdAt != null
                              ? timeago.format(DateTime.parse(model.createdAt!))
                              : '',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        model.message ?? "No content",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: !isRead
                              ? FontWeight.bold
                              : FontWeight.w400,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead) ...[
                  SizedBox(width: 8.w),
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
