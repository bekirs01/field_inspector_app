import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/config/worker_identity.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/demo_task_public_state.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/localization/language_menu_button.dart';
import '../data/assigned_inspection_task_service.dart';
import '../data/demo_task_completion_store.dart';
import '../data/inspector_task_session.dart';
import '../data/task_archive_support.dart';
import 'completed_task_report_screen.dart';
import 'task_detail_screen.dart';
import 'widgets/task_flow_visual.dart';

class _ArchivePageData {
  const _ArchivePageData({required this.load});

  final TaskListLoadResult load;
}

/// Completed / finished assignments for review (worker shell tab).
class WorkerArchiveTabScreen extends StatefulWidget {
  const WorkerArchiveTabScreen({super.key});

  @override
  State<WorkerArchiveTabScreen> createState() => _WorkerArchiveTabScreenState();
}

/// Same count as [TaskListScreen] demo tasks (not exported from that file).
const int _kDemoTaskCount = 3;

class _WorkerArchiveTabScreenState extends State<WorkerArchiveTabScreen> {
  late Future<_ArchivePageData> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _load();
  }

  Future<_ArchivePageData> _load() async {
    final load = await AssignedInspectionTaskService.loadAssignedBundles();
    return _ArchivePageData(load: load);
  }

  void _reload() {
    setState(() {
      _loadFuture = _load();
    });
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
      _kDemoTaskCount,
      (i) => InspectorTaskSession.mock(i, s),
    );
  }

  List<InspectorTaskSession> _archivedSessions({
    required TaskListLoadResult load,
    required AppStrings s,
    required DemoTaskCompletionStore store,
    required bool hasRealTasks,
  }) {
    final out = <InspectorTaskSession>[];
    for (final session in _realSessions(load, s)) {
      if (taskSessionIsArchived(session: session, store: store)) {
        out.add(session);
      }
    }
    final showDemoArchive = kDebugMode &&
        !hasRealTasks &&
        !WorkerIdentity.hasAuthenticatedWorkerSession();
    if (showDemoArchive) {
      for (final session in _demoSessions(s)) {
        if (taskSessionIsArchived(session: session, store: store)) {
          out.add(session);
        }
      }
    }
    out.sort(_compareArchived);
    return out;
  }

  int _compareArchived(InspectorTaskSession a, InspectorTaskSession b) {
    final ta = taskSessionAssignmentCompletedAt(a);
    final tb = taskSessionAssignmentCompletedAt(b);
    if (ta != null && tb != null) return tb.compareTo(ta);
    if (ta != null) return -1;
    if (tb != null) return 1;
    return a.title.toLowerCase().compareTo(b.title.toLowerCase());
  }

  void _openArchived(
    BuildContext context,
    InspectorTaskSession session,
    DemoTaskCompletionStore store,
  ) {
    final snap = store.completedSnapshot(session.storeKey);
    if (snap != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => CompletedTaskReportScreen(session: session),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              TaskDetailScreen(session: session, reviewOnly: true),
        ),
      );
    }
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
                appBar: buildTaskFlowAppBar(
                  context: context,
                  title: Text(
                    s.archiveAppBarTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: s.tasksRetry,
                      onPressed: _reload,
                    ),
                    const LanguageMenuButton(),
                  ],
                ),
                body: FutureBuilder<_ArchivePageData>(
                  future: _loadFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
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
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final load = snapshot.data!.load;
                    final hasRealTasks = load.bundles.isNotEmpty;
                    final archived = _archivedSessions(
                      load: load,
                      s: s,
                      store: store,
                      hasRealTasks: hasRealTasks,
                    );

                    if (archived.isEmpty) {
                      return _ArchiveEmptyState(theme: theme, colorScheme: colorScheme, s: s);
                    }

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
                      children: [
                        Text(
                          s.archiveSectionHeader.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
                            letterSpacing: 1.15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.archiveCountSummary(archived.length),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.88),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        for (final session in archived)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ArchiveTaskCard(
                              session: session,
                              theme: theme,
                              colorScheme: colorScheme,
                              s: s,
                              store: store,
                              onTap: () => _openArchived(context, session, store),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ArchiveEmptyState extends StatelessWidget {
  const _ArchiveEmptyState({
    required this.theme,
    required this.colorScheme,
    required this.s,
  });

  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppStrings s;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Icon(
                Icons.archive_outlined,
                size: 40,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.9),
              ),
            ),
            const SizedBox(height: 22),
            Text(
              s.archiveEmptyTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              s.archiveEmptySubtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchiveTaskCard extends StatelessWidget {
  const _ArchiveTaskCard({
    required this.session,
    required this.theme,
    required this.colorScheme,
    required this.s,
    required this.store,
    required this.onTap,
  });

  final InspectorTaskSession session;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppStrings s;
  final DemoTaskCompletionStore store;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final baseline = session.baselineState();
    final effective = store.effectiveState(
      storeKey: session.storeKey,
      baseline: baseline,
    );
    final snap = store.completedSnapshot(session.storeKey);
    final statusLabel = snap != null
        ? s.taskStateLabel(snap.state)
        : s.taskStateLabel(effective);
    final statusColor = effective == DemoTaskPublicState.completedWithIssues
        ? colorScheme.error
        : colorScheme.primary.withValues(alpha: 0.9);

    final completedAt = taskSessionAssignmentCompletedAt(session);
    final siteLine = session.remoteSiteName?.trim().isNotEmpty == true
        ? session.remoteSiteName!.trim()
        : session.siteAreaLine;
    final zoneLine = session.remoteAreaName?.trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.92),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.32),
                blurRadius: 18,
                offset: const Offset(0, 8),
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
                      label: statusLabel,
                      accent: statusColor,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  siteLine,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                if (zoneLine != null && zoneLine.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '${s.labelZone}: $zoneLine',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.92),
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 16,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${s.archiveLabelFinalStatus}: $statusLabel',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                if (completedAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.event_available_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${s.archiveLabelCompletedOn}: ${s.formatDueDate(completedAt)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                if (session.assignmentDurationMinutes != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 16,
                        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${s.archiveLabelDuration}: ${s.taskDurationMinutesValue(session.assignmentDurationMinutes!)}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.92),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    snap != null ? s.archiveOpenResultHint : s.archiveOpenReviewHint,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary.withValues(alpha: 0.95),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
