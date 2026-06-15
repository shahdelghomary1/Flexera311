import 'package:flexera/core/assets/assets_manager.dart';
import 'package:flexera/view/widget/notification_item.dart';
import 'package:flexera/view_model/notification_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NotificationViewModel>(context, listen: false)
          .fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: isDark ? Colors.black : const Color(0xFFF8F9FA),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            bottom: 150.h,
            left: 0,
            right: 0,
            child: Image.asset(
              AssetsManager.notificationBackground,
              fit: BoxFit.fitWidth,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              AssetsManager.notificationGlow,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, isDark),
                SizedBox(height: 15.h),
                _buildCustomTabBar(isDark),
                SizedBox(height: 15.h),
                _buildMarkAllReadButton(context),
                SizedBox(height: 10.h),
                Expanded(
                  child: Consumer<NotificationViewModel>(
                    builder: (context, vm, _) {
                      if (vm.isLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (vm.allNotifications.isEmpty) {
                        return _buildEmptyState(isDark);
                      }

                      return TabBarView(
                        controller: _tabController,
                        children: [
                          _buildNotificationList(vm.todayList, vm, isDark),
                          _buildNotificationList(vm.weekList, vm, isDark),
                          _buildNotificationList(vm.earlierList, vm, isDark),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20.h,
            right: 20.w,
            child: Consumer<NotificationViewModel>(builder: (context, vm, _) {
              if (vm.allNotifications.isEmpty) return const SizedBox();
              return _buildClearAllButton(context, vm);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: CircleAvatar(
              backgroundColor: isDark
                  ? Colors.grey[800]!.withOpacity(0.5)
                  : Colors.white.withOpacity(0.8),
              radius: 22.r,
              child: Icon(Icons.arrow_back_ios_new,
                  size: 18.sp, color: isDark ? Colors.white : Colors.black),
            ),
          ),
          Text(
            "Notifications",
            style: GoogleFonts.quicksand(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Icon(Icons.notifications_none,
              size: 28.sp, color: Colors.transparent),
        ],
      ),
    );
  }

  Widget _buildCustomTabBar(bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      height: 50.h,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(10.r),
        border:
            Border.all(color: isDark ? Colors.white10 : Colors.grey.shade300),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: isDark ? const Color(0xFF333333) : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorPadding: EdgeInsets.all(6.w),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: isDark ? Colors.white : Colors.black,
        unselectedLabelColor: isDark ? Colors.grey : Colors.grey[600],
        labelStyle:
            GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600),
        tabs: const [
          Tab(text: "Today"),
          Tab(text: "This week"),
          Tab(text: "Earlier"),
        ],
      ),
    );
  }

  Widget _buildMarkAllReadButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20.w),
      child: Align(
        alignment: Alignment.centerRight,
        child: InkWell(
          onTap: () {
            Provider.of<NotificationViewModel>(context, listen: false)
                .markAllAsRead();
          },
          child: Text(
            "Mark all as read",
            style: GoogleFonts.inter(
              color: const Color(0xFF9747FF),
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildClearAllButton(BuildContext context, NotificationViewModel vm) {
    return ElevatedButton(
      onPressed: () {
        vm.clearAllNotifications();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.withOpacity(0.3),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        elevation: 0,
      ),
      child: Text(
        "Clear All",
        style: TextStyle(color: Colors.white, fontSize: 12.sp),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AssetsManager.emptyNotification,
            width: 223.w,
            color: isDark ? Colors.white : const Color(0xFF767171),
          ),
          SizedBox(height: 20.h),
          Text(
            "No notifications right now",
            style: GoogleFonts.instrumentSans(
              fontSize: 25.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF383838),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            "We'll let you know as soon as\nsomething comes up",
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              color: isDark ? const Color(0xFFA9A6AA) : const Color(0xFF383838),
              fontSize: 17.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 100.h),
        ],
      ),
    );
  }

  Widget _buildNotificationList(
      List list, NotificationViewModel vm, bool isDark) {
    if (list.isEmpty) {
      return _buildEmptyState(isDark);
    }
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80.h),
      itemCount: list.length,
      itemBuilder: (context, index) {
        return NotificationItem(
          model: list[index],
          onDelete: (id) => vm.removeNotification(id, context),
          onRead: (id) => vm.markAsRead(id),
        );
      },
    );
  }
}
