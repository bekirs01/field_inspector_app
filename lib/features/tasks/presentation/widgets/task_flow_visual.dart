import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/subtle_snowfall_background.dart';

/// Task list / detail use the global dark theme; this only ensures no drift.
ThemeData taskFlowScreenTheme(ThemeData parent) => parent;

/// Solid app bar — no gradient or blur (avoids blue “wash” at the top).
PreferredSizeWidget buildTaskFlowAppBar({
  required BuildContext context,
  required Widget title,
  List<Widget> actions = const [],
}) {
  final scheme = Theme.of(context).colorScheme;
  return AppBar(
    title: title,
    actions: actions,
    backgroundColor: kAppCanvas,
    foregroundColor: scheme.onSurface,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );
}

/// Particle layer + child. Same stable canvas color as cards (no gradient).
class TaskFlowSnowStack extends StatelessWidget {
  const TaskFlowSnowStack({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const Positioned.fill(
          child: SubtleSnowfallBackground(
            flakeCount: 64,
            intensity: 0.88,
          ),
        ),
        child,
      ],
    );
  }
}

/// Soft status pill for task cards / hero summary.
class TaskFlowStatusPill extends StatelessWidget {
  const TaskFlowStatusPill({
    super.key,
    required this.label,
    required this.accent,
  });

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final muted = Color.lerp(accent, Colors.white, 0.35)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.38)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: muted,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.15,
            ),
      ),
    );
  }
}
