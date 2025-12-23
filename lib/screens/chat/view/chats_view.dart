import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multimodel_chatbot/screens/chat/widgets/chat_header.dart';

import '../controller/chat_controller.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_list.dart';
import '../widgets/sidebar/chat_sidebar.dart';
import '../widgets/suggestion_chips.dart';
import '../widgets/welcome_section.dart';

class ChatScreenView extends GetView<ChatController> {
  const ChatScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/starshd.png', fit: BoxFit.cover),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 900;
              controller.setCompactMode(isCompact);
              const double compactDrawerWidth = 280.0;

              Widget chatSurface = Container(
                padding: const EdgeInsets.only(bottom: 15, left: 12, right: 12),
                child: Obx(() {
                  final hasMessages = controller.messages.isNotEmpty;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: hasMessages
                        ? const _ChatConversation()
                        : const _ChatLanding(),
                  );
                }),
              );

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1380),
                  child: SizedBox(
                    width: double.infinity,
                    child: isCompact
                        ? Obx(() {
                            final isOpen = controller.isSidebarOpen.value;
                            final double chatOffset = isOpen
                                ? compactDrawerWidth
                                : 0;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRect(
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 260),
                                    curve: Curves.easeOutCubic,
                                    transform: Matrix4.translationValues(
                                      chatOffset,
                                      0,
                                      0,
                                    ),
                                    child: Stack(
                                      children: [
                                        chatSurface,
                                        _buildFloatingMenuButton(),
                                      ],
                                    ),
                                  ),
                                ),
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutCubic,
                                  top: 0,
                                  bottom: 0,
                                  left: isOpen ? 0 : -compactDrawerWidth - 32,
                                  child: SizedBox(
                                    width: compactDrawerWidth,
                                    child: const ChatSidebar(),
                                  ),
                                ),
                              ],
                            );
                          })
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Obx(() {
                                final isOpen = controller.isSidebarOpen.value;

                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 260),
                                  curve: Curves.easeOutCubic,
                                  width: isOpen ? 280 : 0,
                                  child: ClipRect(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      widthFactor: isOpen ? 1 : 0,
                                      child: const ChatSidebar(),
                                    ),
                                  ),
                                );
                              }),
                              const SizedBox(width: 28),
                              Expanded(
                                child: Stack(
                                  children: [
                                    chatSurface,

                                    // Floating menu button when sidebar is closed
                                    _buildFloatingMenuButton(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingMenuButton() {
    return Obx(() {
      if (controller.isSidebarOpen.value) {
        return const SizedBox.shrink();
      }

      return Positioned(
        left: 16,
        top: 16,
        child: GestureDetector(
          onTap: controller.toggleSidebar,
          child: Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.08)),
            ),
            child: const Icon(Icons.menu, color: Colors.white70, size: 22),
          ),
        ),
      );
    });
  }
}

class _ChatLanding extends StatelessWidget {
  const _ChatLanding();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 50,
        surfaceTintColor: Colors.transparent,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [ChatHeader()],
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Column(
        key: const ValueKey('landing'),
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          WelcomeSection(),
          SizedBox(height: 32),
          SuggestionChips(),
          SizedBox(height: 32),
          ChatInputBar(),
        ],
      ),
    );
  }
}

class _ChatConversation extends StatelessWidget {
  const _ChatConversation();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 50,
        surfaceTintColor: Colors.transparent,
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [ChatHeader()],
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      body: Column(
        key: const ValueKey('chat'),
        children: const [
          Expanded(child: ChatMessageList()),
          SizedBox(height: 28),
          ChatInputBar(),
        ],
      ),
    );
  }
}
