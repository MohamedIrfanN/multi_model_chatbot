import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:multimodel_chatbot/screens/chat/bindings/chat_binding.dart';
import 'package:multimodel_chatbot/screens/chat/controller/chat_controller.dart';
import 'package:multimodel_chatbot/screens/chat/view/chats_view.dart';

void main() {
  Get.put(ChatController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Multimodel Chatbot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialBinding: ChatBinding(),
      home: const ChatScreenView(),
    );
  }
}
