import 'package:dio/dio.dart';

class AuthApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8000',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/register',
      data: {'email': email, 'password': password},
    );

    if (res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw Exception('Unexpected register response: ${res.data.runtimeType}');
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );

    if (res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw Exception('Unexpected login response: ${res.data.runtimeType}');
  }
}
