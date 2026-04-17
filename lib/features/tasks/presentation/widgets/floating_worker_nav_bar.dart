import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/localization/language_controller.dart';

/// Floating glass capsule — iOS-style bottom navigation for worker home shell.
class FloatingWorkerNavBar extends StatelessWidget {
  const FloatingWorkerNavBar({
    super.key,
    required this.currentIndex,
    required this.onSelect,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = context.languageController;

    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        final s = context.strings;
        return SafeArea(
          minimum: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: colorScheme.surface.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.45),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _NavCell(
                            icon: Icons.fact_check_rounded,
                            label: s.navTabTasks,
                            selected: currentIndex == 0,
                            onTap: () => onSelect(0),
                          ),
                        ),
                        Expanded(
                          child: _NavCell(
                            icon: Icons.edit_note_rounded,
                            label: s.navTabRequest,
                            selected: currentIndex == 1,
                            onTap: () => onSelect(1),
                          ),
                        ),
                        Expanded(
                          child: _NavCell(
                            icon: Icons.person_rounded,
                            label: s.navTabProfile,
                            selected: currentIndex == 2,
                            onTap: () => onSelect(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fg = selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.82);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? colorScheme.primary.withValues(alpha: 0.14)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: fg),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
