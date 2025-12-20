import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/chat_api_service.dart';

class ChatController extends GetxController {
  final suggestions = <String>[
    'Any advice for me?',
    'Some YouTube video idea',
    'Life lessons',
  ].obs;

  final sessions = <ChatSession>[].obs;
  final messages = <ChatMessage>[].obs;
  final selectedSessionId = RxnString();

  final messageController = TextEditingController();
  final isComposing = false.obs;

  final Map<String, List<ChatMessage>> _messagesPerSession = {};
  static const _defaultSessionTitle = 'New chat';

  // 🔹 API service (single instance)
  final ChatApiService _apiService = ChatApiService();

  @override
  void onInit() {
    super.onInit();
    messageController.addListener(_handleInputChanged);
    _createInitialSession();
  }

  void _createInitialSession() {
    final session = _buildSession();
    sessions.add(session);
    selectedSessionId.value = session.id;
    _messagesPerSession[session.id] = <ChatMessage>[];
    messages.clear();
  }

  ChatSession _buildSession() {
    final now = DateTime.now();
    return ChatSession(
      id: now.microsecondsSinceEpoch.toString(),
      title: _defaultSessionTitle,
      createdAt: now,
      updatedAt: now,
    );
  }

  void createNewChat() {
    final session = _buildSession();
    sessions.insert(0, session);
    _messagesPerSession[session.id] = <ChatMessage>[];
    selectChat(session.id);
    messageController.clear();
    isComposing.value = false;
  }

  void selectChat(String sessionId) {
    if (!sessions.any((chat) => chat.id == sessionId)) return;

    selectedSessionId.value = sessionId;
    messages.assignAll(_messagesPerSession[sessionId] ?? <ChatMessage>[]);
    messageController.clear();
    isComposing.value = false;
  }

  void _handleInputChanged() {
    isComposing.value = messageController.text.trim().isNotEmpty;
  }

  void fillFromSuggestion(String suggestion) {
    messageController
      ..text = suggestion
      ..selection = TextSelection.collapsed(offset: suggestion.length);
    isComposing.value = suggestion.trim().isNotEmpty;
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    final sessionId = selectedSessionId.value;
    if (text.isEmpty || sessionId == null) return;
    messageController.clear();

    final timestamp = DateTime.now();

    // 1️⃣ User message
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: timestamp,
    );
    messages.add(userMessage);

    // 2️⃣ Empty assistant message (will be streamed into)
    messages.add(
      ChatMessage(text: '', isUser: false, timestamp: DateTime.now()),
    );
    _updateSessionSummary(sessionId, text, timestamp);
    // Capture index ONCE
    final assistantIndex = messages.length - 1;

    try {
      await for (final chunk in _apiService.streamMessage(text)) {
        final current = messages[assistantIndex];

        messages[assistantIndex] = current.copyWith(text: current.text + chunk);
      }
    } catch (e) {
      final current = messages[assistantIndex];
      messages[assistantIndex] = current.copyWith(
        text: '⚠️ Failed to stream response.',
      );
    }

    // 4️⃣ Persist final state
    _messagesPerSession[sessionId] = List<ChatMessage>.from(messages);
  }

  void _updateSessionSummary(
    String sessionId,
    String latestMessage,
    DateTime timestamp,
  ) {
    final index = sessions.indexWhere((chat) => chat.id == sessionId);
    if (index == -1) return;

    final chat = sessions[index];
    final updatedChat = chat.copyWith(
      title: chat.title == _defaultSessionTitle
          ? _truncate(latestMessage)
          : chat.title,
      updatedAt: timestamp,
    );

    sessions[index] = updatedChat;
    sessions.refresh();
  }

  String _truncate(String text) {
    const maxChars = 36;
    if (text.length <= maxChars) return text;
    return '${text.substring(0, maxChars - 1)}…';
  }

  @override
  void onClose() {
    messageController
      ..removeListener(_handleInputChanged)
      ..dispose();
    super.onClose();
  }
}









 // Future<void> sendMessage() async {
  //   final text = messageController.text.trim();
  //   final sessionId = selectedSessionId.value;
  //   if (text.isEmpty || sessionId == null) return;

  //   final timestamp = DateTime.now();

  //   // 1️⃣ Add user message (optimistic UI)
  //   final userMessage = ChatMessage(
  //     text: text,
  //     isUser: true,
  //     timestamp: timestamp,
  //   );
  //   messages.add(userMessage);

  //   // 2️⃣ Add assistant placeholder
  //   final placeholder = ChatMessage(
  //     text: 'Thinking...',
  //     isUser: false,
  //     timestamp: DateTime.now(),
  //   );
  //   messages.add(placeholder);

  //   // Persist immediately
  //   _messagesPerSession[sessionId] = List<ChatMessage>.from(messages);
  //   _updateSessionSummary(sessionId, text, timestamp);

  //   messageController.clear();
  //   isComposing.value = false;

  //   try {
  //     // 3️⃣ Call backend
  //     final reply = await _apiService.sendMessage(text);

  //     // 4️⃣ Replace placeholder with real response
  //     final index = messages.indexOf(placeholder);
  //     if (index != -1) {
  //       messages[index] = ChatMessage(
  //         text: reply,
  //         isUser: false,
  //         timestamp: DateTime.now(),
  //       );
  //     }
  //   } catch (e) {
  //     // 5️⃣ Replace placeholder with error
  //     final index = messages.indexOf(placeholder);
  //     if (index != -1) {
  //       messages[index] = ChatMessage(
  //         text: '⚠️ Failed to get response. Please try again.',
  //         isUser: false,
  //         timestamp: DateTime.now(),
  //       );
  //     }
  //   }

  //   // Persist final state
  //   _messagesPerSession[sessionId] = List<ChatMessage>.from(messages);
  // }