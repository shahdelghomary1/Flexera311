import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/assets/assets_manager.dart';
import '../../core/themes/app_colors.dart';
import '../../view_model/chat_view_model.dart';
import '../widget/chat_widget.dart';
import 'chat_history_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) {
            return;
          }
        },
        child: Scaffold(
          backgroundColor:
              isDark ? const Color(0xFF131313) : AppColors.backgroundcolor1,
          body: Consumer<ChatViewModel>(
            builder: (context, viewModel, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });

              return Stack(
                children: [
                  Positioned(
                    top: -200.h,
                    left: 100.w,
                    right: -320.w,
                    child: Transform.rotate(
                      angle: 140 * 3.14 / 180,
                      child: Opacity(
                        opacity: 0.8,
                        child: Image.asset(
                          AssetsManager.aboutUp,
                          width: 800.99.w,
                          height: 1000.28.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -300.h,
                    left: -220.w,
                    child: Transform.rotate(
                      angle: 350 * 3.14159 / 180,
                      // child: Opacity(
                      //   opacity: 0.9,
                      child: Image.asset(
                        AssetsManager.aboutDown,
                        width: 800.39.w,
                        height: 1209.65.h,
                        fit: BoxFit.contain,
                      ),
                      // ),
                    ),
                  ),
                  Positioned.fill(
                    child: Column(
                      children: [
                        ChatHeader(
                          onBackPressed: () {
                            try {
                              if (Navigator.canPop(context)) {
                                Navigator.pop(context);
                              } else {
                                debugPrint('Cannot pop - already at root');
                              }
                            } catch (e) {
                              debugPrint('Navigation error: $e');
                            }
                          },
                          onNewChat: () {
                            viewModel.startNewChat();
                          },
                          onHistory: () async {
                            final session = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChangeNotifierProvider.value(
                                  value: viewModel,
                                  child: const ChatHistoryScreen(),
                                ),
                              ),
                            );
                            if (session != null) {
                              await viewModel.loadSession(session);
                            }
                          },
                          isOnline: viewModel.isOnline,
                        ),
                        Expanded(
                          child: viewModel.messages.isEmpty
                              ? _buildEmptyState(isDark)
                              : ShaderMask(
                                  shaderCallback: (Rect bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white,
                                        Colors.white,
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.05, 0.96, 1],
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.dstIn,
                                  child: ListView.builder(
                                    controller: _scrollController,
                                    padding: EdgeInsets.only(
                                      top: 16.h,
                                      bottom: 4.h,
                                    ),
                                    itemCount: viewModel.messages.length +
                                        (viewModel.isTyping ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == viewModel.messages.length) {
                                        return const TypingIndicator();
                                      }

                                      final message = viewModel.messages[index];
                                      return MessageBubble(message: message);
                                    },
                                  ),
                                ),
                        ),
                        Transform.translate(
                          offset: Offset(0, -3.h),
                          child: MessageInputField(
                            viewModel: viewModel,
                            onSend: () {
                              final text = viewModel.messageController.text;
                              if (text.isNotEmpty) {
                                viewModel.sendMessage(text);
                                _scrollToBottom();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF593B5), Color(0xFF83A9F3)],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              color: Colors.white,
              size: 40.r,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Start a conversation',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.whiteColor : Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Send a message to begin chatting',
            style: TextStyle(
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.whiteColor.withOpacity(0.6)
                  : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
