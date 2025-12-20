import 'package:flutter/material.dart';

import '../../models/chat_session.dart';

class SidebarChatTile extends StatelessWidget {
  const SidebarChatTile({
    super.key,
    required this.session,
    required this.isSelected,
    required this.onTap,
  });

  final ChatSession session;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0F4C81)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withOpacity(isSelected ? 0.98 : 0.85),
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
