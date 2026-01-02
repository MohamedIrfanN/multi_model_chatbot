import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multimodel_chatbot/screens/chat/controller/chat_controller.dart';
import 'package:multimodel_chatbot/screens/chat/view/chats_view.dart';
import '../../chat/bindings/chat_binding.dart';
import '../controller/auth_controller.dart';
import 'login_view.dart';

class AuthGate extends GetView<AuthController> {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoggedIn) {
        // ✅ Ensure ChatBinding runs only once
        if (!Get.isRegistered<ChatController>()) {
          ChatBinding().dependencies();
        }
        return const ChatScreenView();
      }
      return const LoginView();
    });
  }
}