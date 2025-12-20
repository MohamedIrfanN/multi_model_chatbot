import 'package:flutter/material.dart';

class SidebarNewChatButton extends StatelessWidget {
  const SidebarNewChatButton({
    super.key,
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.white.withOpacity(0.07),
          border: Border.all(
            color: Colors.white.withOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.edit_outlined,
              color: Colors.white70,
              size: 18,
            ),
            SizedBox(width: 10),
            Text(
              'New chat',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
