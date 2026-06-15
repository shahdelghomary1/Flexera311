import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/themes/app_colors.dart';
import '../../model/chat_session.dart';
import '../../view_model/chat_view_model.dart';

class ChatHistoryScreen extends StatelessWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF131313) : AppColors.backgroundcolor1,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: isDark ? Colors.white24 : Colors.black12,
                width: 1.w,
              ),
            ),
            child: Center(
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  isDark ? Colors.white : Colors.grey,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  'assets/icons/arrow.png',
                  width: 20.w,
                  height: 20.h,
                ),
              ),
            ),
          ),
        ),
        title: Text(
          'Chat History',
          style: GoogleFonts.instrumentSans(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.whiteColor : Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<ChatViewModel>(
            builder: (context, vm, _) {
              if (vm.sessions.isEmpty) return const SizedBox();
              return TextButton(
                onPressed: () => _confirmClearAll(context, vm),
                child: Text(
                  'Clear All',
                  style: GoogleFonts.quicksand(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ChatViewModel>(
        builder: (context, vm, _) {
          if (vm.sessions.isEmpty) {
            return _buildEmptyState(isDark);
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: vm.sessions.length,
            itemBuilder: (context, index) {
              final session = vm.sessions[index];
              return _SessionCard(
                session: session,
                isDark: isDark,
                onTap: () {
                  Navigator.pop(context, session);
                },
                onDismissed: () {
                  vm.deleteSession(session.id);
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 72.r,
            color: isDark ? Colors.white24 : Colors.grey[300],
          ),
          SizedBox(height: 20.h),
          Text(
            'No chat history yet',
            style: GoogleFonts.instrumentSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white54 : Colors.grey[500],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Start a conversation to see it here',
            style: GoogleFonts.quicksand(
              fontSize: 14.sp,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearAll(
      BuildContext context, ChatViewModel vm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text(
            'This will permanently delete all chat sessions. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear All',
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      for (final s in List.of(vm.sessions)) {
        await vm.deleteSession(s.id);
      }
    }
  }
}

class _SessionCard extends StatelessWidget {
  final ChatSession session;
  final bool isDark;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  const _SessionCard({
    required this.session,
    required this.isDark,
    required this.onTap,
    required this.onDismissed,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(session.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(Icons.delete_outline, color: Colors.white, size: 26.sp),
      ),
      onDismissed: (_) => onDismissed(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.primaryDark.withOpacity(0.2)
                      : AppColors.gradientEnd,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: isDark ? AppColors.primaryDark : AppColors.primary,
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _formatDate(session.createdAt),
                      style: GoogleFonts.quicksand(
                        fontSize: 12.sp,
                        color: isDark ? Colors.white38 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: isDark ? Colors.white24 : Colors.grey[300],
                size: 20.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);

    if (day == today) {
      return 'Today · ${DateFormat('h:mm a').format(dt)}';
    } else if (day == today.subtract(const Duration(days: 1))) {
      return 'Yesterday · ${DateFormat('h:mm a').format(dt)}';
    } else {
      return DateFormat('MMM d · h:mm a').format(dt);
    }
  }
}
