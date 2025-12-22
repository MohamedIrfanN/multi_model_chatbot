import 'package:flutter/material.dart';

class SidebarNewChatButton extends StatelessWidget {
  final VoidCallback onTap;

  const SidebarNewChatButton({super.key, required this.onTap});

  static const double _iconSize = 18;
  static const double _gap = 8;
  static const double _textWidth = 62; // measured "New chat"
  static const double _horizontalPadding = 14 * 2;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final requiredWidth =
            _iconSize + _gap + _textWidth + _horizontalPadding;

        final showText = constraints.maxWidth >= requiredWidth;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add,
                  size: _iconSize,
                  color: Colors.white70,
                ),

                if (showText) ...[
                  const SizedBox(width: _gap),
                  const Text(
                    'New chat',
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}