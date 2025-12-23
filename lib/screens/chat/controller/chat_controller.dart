import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';
import '../services/chat_api_service.dart';
import '../models/chat_model.dart';

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
  final selectedModel = ChatModel.gpt4oMini.obs;

  // Sidebar search UI state
  final isSearchOpen = false.obs;

  void openSearch() {
    searchFieldController.text = searchQuery.value;
    isSearchOpen.value = true;
    isSearching.value = searchQuery.value.isNotEmpty;
  }

  void closeSearch() => isSearchOpen.value = false;

  // Search
  final searchQuery = ''.obs;
  final isSearching = false.obs;
  final TextEditingController searchFieldController = TextEditingController();

  Timer? _searchDebounce;

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
    final bool isFirstMessage = messages.isEmpty;

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

    if (isFirstMessage && text.isNotEmpty) {
      _startTitleStream(sessionId: sessionId, prompt: text);
    }

    try {
      final modelId = selectedModel.value.apiName;

      final stream = image != null
          ? _apiService.streamImageMessage(
              sessionId: sessionId,
              imageFile: image,
              text: text,
              model: modelId,
            )
          : _apiService.streamMessage(
              sessionId: sessionId,
              message: text,
              model: modelId,
            );

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

  void _startTitleStream({required String sessionId, required String prompt}) {
    unawaited(_generateSessionTitle(sessionId: sessionId, prompt: prompt));
  }

  Future<void> _generateSessionTitle({
    required String sessionId,
    required String prompt,
  }) async {
    try {
      final stream = _apiService.streamTitle(
        sessionId: sessionId,
        prompt: prompt,
      );
      var buffer = '';
      await for (final chunk in stream) {
        buffer += chunk;
        _applySessionTitle(sessionId, buffer);
      }
    } catch (e) {
      debugPrint('Title stream failed: $e');
    }
  }

  void _applySessionTitle(String sessionId, String rawTitle) {
    final normalized = rawTitle
        .replaceAll('\n', ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (normalized.isEmpty) return;

    final index = sessions.indexWhere((s) => s.id == sessionId);
    if (index == -1) return;

    sessions[index] = sessions[index].copyWith(title: normalized);
  }

  void setModel(ChatModel model) {
    selectedModel.value = model;
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    isSearching.value = value.trim().isNotEmpty;

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      // trigger reactive rebuild after debounce
      searchQuery.refresh();
    });
  }

  void resetSearch() {
    searchFieldController.clear();
    searchQuery.value = '';
    isSearching.value = false;
    searchQuery.refresh();
  }

  List<ChatSession> get filteredSessions {
    final query = searchQuery.value.trim().toLowerCase();

    if (query.isEmpty) {
      return sessions;
    }

    return sessions.where((s) {
      final title = s.title?.toLowerCase() ?? '';
      return title.contains(query);
    }).toList();
  }

  Future<void> deleteChat(String sessionId) async {
    try {
      await _apiService.deleteSession(sessionId);

      sessions.removeWhere((s) => s.id == sessionId);

      // If the deleted chat was selected
      if (selectedSessionId.value == sessionId) {
        messages.clear();

        if (sessions.isNotEmpty) {
          await selectChat(sessions.first.id);
        } else {
          final newSession = await _apiService.createSession();
          sessions.add(newSession);
          await selectChat(newSession.id);
        }
      }
    } catch (e) {
      debugPrint('Delete chat failed: $e');
    }
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    messageController
      ..removeListener(_handleInputChanged)
      ..dispose();
    searchFieldController.dispose();
    super.onClose();
  }
}
