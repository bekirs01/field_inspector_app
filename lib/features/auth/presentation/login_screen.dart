import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_env.dart';
import '../../../core/config/worker_identity.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/localization/language_menu_button.dart';
import '../../../core/theme/app_theme.dart';
import '../../tasks/presentation/worker_main_shell.dart';

ThemeData _loginTheme(ThemeData parent) {
  final scheme = parent.colorScheme;

  return parent.copyWith(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    textTheme: parent.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kAppSurfaceHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      hintStyle: TextStyle(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
      ),
      labelStyle: TextStyle(
        color: scheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: TextStyle(
        color: kAppAccentBlue.withValues(alpha: 0.95),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(
          color: kAppAccentBlue.withValues(alpha: 0.65),
          width: 1.5,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
        shadowColor: kAppAccentBlue.withValues(alpha: 0.45),
        backgroundColor: kAppAccentBlue,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(50),
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
  );
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authSub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) setState(() {});
  }

  Future<void> _signIn(BuildContext context) async {
    final s = context.strings;
    final messenger = ScaffoldMessenger.of(context);
    final email = _email.text.trim();
    if (email.isEmpty || _password.text.isEmpty) {
      messenger.showSnackBar(SnackBar(content: Text(s.authFillEmailPassword)));
      return;
    }
    setState(() => _busy = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: _password.text,
      );
      if (!mounted) return;
      _password.clear();
    } on AuthException {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(s.authSignInFailed)));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(s.authSignInFailed)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openDevBypass(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => const WorkerMainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentTheme = Theme.of(context);
    final lang = context.languageController;
    final showDevBypass =
        kDebugMode && AppEnv.devWorkerUserId.trim().isNotEmpty;

    return Theme(
      data: _loginTheme(parentTheme),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;

          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: kAppCanvas,
              systemNavigationBarIconBrightness: Brightness.light,
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: ListenableBuilder(
                  listenable: lang,
                  builder: (context, _) {
                    final s = context.strings;
                    final anon = WorkerIdentity.hasAnonymousSession();

                    return SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: const [
                                  LanguageMenuButton(),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Center(
                                child: Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(18),
                                    color: kAppSurface,
                                    border: Border.all(
                                      color: kAppAccentBlue.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: kAppAccentBlue.withValues(
                                          alpha: 0.22,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.precision_manufacturing_rounded,
                                    size: 38,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                s.loginTitle,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                s.loginSubtitle,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 28),
                              if (anon) ...[
                                Container(
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer
                                        .withValues(alpha: 0.55),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: colorScheme.error
                                          .withValues(alpha: 0.45),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        s.authAnonymousNotWorkerWarning,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: colorScheme.onErrorContainer,
                                          height: 1.35,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      OutlinedButton(
                                        onPressed: _busy ? null : _signOut,
                                        child: Text(s.authSignOutButton),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                              ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 14,
                                    sigmaY: 14,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: kAppSurface.withValues(
                                        alpha: 0.72,
                                      ),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.35,
                                          ),
                                          blurRadius: 28,
                                          offset: const Offset(0, 14),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.fromLTRB(
                                      20,
                                      22,
                                      20,
                                      22,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          s.authSignInButton,
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        TextField(
                                          controller: _email,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.email,
                                          ],
                                          style: TextStyle(
                                            color: colorScheme.onSurface,
                                          ),
                                          cursorColor: kAppAccentBlue,
                                          decoration: InputDecoration(
                                            labelText: s.authLabelEmail,
                                            hintText: s.authHintEmail,
                                          ),
                                        ),
                                        const SizedBox(height: 14),
                                        TextField(
                                          controller: _password,
                                          obscureText: true,
                                          textInputAction: TextInputAction.done,
                                          onSubmitted: (_) =>
                                              _signIn(context),
                                          autofillHints: const [
                                            AutofillHints.password,
                                          ],
                                          style: TextStyle(
                                            color: colorScheme.onSurface,
                                          ),
                                          cursorColor: kAppAccentBlue,
                                          decoration: InputDecoration(
                                            labelText: s.authLabelPassword,
                                            hintText: s.authHintPassword,
                                          ),
                                        ),
                                        const SizedBox(height: 22),
                                        DecoratedBox(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(28),
                                            boxShadow: [
                                              BoxShadow(
                                                color: kAppAccentBlue.withValues(
                                                  alpha: 0.35,
                                                ),
                                                blurRadius: 18,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: FilledButton(
                                            onPressed: _busy
                                                ? null
                                                : () => _signIn(context),
                                            child: _busy
                                                ? const SizedBox(
                                                    height: 22,
                                                    width: 22,
                                                    child:
                                                        CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                                  )
                                                : Text(s.authSignInButton),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                s.loginDescription,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                s.loginDevPathWithoutSession,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.85),
                                  height: 1.4,
                                ),
                              ),
                              if (showDevBypass) ...[
                                const SizedBox(height: 20),
                                OutlinedButton(
                                  onPressed: _busy
                                      ? null
                                      : () => _openDevBypass(context),
                                  child: Text(s.loginDevBypassButton),
                                ),
                              ],
                              const SizedBox(height: 28),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
            ),
          );
        },
      ),
    );
  }
}
