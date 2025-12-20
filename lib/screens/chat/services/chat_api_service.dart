import 'package:dio/dio.dart';
import 'dart:convert';

class ChatApiService {
  late final Dio _dio;

  ChatApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:8000',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 0),
        responseType: ResponseType.stream,
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Stream<String> streamMessage(String message) async* {
    final response = await _dio.post<ResponseBody>(
      '/chat',
      data: {'message': message},
      options: Options(responseType: ResponseType.stream),
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
}

// class ChatApiService {
//   late final Dio _dio;

//   ChatApiService() {
//     _dio = Dio(
//       BaseOptions(
//         baseUrl: 'http://localhost:8000',
//         connectTimeout: const Duration(seconds: 10),
//         receiveTimeout: const Duration(seconds: 30),
//         headers: {'Content-Type': 'application/json'},
//       ),
//     );
//   }

//   /// Sends a user message to the backend and returns the AI reply
//   Future<String> sendMessage(String message) async {
//     try {
//       print('📤 Sending message to backend: $message');
//       final response = await _dio.post('/chat', data: {'message': message});
//       print('📥 Backend response: ${response.data}');

//       // Expected backend response:
//       // { "reply": "..." }
//       final data = response.data;

//       if (data == null || data['reply'] == null) {
//         throw Exception('Invalid response from server');
//       }

//       return data['reply'] as String;
//     } on DioException catch (e) {
//       // Network / server error
//       final errorMessage =
//           e.response?.data?.toString() ?? e.message ?? 'Unknown error';
//       throw Exception('Backend error: $errorMessage');
//     } catch (e) {
//       // Any other error
//       throw Exception('Unexpected error: $e');
//     }
//   }

// }
