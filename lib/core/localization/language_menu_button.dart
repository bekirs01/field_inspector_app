import 'package:flutter/material.dart';

import 'app_language.dart';
import 'language_controller.dart';

class LanguageMenuButton extends StatelessWidget {
  const LanguageMenuButton({
    super.key,
    this.showLabel = true,
  });

  /// When false, shows a compact control (e.g. on Profile next to a [ListTile] title).
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final controller = context.languageController;
    final s = context.strings;
    final primary = Theme.of(context).colorScheme.primary;

    return PopupMenuButton<AppLanguage>(
      tooltip: s.languageMenuLabel,
      onSelected: controller.setLanguage,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: AppLanguage.ru,
          child: Text(s.langNameRu),
        ),
        PopupMenuItem(
          value: AppLanguage.tr,
          child: Text(s.langNameTr),
        ),
        PopupMenuItem(
          value: AppLanguage.en,
          child: Text(s.langNameEn),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: showLabel
            ? Text(
                s.languageMenuLabel,
                style: TextStyle(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              )
            : Icon(
                Icons.language_rounded,
                color: primary,
                size: 24,
              ),
      ),
    );
  }
}
