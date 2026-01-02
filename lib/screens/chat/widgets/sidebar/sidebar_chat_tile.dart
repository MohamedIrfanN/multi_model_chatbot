import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/chat_controller.dart';
import '../../models/chat_session.dart';

class SidebarChatTile extends StatelessWidget {
  final ChatSession session;
  final bool isSelected;
  final VoidCallback onTap;

  const SidebarChatTile({
    super.key,
    required this.session,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ChatController>();

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? Colors.white.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              // ── Title (bounded width) ───────────
              Expanded(
                child: Text(
                  session.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),

              // ── Fixed gap ──────────────────────
              const SizedBox(width: 12),

              // ── Delete button (FIXED SIZE) ─────
              SizedBox(
                child: GestureDetector(
                  onTap: () => _confirmDelete(context, controller),
                  behavior: HitTestBehavior.opaque,
                  child: const Icon(
                    Icons.delete_outline,
                    size: 18,
                    color: Colors.white70,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ChatController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: const Text(
          'Delete chat?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'This will permanently delete this chat.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Get.back();
              await controller.deleteChat(session.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}
