import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/chat_controller.dart';

class SuggestionChips extends GetView<ChatController> {
  const SuggestionChips({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Obx(
        () {
          final suggestions = controller.suggestions;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: suggestions.map((text) {
              return GestureDetector(
                onTap: () => controller.fillFromSuggestion(text),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    text,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
