import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/chat_controller.dart';

class ChatInputBar extends GetView<ChatController> {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add, color: Colors.white70),
                  onPressed: () {},
                ),
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Ask anything ...',
                      hintStyle: TextStyle(color: Colors.white54),
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
                Obx(
                  () {
                    final isComposing = controller.isComposing.value;
                    return IconButton(
                      icon: Icon(
                        Icons.send,
                        color: isComposing ? Colors.white : Colors.white38,
                      ),
                      onPressed: isComposing ? controller.sendMessage : null,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
