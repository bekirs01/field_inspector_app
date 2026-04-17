import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Drifting squares and occasional wide “card shard” shapes (login + task flow).
class AnimatedSquareParticlesBackground extends StatefulWidget {
  const AnimatedSquareParticlesBackground({
    super.key,
    this.baseColor = kAppCanvas,
    this.accentTint = kAppAccentBlue,
    this.intensity = 1.0,
    this.particleCount,
  });

  /// Backdrop fill (also used as painter base).
  final Color baseColor;

  /// iOS-style accent; some particles pick this tint.
  final Color accentTint;

  /// Multiplies particle opacity (use below 1.0 on busy screens).
  final double intensity;

  /// Defaults: 52 when null (login), or pass fewer for list screens.
  final int? particleCount;

  @override
  State<AnimatedSquareParticlesBackground> createState() =>
      _AnimatedSquareParticlesBackgroundState();
}

class _SquareParticle {
  _SquareParticle({
    required this.xNorm,
    required this.phase,
    required this.speed,
    required this.halfSize,
    required this.opacity,
    required this.rotSeed,
    required this.useAccent,
    required this.widthMul,
    required this.heightMul,
  });

  final double xNorm;
  final double phase;
  final double speed;
  final double halfSize;
  final double opacity;
  final double rotSeed;
  final bool useAccent;
  final double widthMul;
  final double heightMul;
}

class _AnimatedSquareParticlesBackgroundState
    extends State<AnimatedSquareParticlesBackground>
    with SingleTickerProviderStateMixin {
  static const int _defaultCount = 52;

  late final List<_SquareParticle> _particles;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final count = widget.particleCount ?? _defaultCount;
    final r = math.Random(7);
    _particles = List<_SquareParticle>.generate(
      count,
      (_) {
        final cardShard = r.nextDouble() < 0.14;
        return _SquareParticle(
          xNorm: r.nextDouble(),
          phase: r.nextDouble(),
          speed: 0.07 + r.nextDouble() * 0.16,
          halfSize: cardShard
              ? 1.0 + r.nextDouble() * 1.4
              : 1.1 + r.nextDouble() * 2.0,
          opacity: (0.055 + r.nextDouble() * 0.12) * widget.intensity,
          rotSeed: r.nextDouble() * math.pi * 2,
          useAccent: r.nextBool(),
          widthMul: cardShard ? (2.2 + r.nextDouble() * 1.4) : 1.0,
          heightMul: cardShard ? 0.42 : 1.0,
        );
      },
    );
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 46),
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
          return CustomPaint(
            painter: _SquareParticlesPainter(
              particles: _particles,
              progress: _controller.value,
              baseColor: widget.baseColor,
              accentTint: widget.accentTint,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class _SquareParticlesPainter extends CustomPainter {
  _SquareParticlesPainter({
    required this.particles,
    required this.progress,
    required this.baseColor,
    required this.accentTint,
  });

  final List<_SquareParticle> particles;
  final double progress;
  final Color baseColor;
  final Color accentTint;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final bg = Paint()..color = baseColor;
    canvas.drawRect(Offset.zero & size, bg);

    for (final p in particles) {
      final y = ((p.phase + progress * p.speed) % 1.0) * (size.height + 40) - 20;
      final drift = math.sin(progress * math.pi * 2 * 0.26 + p.rotSeed) * 12;
      var x = p.xNorm * size.width + drift;
      x = x % size.width;
      if (x < 0) x += size.width;

      final rot = progress * math.pi * 2 * 0.1 + p.rotSeed;

      final color = p.useAccent
          ? accentTint.withValues(alpha: p.opacity * 0.9)
          : Colors.white.withValues(alpha: p.opacity);

      final paint = Paint()
        ..color = color
        ..isAntiAlias = true;

      final w = p.halfSize * 2 * p.widthMul;
      final h = p.halfSize * 2 * p.heightMul;
      final rCorner = math.min(w, h) * 0.18;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: w, height: h),
        Radius.circular(rCorner),
      );
      canvas.drawRRect(rect, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SquareParticlesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
