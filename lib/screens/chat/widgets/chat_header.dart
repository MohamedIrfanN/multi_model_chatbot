import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';
import 'model_selector/model_selector_button.dart';

class ChatHeader extends GetView<ChatController> {
  const ChatHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8), // small separation
      child: ModelSelectorButton(),
    );
  }
}
