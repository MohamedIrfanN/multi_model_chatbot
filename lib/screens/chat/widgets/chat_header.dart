import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';
import 'model_selector/model_selector_button.dart';

class ChatHeader extends GetView<ChatController> {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _TokenUsagePill(),
          SizedBox(width: 12),
          ModelSelectorButton(),
        ],
      ),
    );
  }
}

class _TokenUsagePill extends GetView<ChatController> {
  const _TokenUsagePill();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.totalTokens.value;
      final byModel = controller.modelTokens;
      final tooltip = byModel.isEmpty
          ? 'No usage yet'
          : byModel.entries
              .map((entry) => '${entry.key}: ${entry.value} tokens')
              .join('\n');

      return Tooltip(
        message: tooltip,
        waitDuration: const Duration(milliseconds: 400),
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bolt, size: 16, color: Colors.amber.shade300),
              const SizedBox(width: 6),
              Text(
                '$total tokens',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
