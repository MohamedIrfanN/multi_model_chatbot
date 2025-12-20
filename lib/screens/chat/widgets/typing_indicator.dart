import 'package:flutter/material.dart';

/// ChatGPT-like "typing" indicator using 3 dots that pulse (grow/shrink).
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _dotScale(double t, double delay) {
    // t in [0..1)
    final x = (t + delay) % 1.0;
    // Sine-like pulse: 0.65 → 1.15 → 0.65
    final pulse = 0.65 + 0.5 * (0.5 - (x - 0.5).abs()) * 2; // triangle wave
    return pulse.clamp(0.65, 1.15);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Dot(scale: _dotScale(t, 0.00)),
            const SizedBox(width: 6),
            _Dot(scale: _dotScale(t, 0.18)),
            const SizedBox(width: 6),
            _Dot(scale: _dotScale(t, 0.36)),
          ],
        );
      },
    );
  }
}

class _Dot extends StatelessWidget {
  final double scale;
  const _Dot({required this.scale});

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
