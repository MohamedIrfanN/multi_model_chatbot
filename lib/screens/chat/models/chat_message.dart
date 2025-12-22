import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  // 🆕 Optional image (for multimodal messages)
  final File? imageFile;
  final Uint8List? imageBytes;
  final String? imageMime;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageFile,
    this.imageBytes,
    this.imageMime,
  });

  bool get hasImage => imageFile != null || imageBytes != null;

  ChatMessage copyWith({
    String? text,
    bool? isUser,
    DateTime? timestamp,
    File? imageFile,
    Uint8List? imageBytes,
    String? imageMime,
  }) {
    return ChatMessage(
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      imageFile: imageFile ?? this.imageFile,
      imageBytes: imageBytes ?? this.imageBytes,
      imageMime: imageMime ?? this.imageMime,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    Uint8List? decodedBytes;
    final encoded = json['image_base64'] as String?;
    if (encoded != null && encoded.isNotEmpty) {
      decodedBytes = base64Decode(encoded);
    }

    return ChatMessage(
      text: json['content'] ?? '',
      isUser: json['role'] == 'user',
      timestamp: DateTime.now(),
      imageBytes: decodedBytes,
      imageMime: json['image_mime'] as String?,
    );
  }
}
