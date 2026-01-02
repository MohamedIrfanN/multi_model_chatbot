import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'screens/auth/bindings/auth_binding.dart';
import 'screens/auth/view/auth_gate.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Multimodel Chatbot',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialBinding: AuthBinding(),
      home: const AuthGate(),
    );
  }
}
