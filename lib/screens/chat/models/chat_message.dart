import 'dart:io';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  // 🆕 Optional image (for multimodal messages)
  final File? imageFile;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageFile,
  });

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    File? imageFile,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      imageFile: imageFile ?? this.imageFile,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      text: json['content'] ?? '',
      isUser: json['role'] == 'user',
      timestamp: DateTime.now(),
      // imageFile intentionally left null (text-only history)
    );
  }
}
