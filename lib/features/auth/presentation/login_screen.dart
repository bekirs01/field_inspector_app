import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_env.dart';
import '../../../core/config/worker_identity.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/localization/language_menu_button.dart';
import '../../tasks/presentation/task_list_screen.dart';

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
      MaterialPageRoute<void>(builder: (context) => const TaskListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = context.languageController;
    final showDevBypass =
        kDebugMode && AppEnv.devWorkerUserId.trim().isNotEmpty;

    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        final s = context.strings;
        final anon = WorkerIdentity.hasAnonymousSession();

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [LanguageMenuButton()],
                  ),
                  const SizedBox(height: 8),
                  if (anon) ...[
                    Card(
                      color: colorScheme.errorContainer,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              s.authAnonymousNotWorkerWarning,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onErrorContainer,
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
                    ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    s.loginTitle,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.loginSubtitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    s.loginDescription,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    s.loginDevPathWithoutSession,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                      labelText: s.authLabelEmail,
                      hintText: s.authHintEmail,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _signIn(context),
                    autofillHints: const [AutofillHints.password],
                    decoration: InputDecoration(
                      labelText: s.authLabelPassword,
                      hintText: s.authHintPassword,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _busy ? null : () => _signIn(context),
                    child: _busy
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(s.authSignInButton),
                  ),
                  if (showDevBypass) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _busy ? null : () => _openDevBypass(context),
                      child: Text(s.loginDevBypassButton),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
