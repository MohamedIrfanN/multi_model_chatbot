import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';

import '../controller/chat_controller.dart';
import '../models/chat_message.dart';
import 'typing_indicator.dart';

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
      // Scroll after rebuild (important for streaming & images)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });

      return ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final message = controller.messages[index];

          final isTypingIndicator =
              message.text.isEmpty && !message.isUser && !message.hasImage;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Align(
              alignment: message.isUser
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: IntrinsicWidth(
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
                  child: isTypingIndicator
                      ? const TypingIndicator()
                      : GestureDetector(
                          onSecondaryTap: () =>
                              _copyText(context, message.text),
                          onLongPress: () => _copyText(context, message.text),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 🖼 Image (if exists)
                              if (message.hasImage)
                                SizedBox(
                                  width: 250,
                                  height: 320,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      // width: 280, // ✅ HARD WIDTH (key fix)
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: _buildMessageImage(message),
                                    ),
                                  ),
                                ),

                              // spacing between image & text
                              if (message.hasImage && message.text.isNotEmpty)
                                const SizedBox(height: 8),

                              // 📝 Markdown text (if exists)
                              if (message.text.isNotEmpty)
                                MarkdownBody(
                                  data: message.text,
                                  selectable: true,
                                  styleSheet: MarkdownStyleSheet(
                                    p: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                    code: TextStyle(
                                      color: Colors.greenAccent.shade200,
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                    ),
                                    codeblockPadding: const EdgeInsets.all(12),
                                    codeblockDecoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.35),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                            ],
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

  Widget _buildMessageImage(ChatMessage message) {
    if (message.imageFile != null) {
      return Image.file(message.imageFile!, fit: BoxFit.fill);
    }

    if (message.imageBytes != null) {
      return Image.memory(message.imageBytes!, fit: BoxFit.fill);
    }

    return const SizedBox.shrink();
  }

  void _copyText(BuildContext context, String text) {
    if (text.isEmpty) return;

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(milliseconds: 800),
      ),
    );
  }
}
