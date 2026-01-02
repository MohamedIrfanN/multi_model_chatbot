import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth_api_services.dart';

class AuthController extends GetxController {
  // Controllers
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmPasswordCtrl = TextEditingController();

  // State
  final isLoading = false.obs;
  final errorText = RxnString();
  final userId = RxnString();

  bool get isLoggedIn => userId.value != null;

  // Services
  final AuthApiService _authApi = AuthApiService();
  SharedPreferences? _prefs;

  @override
  void onInit() {
    super.onInit();
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final token = _prefs?.getString('access_token');
      final uid = _prefs?.getString('user_id');

      if ((token ?? '').isNotEmpty && (uid ?? '').isNotEmpty) {
        userId.value = uid;
      }
    } catch (e) {
      // Don’t crash app if local storage fails on startup
      debugPrint('SharedPreferences restore failed: $e');
    }
  }

  Future<void> _persistAuth({
    required String accessToken,
    required String uid,
  }) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString('access_token', accessToken);
      await _prefs!.setString('user_id', uid);
    } catch (e) {
      debugPrint('SharedPreferences write failed: $e');
      rethrow;
    }
  }

  // -------------------------
  // Login
  // -------------------------
  Future<void> login() async {
    errorText.value = null;

    final email = emailCtrl.text.trim();
    final pass = passwordCtrl.text;

    if (email.isEmpty || !email.contains('@')) {
      errorText.value = 'Enter a valid email';
      return;
    }
    if (pass.length < 6) {
      errorText.value = 'Password must be at least 6 characters';
      return;
    }

    isLoading.value = true;

    try {
      final res = await _authApi.login(email: email, password: pass);

      final accessToken = res['access_token']?.toString();
      final uid = res['user_id']?.toString();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Missing access_token from API');
      }
      if (uid == null || uid.isEmpty) {
        throw Exception('Missing user_id from API');
      }

      await _persistAuth(accessToken: accessToken, uid: uid);
      userId.value = uid;
    } on DioException catch (e) {
      errorText.value =
          e.response?.data?['detail']?.toString() ??
          'Invalid email or password';
    } catch (e) {
      // TEMP: show real error so we can fix it quickly
      errorText.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // -------------------------
  // Register
  // -------------------------
  Future<void> register() async {
    errorText.value = null;

    final email = emailCtrl.text.trim();
    final pass = passwordCtrl.text;
    final confirm = confirmPasswordCtrl.text;

    if (email.isEmpty || !email.contains('@')) {
      errorText.value = 'Enter a valid email';
      return;
    }
    if (pass.length < 6) {
      errorText.value = 'Password must be at least 6 characters';
      return;
    }
    if (pass != confirm) {
      errorText.value = 'Passwords do not match';
      return;
    }

    isLoading.value = true;

    try {
      final res = await _authApi.register(email: email, password: pass);

      final uid = res['user_id']?.toString();

      if (uid == null || uid.isEmpty) {
        throw Exception('Missing user_id from API');
      }

      resetAuthFields(keepEmail: true);
      _showRegisterSuccessDialog();
    } on DioException catch (e) {
      errorText.value =
          e.response?.data?['detail']?.toString() ?? 'Account already exists';
    } catch (e) {
      // TEMP: show real error so we can fix it quickly
      errorText.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void _showRegisterSuccessDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account created!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You can now sign in with your new credentials.',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.15),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Get.back(); // close dialog
                      Get.back(); // return to login view
                    },
                    child: const Text('Go to login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------
  // Logout
  // -------------------------
  Future<void> logout() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.remove('access_token');
      await _prefs!.remove('user_id');
    } catch (e) {
      debugPrint('SharedPreferences delete failed: $e');
    }

    userId.value = null;

    emailCtrl.clear();
    passwordCtrl.clear();
    confirmPasswordCtrl.clear();
    errorText.value = null;
  }

  void resetAuthFields({bool keepEmail = false}) {
    final email = emailCtrl.text;

    emailCtrl.clear();
    passwordCtrl.clear();
    confirmPasswordCtrl.clear();
    errorText.value = null;

    if (keepEmail) {
      emailCtrl.text = email;
      emailCtrl.selection = TextSelection.collapsed(offset: email.length);
    }
  }

  @override
  void onClose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    confirmPasswordCtrl.dispose();
    super.onClose();
  }
}
