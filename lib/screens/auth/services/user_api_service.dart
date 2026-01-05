import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8000',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  SharedPreferences? _prefs;

  Future<Map<String, dynamic>> fetchTokenUsage() async {
    final res = await _dio.get(
      '/me/tokens',
      options: await _authOptions(),
    );

    if (res.data is Map) {
      return Map<String, dynamic>.from(res.data as Map);
    }
    throw Exception('Unexpected /me/tokens response: ${res.data.runtimeType}');
  }

  Future<Options> _authOptions() async {
    _prefs ??= await SharedPreferences.getInstance();
    final token = _prefs?.getString('access_token');
    if (token == null || token.isEmpty) {
      throw Exception('Missing auth token');
    }
    return Options(headers: {'Authorization': 'Bearer $token'});
  }
}
