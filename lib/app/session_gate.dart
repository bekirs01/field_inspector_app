import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/worker_profile_service.dart';
import '../core/localization/language_controller.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/worker_profile_required_screen.dart';
import '../features/tasks/presentation/task_list_screen.dart';

/// Routes: login → (email session) → verify `profiles` row → task list.
class SessionGate extends StatefulWidget {
  const SessionGate({super.key});

  @override
  State<SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<SessionGate> {
  Session? _session;
  StreamSubscription<AuthState>? _sub;
  String? _profileGateUid;
  Future<WorkerProfile?>? _profileResolution;

  @override
  void initState() {
    super.initState();
    _session = Supabase.instance.client.auth.currentSession;
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      setState(() {
        _session = data.session;
        _profileGateUid = null;
        _profileResolution = null;
      });
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _session?.user;
    final uid = user?.id;
    final hasUid = uid != null && uid.isNotEmpty;
    final isAnonymous = user?.isAnonymous ?? true;
    final useWorkerHome = hasUid && !isAnonymous;

    if (!useWorkerHome) {
      _profileGateUid = null;
      _profileResolution = null;
      return const LoginScreen();
    }

    final workerUid = uid;
    if (_profileGateUid != workerUid) {
      _profileGateUid = workerUid;
      _profileResolution =
          WorkerProfileService.fetchProfileForUserId(workerUid);
    }

    final lang = context.languageController;

    return FutureBuilder<WorkerProfile?>(
      future: _profileResolution,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return ListenableBuilder(
            listenable: lang,
            builder: (context, _) {
              final s = context.strings;
              final theme = Theme.of(context);
              final colorScheme = theme.colorScheme;
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          s.authLoadingWorkerProfile,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        final profile = snapshot.data;
        if (profile == null) {
          return const WorkerProfileRequiredScreen();
        }
        return const TaskListScreen();
      },
    );
  }
}
