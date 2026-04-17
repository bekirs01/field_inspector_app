import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/localization/language_controller.dart';
import '../../../core/localization/language_menu_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/subtle_snowfall_background.dart';

/// Shown when the user signed in with email/password but `public.profiles`
/// has no row for [auth.currentUser.id].
class WorkerProfileRequiredScreen extends StatelessWidget {
  const WorkerProfileRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final parent = Theme.of(context);
    final lang = context.languageController;

    final darkScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: kAppAccentBlue,
      onPrimary: Colors.white,
      surface: kAppSurface,
      onSurface: const Color(0xFFF6F8FA),
      onSurfaceVariant: const Color(0xFF8B949E),
      error: const Color(0xFFF85149),
      onError: Colors.white,
    );

    final theme = parent.copyWith(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: darkScheme,
      textTheme: parent.textTheme.apply(
        bodyColor: darkScheme.onSurface,
        displayColor: darkScheme.onSurface,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          backgroundColor: kAppAccentBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );

    return Theme(
      data: theme,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
          systemNavigationBarColor: kAppCanvas,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: kAppCanvas,
          body: Stack(
            fit: StackFit.expand,
            children: [
              const Positioned.fill(
                child: SubtleSnowfallBackground(
                  flakeCount: 70,
                  intensity: 0.9,
                ),
              ),
              SafeArea(
                child: ListenableBuilder(
                  listenable: lang,
                  builder: (context, _) {
                    final s = context.strings;
                    final t = Theme.of(context);
                    final cs = t.colorScheme;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
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
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                              child: Container(
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: kAppSurface.withValues(alpha: 0.75),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.workerProfileRequiredTitle,
                                      style: t.textTheme.headlineSmall?.copyWith(
                                        color: cs.onSurface,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      s.workerProfileRequiredMessage,
                                      style: t.textTheme.bodyLarge?.copyWith(
                                        color: cs.onSurfaceVariant,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
