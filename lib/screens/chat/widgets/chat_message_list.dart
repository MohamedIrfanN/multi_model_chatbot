import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/chat_controller.dart';
import 'typing_indicator.dart';
import 'package:flutter/services.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({super.key});

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final ChatController controller = Get.find();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Schedule scroll AFTER the list rebuilds
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Align(
              alignment: message.isUser
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? Colors.white.withOpacity(0.12)
                      : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: message.text.isEmpty && !message.isUser
                    ? const TypingIndicator()
                    : GestureDetector(
                        onSecondaryTap: () {
                          Clipboard.setData(ClipboardData(text: message.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                              duration: Duration(milliseconds: 800),
                            ),
                          );
                        },
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: message.text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                              duration: Duration(milliseconds: 800),
                            ),
                          );
                        },
                        child: SelectableText(
                          message.text,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
            ),
          );
        },
      );
    });
  }
}
