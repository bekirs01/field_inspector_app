import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Soft snowfall behind UI: small white flakes drift downward with a gentle
/// sway. Stays under scroll/content via [Stack] order; does not intercept taps.
class SubtleSnowfallBackground extends StatefulWidget {
  const SubtleSnowfallBackground({
    super.key,
    this.baseColor = kAppCanvas,
    this.flakeCount = 68,
    this.intensity = 1.0,
  });

  final Color baseColor;

  /// More flakes = fuller sky; keep ~55–80 for calm coverage.
  final int flakeCount;

  /// Multiplies flake opacity (use 0.85–1.0 on busy screens).
  final double intensity;

  @override
  State<SubtleSnowfallBackground> createState() =>
      _SubtleSnowfallBackgroundState();
}

class _Flake {
  _Flake({
    required this.xNorm,
    required this.phase,
    required this.speed,
    required this.radius,
    required this.opacity,
    required this.wobbleSeed,
  });

  final double xNorm;
  final double phase;
  final double speed;
  final double radius;
  final double opacity;
  final double wobbleSeed;
}

class _SubtleSnowfallBackgroundState extends State<SubtleSnowfallBackground>
    with SingleTickerProviderStateMixin {
  late final List<_Flake> _flakes;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final r = math.Random(19);
    _flakes = List<_Flake>.generate(
      widget.flakeCount,
      (_) => _Flake(
        xNorm: r.nextDouble(),
        phase: r.nextDouble(),
        speed: 0.11 + r.nextDouble() * 0.22,
        radius: 0.65 + r.nextDouble() * 1.35,
        opacity: (0.035 + r.nextDouble() * 0.065) * widget.intensity,
        wobbleSeed: r.nextDouble() * math.pi * 2,
      ),
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 52),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return SizedBox.expand(
            child: CustomPaint(
              painter: _SnowfallPainter(
                flakes: _flakes,
                progress: _controller.value,
                baseColor: widget.baseColor,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SnowfallPainter extends CustomPainter {
  _SnowfallPainter({
    required this.flakes,
    required this.progress,
    required this.baseColor,
  });

  final List<_Flake> flakes;
  final double progress;
  final Color baseColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    canvas.drawRect(Offset.zero & size, Paint()..color = baseColor);

    final h = size.height + 32;
    for (final f in flakes) {
      final t = (f.phase + progress * f.speed) % 1.0;
      final y = t * h - 16;
      final wobble =
          math.sin(progress * math.pi * 2 * 0.45 + f.wobbleSeed) * 7.0;
      var x = f.xNorm * size.width + wobble;
      x = x % size.width;
      if (x < 0) x += size.width;

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: f.opacity)
        ..isAntiAlias = true;
      canvas.drawCircle(Offset(x, y), f.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SnowfallPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
