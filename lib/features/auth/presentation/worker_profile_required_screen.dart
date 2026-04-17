import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/localization/language_controller.dart';
import '../../../core/localization/language_menu_button.dart';

/// Shown when the user signed in with email/password but `public.profiles`
/// has no row for [auth.currentUser.id].
class WorkerProfileRequiredScreen extends StatelessWidget {
  const WorkerProfileRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = context.languageController;

    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        final s = context.strings;
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      LanguageMenuButton(),
                    ],
                  ),
                  const Spacer(flex: 2),
                  Text(
                    s.workerProfileRequiredTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.workerProfileRequiredMessage,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(flex: 3),
                  FilledButton(
                    onPressed: () {
                      Supabase.instance.client.auth.signOut();
                    },
                    child: Text(s.authSignOutButton),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
