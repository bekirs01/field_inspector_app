import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:app_settings/app_settings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/localization/language_menu_button.dart';
import '../../tasks/presentation/widgets/task_flow_visual.dart';

/// Phase 1: camera + premium scan UI + mock result only (no task / backend).
class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen>
    with TickerProviderStateMixin {
  late final MobileScannerController _controller;
  late final AnimationController _lineController;
  late final AnimationController _pulseController;
  bool _handling = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      formats: const [BarcodeFormat.qrCode],
    );
    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _lineController.dispose();
    _pulseController.dispose();
    _controller.dispose();
    super.dispose();
  }

  Rect _scanRect(Size layout, double topReserve) {
    final w = layout.width;
    final h = layout.height;
    final side = (w * 0.72).clamp(236.0, 318.0);
    final frameH = (side * 0.92).clamp(220.0, 300.0);
    final cy = topReserve + (h - topReserve) * 0.46;
    return Rect.fromCenter(
      center: Offset(w / 2, cy),
      width: side,
      height: frameH,
    );
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    final codes = capture.barcodes;
    if (codes.isEmpty) return;
    final raw = codes.first.rawValue;
    if (raw == null || raw.isEmpty) return;

    _handling = true;
    try {
      await _controller.stop();
    } catch (_) {}

    if (!mounted) return;
    await HapticFeedback.mediumImpact();

    if (!mounted) return;
    final s = context.strings;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return _QrResultSheet(
          strings: s,
          rawValue: raw,
          onScanAgain: () {
            Navigator.of(ctx).pop();
          },
          onClose: () {
            Navigator.of(ctx).pop();
          },
        );
      },
    );

    if (!mounted) return;
    try {
      await _controller.start();
    } catch (_) {}
    _handling = false;
  }

  Widget _errorBody(AppStrings s, MobileScannerException error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDenied = error.errorCode == MobileScannerErrorCode.permissionDenied;
    final isUnsupported = error.errorCode == MobileScannerErrorCode.unsupported;

    return Container(
      color: const Color(0xFF06080C),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isDenied
                    ? Icons.photo_camera_outlined
                    : Icons.videocam_off_outlined,
                size: 56,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 22),
              Text(
                isDenied
                    ? s.qrScanPermissionTitle
                    : isUnsupported
                    ? s.qrScanUnavailable
                    : s.qrScanStartFailed,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isDenied ? s.qrScanPermissionBody : s.qrScanGenericErrorHint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 28),
              if (isDenied) ...[
                FilledButton(
                  onPressed: () => AppSettings.openAppSettings(),
                  child: Text(s.qrScanOpenSettings),
                ),
                const SizedBox(height: 12),
              ],
              OutlinedButton(
                onPressed: () async {
                  try {
                    await _controller.start();
                  } catch (_) {}
                  if (mounted) setState(() {});
                },
                child: Text(s.qrScanRetry),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentTheme = Theme.of(context);
    final lang = context.languageController;

    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        final s = context.strings;

        if (kIsWeb) {
          return Theme(
            data: taskFlowScreenTheme(parentTheme),
            child: Scaffold(
              appBar: AppBar(
                title: Text(s.qrScanScreenTitle),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: s.qrScanBackTooltip,
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: const [LanguageMenuButton()],
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Text(
                    s.qrScanUnavailable,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          );
        }

        return Theme(
          data: taskFlowScreenTheme(parentTheme),
          child: Scaffold(
            backgroundColor: Colors.black,
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.black.withValues(alpha: 0.38),
              foregroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 22),
                tooltip: s.qrScanBackTooltip,
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                s.qrScanScreenTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              actions: const [
                LanguageMenuButton(),
              ],
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final padding = MediaQuery.paddingOf(context);
                final topReserve = padding.top + kToolbarHeight;
                final layoutSize = Size(
                  constraints.maxWidth,
                  constraints.maxHeight,
                );
                final scanRect = _scanRect(layoutSize, topReserve);

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      controller: _controller,
                      fit: BoxFit.cover,
                      scanWindow: scanRect,
                      onDetect: _onDetect,
                      errorBuilder: (ctx, error) => _errorBody(s, error),
                      overlayBuilder: (ctx, constraints) {
                        final scheme = Theme.of(ctx).colorScheme;
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            CustomPaint(
                              painter: _QrDimPainter(
                                cutout: scanRect,
                                radius: 20,
                              ),
                              child: SizedBox(
                                width: constraints.maxWidth,
                                height: constraints.maxHeight,
                              ),
                            ),
                            Positioned.fromRect(
                              rect: scanRect,
                              child: IgnorePointer(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      AnimatedBuilder(
                                        animation: _lineController,
                                        builder: (context, _) {
                                          final t = Curves.easeInOut
                                              .transform(_lineController.value);
                                          return Align(
                                            alignment: Alignment(0, -1 + 2 * t),
                                            child: Container(
                                              height: 2.5,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 14,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(2),
                                                gradient: LinearGradient(
                                                  colors: [
                                                    scheme.primary.withValues(
                                                      alpha: 0,
                                                    ),
                                                    scheme.primary,
                                                    scheme.primary.withValues(
                                                      alpha: 0,
                                                    ),
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: scheme.primary
                                                        .withValues(
                                                      alpha: 0.55,
                                                    ),
                                                    blurRadius: 12,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fromRect(
                              rect: scanRect,
                              child: IgnorePointer(
                                child: AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, _) {
                                    final wave = (math.sin(
                                              _pulseController.value *
                                                  math.pi *
                                                  2,
                                            ) +
                                            1) /
                                        2;
                                    final a = 0.42 + 0.38 * wave;
                                    return DecoratedBox(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          width: 2.2,
                                          color: scheme.primary.withValues(
                                            alpha: a,
                                          ),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: scheme.primary.withValues(
                                              alpha: 0.22 * a,
                                            ),
                                            blurRadius: 20,
                                            spreadRadius: 1,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            Positioned(
                              left: 28,
                              right: 28,
                              bottom: padding.bottom + 36,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.12,
                                        ),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 18,
                                        vertical: 16,
                                      ),
                                      child: Text(
                                        s.qrScanInstruction,
                                        textAlign: TextAlign.center,
                                        style: Theme.of(ctx)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: Colors.white.withValues(
                                                alpha: 0.92,
                                              ),
                                              height: 1.35,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _QrDimPainter extends CustomPainter {
  _QrDimPainter({required this.cutout, required this.radius});

  final Rect cutout;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final inner = Path()
      ..addRRect(RRect.fromRectXY(cutout, radius, radius));
    final overlay = Path.combine(PathOperation.difference, outer, inner);
    canvas.drawPath(
      overlay,
      Paint()..color = Colors.black.withValues(alpha: 0.52),
    );
  }

  @override
  bool shouldRepaint(covariant _QrDimPainter oldDelegate) {
    return oldDelegate.cutout != cutout || oldDelegate.radius != radius;
  }
}

class _QrResultSheet extends StatelessWidget {
  const _QrResultSheet({
    required this.strings,
    required this.rawValue,
    required this.onScanAgain,
    required this.onClose,
  });

  final AppStrings strings;
  final String rawValue;
  final VoidCallback onScanAgain;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Transform.translate(
          offset: Offset(0, 22 * (1 - t)),
          child: Opacity(opacity: t, child: child),
        );
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          18,
          0,
          18,
          18 + MediaQuery.paddingOf(context).bottom,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Material(
            color: colorScheme.surface,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.qr_code_2_rounded,
                        color: colorScheme.primary,
                        size: 30,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          strings.qrScanRecognized,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    strings.qrScanPhase2Message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    strings.qrScanScannedValueLabel,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.85,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    ),
                    child: SelectableText(
                      rawValue,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: onScanAgain,
                          child: Text(strings.qrScanAgain),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: onClose,
                          child: Text(strings.qrScanClose),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
