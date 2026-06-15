import 'package:flexera/core/assets/assets_manager.dart';
import 'package:flexera/view_model/notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class HomeNotificationIcon extends StatefulWidget {
  const HomeNotificationIcon({super.key});

  @override
  State<HomeNotificationIcon> createState() => _HomeNotificationIconState();
}

class _HomeNotificationIconState extends State<HomeNotificationIcon> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<NotificationViewModel>(context, listen: false)
            .fetchNotifications());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<NotificationViewModel>(
      builder: (context, vm, child) {
        bool hasUnread = vm.allNotifications.any((n) => n.isRead == false);

        return SizedBox(
          height: 28.h,
          width: 28.w,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/notifications');
                },
                child: Image.asset(
                  isDark
                      ? AssetsManager.notificationlight
                      : "assets/icons/notificationhome.png",
                  fit: BoxFit.contain,
                ),
              ),
              if (hasUnread)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
