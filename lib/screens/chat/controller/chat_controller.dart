import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/chat_api_service.dart';

class ChatController extends GetxController {
  // Suggestions (keep as-is)
  final suggestions = <String>[
    'Any advice for me?',
    'Some YouTube video idea',
    'Life lessons',
  ].obs;

  // Backend-driven state
  final sessions = <ChatSession>[].obs;
  final messages = <ChatMessage>[].obs;
  final selectedSessionId = RxnString();

  final Rx<File?> selectedImage = Rx<File?>(null);

  // Input
  final messageController = TextEditingController();
  final isComposing = false.obs;

  // API
  final ChatApiService _apiService = ChatApiService();

  final isSidebarOpen = true.obs;
  final isCompactMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    messageController.addListener(_handleInputChanged);
    _bootstrap();
  }

  // -------------------------
  // Startup: restore last chat
  // -------------------------
  Future<void> _bootstrap() async {
    try {
      final fetchedSessions = await _apiService.fetchSessions();

      if (fetchedSessions.isNotEmpty) {
        sessions.assignAll(fetchedSessions);
        await selectChat(fetchedSessions.first.id); // most recent
      } else {
        final session = await _apiService.createSession();
        sessions.add(session);
        await selectChat(session.id);
      }
    } catch (e) {
      debugPrint('Bootstrap failed: $e');
    }
  }

  // -------------------------
  // Session handling
  // -------------------------
  Future<void> createNewChat() async {
    try {
      final session = await _apiService.createSession();
      sessions.insert(0, session);
      await selectChat(session.id);
    } catch (e) {
      debugPrint('Create chat failed: $e');
    }
  }

  Future<void> selectChat(String sessionId) async {
    selectedSessionId.value = sessionId;
    messages.clear();

    try {
      final fetched = await _apiService.fetchMessages(sessionId);
      messages.assignAll(fetched);
    } catch (e) {
      debugPrint('Load messages failed: $e');
    }

    messageController.clear();
    isComposing.value = false;
  }

  // -------------------------
  // Suggestions
  // -------------------------
  void fillFromSuggestion(String suggestion) {
    messageController
      ..text = suggestion
      ..selection = TextSelection.collapsed(offset: suggestion.length);
    isComposing.value = true;
  }

  // -------------------------
  // Send + stream message
  // -------------------------
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    final sessionId = selectedSessionId.value;
    final image = selectedImage.value;

    if (sessionId == null) return;
    if (text.isEmpty && image == null) return;

    messageController.clear();
    isComposing.value = false;
    clearSelectedImage();

    // 1️⃣ Optimistic user message
    messages.add(
      ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
        imageFile: image, // add this field in model
      ),
    );

    // 2️⃣ Empty assistant message
    messages.add(
      ChatMessage(text: '', isUser: false, timestamp: DateTime.now()),
    );
    final assistantIndex = messages.length - 1;

    try {
      final stream = image != null
          ? _apiService.streamImageMessage(
              sessionId: sessionId,
              imageFile: image,
              text: text,
            )
          : _apiService.streamMessage(sessionId: sessionId, message: text);

      await for (final chunk in stream) {
        final current = messages[assistantIndex];
        messages[assistantIndex] = current.copyWith(text: current.text + chunk);
      }
    } catch (e) {
      final current = messages[assistantIndex];
      messages[assistantIndex] = current.copyWith(
        text: '⚠️ Failed to get response.',
      );
    }
  }

  // -------------------------
  // Input state
  // -------------------------
  void _handleInputChanged() {
    isComposing.value = messageController.text.trim().isNotEmpty;
  }

  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: false,
    );

    if (result != null && result.files.single.path != null) {
      selectedImage.value = File(result.files.single.path!);
    }
  }

  void clearSelectedImage() {
    selectedImage.value = null;
  }

  void toggleSidebar() {
    isSidebarOpen.toggle();
  }

  void setCompactMode(bool value) {
    if (isCompactMode.value == value) return;
    isCompactMode.value = value;

    if (value) {
      isSidebarOpen.value = false;
    }
  }

  @override
  void onClose() {
    messageController
      ..removeListener(_handleInputChanged)
      ..dispose();
    super.onClose();
  }
}
