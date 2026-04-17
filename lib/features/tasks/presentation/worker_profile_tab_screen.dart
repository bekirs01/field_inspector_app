import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/worker_identity.dart';
import '../../../core/config/worker_profile_service.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/localization/language_menu_button.dart';
import 'widgets/task_flow_visual.dart';

/// Minimal profile tab: real worker data, language, sign-out.
class WorkerProfileTabScreen extends StatefulWidget {
  const WorkerProfileTabScreen({super.key});

  @override
  State<WorkerProfileTabScreen> createState() => _WorkerProfileTabScreenState();
}

class _WorkerProfileTabScreenState extends State<WorkerProfileTabScreen> {
  late Future<WorkerProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = WorkerProfileService.fetchCurrentProfile();
  }

  void _reload() {
    setState(() {
      _profileFuture = WorkerProfileService.fetchCurrentProfile();
    });
  }

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
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: buildTaskFlowAppBar(
            context: context,
            title: Text(s.profileScreenTitle),
          ),
          body: FutureBuilder<WorkerProfile?>(
            future: _profileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colorScheme.primary,
                    ),
                  ),
                );
              }
              final p = snapshot.data;
              final workerId = WorkerIdentity.resolveWorkerUserId();

              return ListView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p != null) ...[
                            Text(
                              s.workerProfileNameLabel,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              p.displayName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (p.displayCodeOrUsername.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              Text(
                                s.workerProfileCodeLabel,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 4),
                              SelectableText(
                                p.displayCodeOrUsername,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ] else ...[
                            Text(
                              workerId == null
                                  ? s.tasksNoWorkerIdentity
                                  : s.workerProfileNotInDatabase,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                            if (workerId != null) ...[
                              const SizedBox(height: 10),
                              SelectableText(
                                workerId,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              s.languageMenuLabel,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          const LanguageMenuButton(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                    },
                    icon: const Icon(Icons.logout_rounded),
                    label: Text(s.authSignOutButton),
                  ),
                  TextButton(
                    onPressed: _reload,
                    child: Text(s.tasksRetry),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
