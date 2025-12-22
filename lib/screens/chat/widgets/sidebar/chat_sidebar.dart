import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/chat_controller.dart';
import 'sidebar_chat_tile.dart';
import 'sidebar_new_chat_button.dart';

class ChatSidebar extends GetView<ChatController> {
  const ChatSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Obx(() {
        if (!controller.isSidebarOpen.value) {
          return const SizedBox.shrink();
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SidebarHeader(),
            const SizedBox(height: 28),
            SidebarNewChatButton(onTap: controller.createNewChat),
            const SizedBox(height: 32),
            const Text(
              'Chats',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Obx(() {
                final sessions = controller.sessions;
                final selectedId = controller.selectedSessionId.value;

                if (sessions.isEmpty) {
                  return const Center(
                    child: Text(
                      'No chats yet',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  );
                }

                return ListView.separated(
                  itemCount: sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final isSelected = session.id == selectedId;

                    return SidebarChatTile(
                      session: session,
                      isSelected: isSelected,
                      onTap: () => controller.selectChat(session.id),
                    );
                  },
                );
              }),
            ),
          ],
        );
      }),
    );
  }
}

class _SidebarHeader extends GetView<ChatController> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Sidebar is too narrow → shrink button
        final scale = width >= 36 ? 1.0 : (width / 36).clamp(0.0, 1.0);
        final canShowSearch = width >= 80;

        return ClipRect(
          child: Row(
            children: [
              Transform.scale(
                scale: scale,
                alignment: Alignment.centerLeft,
                child: _circleButton(
                  icon: Icons.menu,
                  onTap: controller.toggleSidebar,
                ),
              ),

              if (canShowSearch) ...[
                const Spacer(),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _circleButton(
                    key: const ValueKey('search'),
                    icon: Icons.search,
                    onTap: () {},
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Key? key,
  }) {
    return GestureDetector(
      key: key,
      onTap: onTap,
      child: Container(
        height: 36,
        width: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white70, size: 20),
      ),
    );
  }
}
