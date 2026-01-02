import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class ChatApiService {
  // Normal JSON requests
  final Dio _jsonDio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8000',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Streaming requests ONLY
  final Dio _streamDio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8000',
      responseType: ResponseType.stream,
      receiveTimeout: const Duration(seconds: 0),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // -------------------------
  // Sessions
  // -------------------------
  Future<List<ChatSession>> fetchSessions() async {
    final res = await _jsonDio.get('/sessions', options: await _authOptions());
    return (res.data as List).map((e) => ChatSession.fromJson(e)).toList();
  }

  Future<ChatSession> createSession() async {
    final res = await _jsonDio.post(
      '/sessions',
      data: {'title': 'New chat'},
      options: await _authOptions(),
    );
    return ChatSession.fromJson(res.data);
  }

  Future<List<ChatMessage>> fetchMessages(String sessionId) async {
    final res = await _jsonDio.get(
      '/sessions/$sessionId/messages',
      options: await _authOptions(),
    );
    return (res.data as List).map((e) => ChatMessage.fromJson(e)).toList();
  }

  // -------------------------
  // Streaming chat
  // -------------------------
  Stream<String> streamMessage({
    required String sessionId,
    required String message,
    required String model,
  }) async* {
    final response = await _streamDio.post<ResponseBody>(
      '/chat',
      data: {'session_id': sessionId, 'message': message, 'model': model},
      options: await _authOptions(),
    );

    final byteStream = response.data!.stream;
    await for (final chunk in byteStream.cast<List<int>>().transform(
      utf8.decoder,
    )) {
      if (chunk.isNotEmpty) {
        yield chunk;
      }
    }
  }

  Stream<String> streamImageMessage({
    required String sessionId,
    required File imageFile,
    String? text,
    required String model,
  }) async* {
    final formData = FormData.fromMap({
      'session_id': sessionId,
      if (text != null && text.isNotEmpty) 'text': text,
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
      'model': model,
    });

    final response = await _streamDio.post<ResponseBody>(
      '/chat/image',
      data: formData,
      options: (await _authOptions()).copyWith(
        contentType: 'multipart/form-data',
      ),
    );

    final stream = response.data!.stream;
    await for (final chunk in stream.cast<List<int>>()) {
      final decoded = String.fromCharCodes(chunk);
      if (decoded.isNotEmpty) yield decoded;
    }
  }

  Stream<String> streamTitle({
    required String sessionId,
    required String prompt,
  }) async* {
    final response = await _streamDio.post<ResponseBody>(
      '/chat/title',
      data: {'session_id': sessionId, 'prompt': prompt},
      options: await _authOptions(),
    );

    final stream = response.data!.stream;
    await for (final chunk in stream.cast<List<int>>().transform(
      utf8.decoder,
    )) {
      if (chunk.isNotEmpty) {
        yield chunk;
      }
    }
  }

  Future<void> deleteSession(String sessionId) async {
    final response = await _jsonDio.delete(
      '/chat/session/$sessionId',
      options: await _authOptions(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete session');
    }
  }

  SharedPreferences? _prefs;

  Future<Options> _authOptions() async {
    _prefs ??= await SharedPreferences.getInstance();
    final token = _prefs?.getString('access_token');
    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }
}
