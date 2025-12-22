import 'dart:convert';
import 'package:dio/dio.dart';
import 'dart:io';
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
    final res = await _jsonDio.get('/sessions');
    return (res.data as List).map((e) => ChatSession.fromJson(e)).toList();
  }

  Future<ChatSession> createSession() async {
    final res = await _jsonDio.post('/sessions', data: {'title': 'New chat'});
    return ChatSession.fromJson(res.data);
  }

  Future<List<ChatMessage>> fetchMessages(String sessionId) async {
    final res = await _jsonDio.get('/sessions/$sessionId/messages');
    return (res.data as List).map((e) => ChatMessage.fromJson(e)).toList();
  }

  // -------------------------
  // Streaming chat
  // -------------------------
  Stream<String> streamMessage({
    required String sessionId,
    required String message,
  }) async* {
    final response = await _streamDio.post<ResponseBody>(
      '/chat',
      data: {'session_id': sessionId, 'message': message},
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
  }) async* {
    final formData = FormData.fromMap({
      'session_id': sessionId,
      if (text != null && text.isNotEmpty) 'text': text,
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
    });

    final response = await _streamDio.post<ResponseBody>(
      '/chat/image',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final stream = response.data!.stream;
    await for (final chunk in stream.cast<List<int>>()) {
      final decoded = String.fromCharCodes(chunk);
      if (decoded.isNotEmpty) yield decoded;
    }
  }
}
