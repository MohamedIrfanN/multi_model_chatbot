import 'package:flutter/material.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // App Icon
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.auto_awesome,
            color: Colors.white,
            size: 28,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'Good to See You!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'How Can I be an Assistance?',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: Colors.white70,
          ),
        ),

        const SizedBox(height: 12),
      ],
    );
  }
}