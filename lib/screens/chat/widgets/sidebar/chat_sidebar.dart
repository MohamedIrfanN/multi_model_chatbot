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
      margin: const EdgeInsets.symmetric(vertical: 10),
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
                final sessions = controller.filteredSessions;
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
                      onDelete: () => controller.deleteChat(session.id),
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
  const _SidebarHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44, // fixed height → no layout jump
      child: Obx(() {
        final isSearchOpen = controller.isSearchOpen.value;

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final slide = Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(animation);

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: slide, child: child),
            );
          },
          child: isSearchOpen
              ? const _SearchBar(key: ValueKey('search'))
              : const _HeaderActions(key: ValueKey('actions')),
        );
      }),
    );
  }
}

class _HeaderActions extends GetView<ChatController> {
  const _HeaderActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      key: key,
      children: [
        _circleButton(icon: Icons.menu, onTap: controller.toggleSidebar),
        const Spacer(),
        _circleButton(
          icon: Icons.search,
          onTap: () {
            controller.openSearch();
            controller.isSearching.value = true;
          },
        ),
      ],
    );
  }
}

class _SearchBar extends GetView<ChatController> {
  const _SearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, size: 18, color: Colors.white60),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller.searchFieldController,
              autofocus: true,
              onChanged: controller.onSearchChanged,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search chats…',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              controller.resetSearch();
              controller.closeSearch();
            },
            child: const Icon(Icons.close, size: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
  return GestureDetector(
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
