import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/worker_identity.dart';
import '../../../core/config/worker_profile_service.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/demo_task_public_state.dart';
import '../../../core/localization/language_controller.dart';
import '../../inspection/data/remote_send_availability.dart';
import '../data/assigned_inspection_task_service.dart';
import '../data/demo_task_completion_store.dart';
import '../data/inspector_task_session.dart';
import '../data/task_archive_support.dart';
import 'task_detail_screen.dart';
import 'widgets/task_flow_visual.dart';

Widget _maybeSnow({required bool embed, required Widget child}) {
  if (embed) return child;
  return TaskFlowSnowStack(child: child);
}

class _TaskListPageData {
  const _TaskListPageData({
    required this.load,
    this.profile,
  });

  final TaskListLoadResult load;
  final WorkerProfile? profile;
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({
    super.key,
    this.embedInMainShell = false,
  });

  /// When true, particles + request/logout live on [WorkerMainShell] / profile tab.
  final bool embedInMainShell;

  static const _mockCount = 3;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<_TaskListPageData> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadPage();
  }

  Future<_TaskListPageData> _loadPage() async {
    final load = await AssignedInspectionTaskService.loadAssignedBundles();
    final profile = await WorkerProfileService.fetchCurrentProfile();
    unawaited(flushPendingInspectionSubmissions());
    return _TaskListPageData(load: load, profile: profile);
  }

  Future<void> _reload() async {
    final f = _loadPage();
    setState(() {
      _loadFuture = f;
    });
    await f;
  }

  List<InspectorTaskSession> _realSessions(TaskListLoadResult load, AppStrings s) {
    return load.bundles
        .map(
          (b) => InspectorTaskSession.fromRemoteTask(
            assignmentRow: b.assignmentRow,
            taskRow: b.taskRow,
            itemRows: b.itemRows,
            s: s,
          ),
        )
        .toList();
  }

  List<InspectorTaskSession> _demoSessions(AppStrings s) {
    return List<InspectorTaskSession>.generate(
      TaskListScreen._mockCount,
      (i) => InspectorTaskSession.mock(i, s),
    );
  }

  String? _errorLine(AppStrings s, TaskListLoadError? e) {
    if (e == null) return null;
    switch (e) {
      case TaskListLoadError.noWorkerIdentity:
        return s.tasksNoWorkerIdentity;
      case TaskListLoadError.supabaseNotReady:
        return s.tasksSupabaseNotReady;
      case TaskListLoadError.fetchFailed:
        return s.tasksLoadFailed;
    }
  }

  Widget _taskListLoadedContent({
    required AsyncSnapshot<_TaskListPageData> snapshot,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required DemoTaskCompletionStore store,
    required AppStrings sNow,
  }) {
    final page = snapshot.data!;
    final load = page.load;
    final profile = page.profile;
    final realSessions = _realSessions(load, sNow);
    final hasRealTasks = realSessions.isNotEmpty;
    final err = load.error;
    final remoteSucceeded = err == null;
    final showError = err != null;
    final showEmptyAssigned = remoteSucceeded && !hasRealTasks;
    final showDemoSection = kDebugMode &&
        !hasRealTasks &&
        !WorkerIdentity.hasAuthenticatedWorkerSession();

    final errLine = _errorLine(sNow, err);

    final children = <Widget>[
      _WorkerContextCard(
        s: sNow,
        theme: theme,
        colorScheme: colorScheme,
        profile: profile,
      ),
    ];

    if (showError && errLine != null) {
      children.addAll([
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  errLine,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.error,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    unawaited(_reload());
                  },
                  child: Text(sNow.tasksRetry),
                ),
              ],
            ),
          ),
        ),
      ]);
    }

    if (hasRealTasks) {
      final activeReal = realSessions
          .where(
            (session) => !taskSessionIsArchived(
              session: session,
              store: store,
            ),
          )
          .toList();
      children.addAll([
        const SizedBox(height: 20),
        _SectionHeader(text: sNow.tasksSectionAssignedRounds),
        const SizedBox(height: 12),
        if (activeReal.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 22,
              ),
              child: Text(
                sNow.tasksAllCompletedSeeArchive,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
          )
        else
          ...activeReal.map(
            (session) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _TaskListCard(
                session: session,
                theme: theme,
                colorScheme: colorScheme,
                s: sNow,
                store: store,
              ),
            ),
          ),
      ]);
    }

    if (showEmptyAssigned) {
      children.addAll([
        const SizedBox(height: 20),
        _SectionHeader(text: sNow.tasksSectionAssignedRounds),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 26,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.task_alt_rounded,
                    size: 28,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sNow.tasksNoAssignments,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ]);
    }

    if (showDemoSection) {
      final demoSessions = _demoSessions(sNow)
          .where(
            (session) => !taskSessionIsArchived(
              session: session,
              store: store,
            ),
          )
          .toList();
      children.addAll([
        const SizedBox(height: 28),
        Divider(
          height: 1,
          color: colorScheme.outlineVariant,
        ),
        const SizedBox(height: 24),
        _SectionHeader(text: sNow.tasksSectionDemoTasks),
        const SizedBox(height: 6),
        Text(
          sNow.tasksDemoSectionDebugHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        ...demoSessions.map(
          (session) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _TaskListCard(
              session: session,
              theme: theme,
              colorScheme: colorScheme,
              s: sNow,
              store: store,
            ),
          ),
        ),
      ]);
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
      children: children,
    );
  }

  @override
  Widget build(BuildContext context) {
    final parentTheme = Theme.of(context);
    final store = DemoTaskCompletionStore.instance;
    final lang = context.languageController;

    return ListenableBuilder(
      listenable: Listenable.merge([lang, store]),
      builder: (context, _) {
        final s = context.strings;
        return Theme(
          data: taskFlowScreenTheme(parentTheme),
          child: Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final colorScheme = theme.colorScheme;
              return Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                appBar: widget.embedInMainShell
                    ? null
                    : buildTaskFlowAppBar(
                        context: context,
                        title: Text(
                          s.tasksAppTitle,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.refresh_rounded),
                            tooltip: s.tasksRetry,
                            onPressed: () {
                              unawaited(_reload());
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout_rounded),
                            tooltip: s.tasksAppBarSignOut,
                            onPressed: () async {
                              await Supabase.instance.client.auth.signOut();
                            },
                          ),
                        ],
                      ),
                body: _maybeSnow(
                  embed: widget.embedInMainShell,
                  child: widget.embedInMainShell
                      ? AnnotatedRegion<SystemUiOverlayStyle>(
                          value: SystemUiOverlayStyle.light,
                          child: SafeArea(
                            bottom: false,
                            child: FutureBuilder<_TaskListPageData>(
                              future: _loadFuture,
                              builder: (context, snapshot) {
                                Widget content;
                                if (snapshot.connectionState !=
                                    ConnectionState.done) {
                                  content = LayoutBuilder(
                                    builder: (context, constraints) {
                                      return SingleChildScrollView(
                                        physics:
                                            const AlwaysScrollableScrollPhysics(),
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight: constraints.maxHeight,
                                          ),
                                          child: Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 36,
                                                  height: 36,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.5,
                                                    color: colorScheme.primary,
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                Text(
                                                  s.tasksLoading,
                                                  style: theme
                                                      .textTheme.bodyLarge
                                                      ?.copyWith(
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  content = _taskListLoadedContent(
                                    snapshot: snapshot,
                                    theme: theme,
                                    colorScheme: colorScheme,
                                    store: store,
                                    sNow: context.strings,
                                  );
                                }
                                return RefreshIndicator(
                                  onRefresh: _reload,
                                  child: content,
                                );
                              },
                            ),
                          ),
                        )
                      : FutureBuilder<_TaskListPageData>(
                          future: _loadFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState !=
                                ConnectionState.done) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      s.tasksLoading,
                                      style: theme.textTheme.bodyLarge
                                          ?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return _taskListLoadedContent(
                              snapshot: snapshot,
                              theme: theme,
                              colorScheme: colorScheme,
                              store: store,
                              sNow: context.strings,
                            );
                          },
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

String _workerMonogram(WorkerProfile? profile) {
  if (profile == null) return '?';
  final n = profile.displayName.trim();
  if (n.isEmpty) return '?';
  final parts = n.split(RegExp(r'\s+'));
  if (parts.length >= 2 &&
      parts[0].isNotEmpty &&
      parts[1].isNotEmpty) {
    final a = parts[0];
    final b = parts[1];
    return '${a[0]}${b[0]}'.toUpperCase();
  }
  return n[0].toUpperCase();
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Text(
      text.toUpperCase(),
      style: theme.textTheme.labelLarge?.copyWith(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
        letterSpacing: 1.15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _WorkerContextCard extends StatelessWidget {
  const _WorkerContextCard({
    required this.s,
    required this.theme,
    required this.colorScheme,
    required this.profile,
  });

  final AppStrings s;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final WorkerProfile? profile;

  @override
  Widget build(BuildContext context) {
    final workerId = WorkerIdentity.resolveWorkerUserId();
    final devMode = WorkerIdentity.isDevWorkerUserIdActive();
    final p = profile;
    final authMissingProfile =
        WorkerIdentity.hasAuthenticatedWorkerSession();

    final inner = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.workerSectionTitle.toUpperCase(),
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.88),
            letterSpacing: 1.1,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (devMode) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.tertiary.withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              s.workerDevWorkerIdBadge,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.tertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        if (workerId == null) ...[
          const SizedBox(height: 12),
          Text(
            s.tasksNoWorkerIdentity,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ] else if (p != null) ...[
          const SizedBox(height: 14),
          Text(
            s.workerProfileNameLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            p.displayName,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          if (p.username.trim().isNotEmpty &&
              p.fullName.trim().isNotEmpty &&
              p.username.trim().toLowerCase() !=
                  p.fullName.trim().toLowerCase()) ...[
            const SizedBox(height: 8),
            Text(
              p.username.trim(),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.82),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ] else ...[
          const SizedBox(height: 12),
          Text(
            authMissingProfile
                ? s.workerProfileMissingAuthenticated
                : s.workerProfileNotInDatabase,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: authMissingProfile
                  ? colorScheme.error
                  : colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            workerId,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ],
    );

    final monogram = _workerMonogram(p);
    final avatarBg = Color.lerp(
      colorScheme.primary,
      colorScheme.surface,
      0.72,
    )!;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarBg,
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.35),
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Text(
                monogram,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(child: inner),
          ],
        ),
    );
  }
}

class _TaskListCard extends StatelessWidget {
  const _TaskListCard({
    required this.session,
    required this.theme,
    required this.colorScheme,
    required this.s,
    required this.store,
  });

  final InspectorTaskSession session;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppStrings s;
  final DemoTaskCompletionStore store;

  @override
  Widget build(BuildContext context) {
    final routeTotal = session.routeItemCount;
    final baseline = session.baselineState();

    final effective = store.effectiveState(
      storeKey: session.storeKey,
      baseline: baseline,
    );
    final done = store.completedSnapshot(session.storeKey);
    final statusColor = effective == DemoTaskPublicState.completedWithIssues
        ? colorScheme.error
        : colorScheme.primary;

    final statusText = done != null
        ? s.taskStateLabel(done.state)
        : s.taskStateLabel(effective);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (context) => TaskDetailScreen(session: session),
            ),
          );
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.07),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        session.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TaskFlowStatusPill(
                      label: statusText,
                      accent: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  session.siteAreaLine,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        session.shiftOrDueLine,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.92,
                          ),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.alt_route_rounded,
                      size: 16,
                      color: colorScheme.primary.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        s.taskListProgressLine(
                          state: effective,
                          routeTotal: routeTotal,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
