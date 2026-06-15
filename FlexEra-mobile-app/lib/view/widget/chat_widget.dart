import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';
import '../../model/chat_message.dart';
import '../../view_model/chat_view_model.dart';

class ChatHeader extends StatelessWidget {
  final VoidCallback onBackPressed;
  final VoidCallback onNewChat;
  final VoidCallback onHistory;
  final bool isOnline;

  const ChatHeader({
    super.key,
    required this.onBackPressed,
    required this.onNewChat,
    required this.onHistory,
    required this.isOnline,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 4.h),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: SafeArea(
        child: Row(
          children: [
            GestureDetector(
              onTap: onBackPressed,
              child: Container(
                width: 50.w,
                height: 50.h,
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
                      width: 25.w,
                      height: 25.h,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Chat with AI',
                    style: GoogleFonts.instrumentSans(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.whiteColor : Colors.black,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 136.w),
                      Center(
                        child: Text(
                          isOnline ? 'Online' : 'Offline',
                          style: GoogleFonts.quicksand(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.whiteColor.withOpacity(0.7)
                                : Colors.grey[600],
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: BoxDecoration(
                              color: isOnline ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PopupMenuButton<_ChatMenuAction>(
              icon: Icon(
                Icons.more_vert,
                color: isDark ? AppColors.whiteColor : Colors.black87,
                size: 24.sp,
              ),
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              onSelected: (action) {
                if (action == _ChatMenuAction.newChat) {
                  onNewChat();
                } else {
                  onHistory();
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: _ChatMenuAction.newChat,
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined,
                          size: 20.sp,
                          color: isDark ? Colors.white70 : Colors.black87),
                      SizedBox(width: 10.w),
                      Text(
                        'New Chat',
                        style: GoogleFonts.quicksand(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: _ChatMenuAction.history,
                  child: Row(
                    children: [
                      Icon(Icons.history,
                          size: 20.sp,
                          color: isDark ? Colors.white70 : Colors.black87),
                      SizedBox(width: 10.w),
                      Text(
                        'History',
                        style: GoogleFonts.quicksand(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum _ChatMenuAction { newChat, history }

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isUser = message.sender == MessageSender.user;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 5.h),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
              children: [
                Container(
                  constraints: BoxConstraints(maxWidth: 295.w),
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: isUser
                        ? isDark
                            ? AppColors.cardDark
                            : Colors.grey[100]
                        : const Color.fromRGBO(173, 135, 228, 1),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(30),
                      topRight: const Radius.circular(30),
                      bottomLeft: Radius.circular(isUser ? 0 : 30),
                      bottomRight: Radius.circular(isUser ? 30 : 0),
                    ),
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.quicksand(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: isUser
                          ? isDark
                              ? AppColors.whiteColor
                              : Colors.black87
                          : Colors.white,
                      height: 1.4.h,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Text(
                    _formatTime(message.timestamp),
                    style: GoogleFonts.sora(
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.whiteColor : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(
      timestamp.year,
      timestamp.month,
      timestamp.day,
    );

    if (messageDate == today) {
      return DateFormat('h:mm a').format(timestamp);
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }
}

class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDark : Colors.grey[100],
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: List.generate(
                3,
                (index) => AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final delay = index * 0.2;
                    final value = (_controller.value - delay) % 1.0;
                    final opacity = value < 0.5 ? value * 2 : (1 - value) * 2;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Opacity(
                        opacity: opacity.clamp(0.3, 1.0),
                        child: Container(
                          width: 8.w,
                          height: 8.h,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.whiteColor : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MessageInputField extends StatelessWidget {
  final ChatViewModel viewModel;
  final VoidCallback onSend;

  const MessageInputField({
    super.key,
    required this.viewModel,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
      decoration: const BoxDecoration(color: Colors.transparent),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Container(
              width: 370.w,
              height: 56.h,
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.whiteColor : Colors.grey,
                  width: 1.w,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: viewModel.messageController,
                      style: GoogleFonts.quicksand(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.whiteColor : Colors.black,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type your message...',
                        hintStyle: GoogleFonts.quicksand(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color:
                              isDark ? AppColors.whiteColor : Colors.grey[500],
                        ),
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => onSend(),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: onSend,
                    child: Image.asset(
                      AssetsManager.sendIcon,
                      width: 24.w,
                      height: 24.h,
                      color: isDark ? AppColors.whiteColor : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
