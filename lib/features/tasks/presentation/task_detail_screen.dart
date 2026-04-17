import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/demo_task_public_state.dart';
import '../../../core/localization/language_controller.dart';
import '../../inspection/presentation/inspection_route_screen.dart';
import '../data/demo_task_completion_store.dart';
import '../data/inspector_task_session.dart';
import 'completed_task_report_screen.dart';
import 'widgets/task_flow_visual.dart';

class TaskDetailScreen extends StatelessWidget {
  const TaskDetailScreen({
    super.key,
    required this.session,
    this.reviewOnly = false,
  });

  final InspectorTaskSession session;

  /// When true (e.g. opened from Archive without a local result snapshot),
  /// never offers "Start round" — review / view result only.
  final bool reviewOnly;

  void _onStartInspection(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => InspectionRouteScreen(session: session),
      ),
    );
  }

  void _onOpenResult(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CompletedTaskReportScreen(session: session),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final store = DemoTaskCompletionStore.instance;
    final lang = context.languageController;
    final baseline = session.baselineState();

    return ListenableBuilder(
      listenable: Listenable.merge([store, lang]),
      builder: (context, _) {
        final s = context.strings;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
              final done = store.completedSnapshot(session.storeKey);
              final effective = store.effectiveState(
                storeKey: session.storeKey,
                baseline: baseline,
              );
              final statusLabel = done != null
                  ? s.taskStateLabel(done.state)
                  : s.taskStateLabel(effective);
              final statusColorResolved = (done?.state ==
                          DemoTaskPublicState.completedWithIssues ||
                      effective == DemoTaskPublicState.completedWithIssues)
                  ? colorScheme.error
                  : colorScheme.primary;

              final instructionsTrimmed = session.instructions?.trim() ?? '';
              final hasInstructions = instructionsTrimmed.isNotEmpty;

              return Scaffold(
                backgroundColor: theme.scaffoldBackgroundColor,
                appBar: buildTaskFlowAppBar(
                  context: context,
                  title: Text(
                    s.taskDetailAppTitle,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                body: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                        children: [
                            _HeroSummaryCard(
                              session: session,
                              theme: theme,
                              colorScheme: colorScheme,
                              s: s,
                              statusLabel: statusLabel,
                              statusColor: statusColorResolved,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              s.sectionTaskInstructions.toUpperCase(),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.9),
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Card(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: hasInstructions ? 16 : 14,
                                ),
                                child: hasInstructions
                                    ? Text(
                                        instructionsTrimmed,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                          color: colorScheme.onSurface,
                                          height: 1.45,
                                        ),
                                      )
                                    : Text(
                                        s.taskDetailInstructionsEmpty,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                          height: 1.45,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                              ),
                            ),
                            if (done != null) ...[
                              const SizedBox(height: 20),
                              Text(
                                s.taskDetailSectionOutcome.toUpperCase(),
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: colorScheme.onSurfaceVariant
                                      .withValues(alpha: 0.9),
                                  letterSpacing: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Card(
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _OutcomeRow(
                                        label: s.labelSummaryTotalObjects,
                                        value: '${done.totalObjects}',
                                        theme: theme,
                                        colorScheme: colorScheme,
                                      ),
                                      const SizedBox(height: 10),
                                      _OutcomeRow(
                                        label: s.labelSummaryCompletedOk,
                                        value: '${done.completedOkCount}',
                                        theme: theme,
                                        colorScheme: colorScheme,
                                      ),
                                      const SizedBox(height: 10),
                                      _OutcomeRow(
                                        label: s.labelSummaryWithIssues,
                                        value: '${done.issueObjectCount}',
                                        theme: theme,
                                        colorScheme: colorScheme,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Text(
                              s.sectionInspectionRoute.toUpperCase(),
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.9),
                                letterSpacing: 1.1,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            for (var i = 0; i < session.items.length; i++)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: _RouteItemTile(
                                  index: i + 1,
                                  item: session.items[i],
                                  theme: theme,
                                  colorScheme: colorScheme,
                                  s: s,
                                  done: done,
                                  itemIndex: i,
                                ),
                              ),
                          ],
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 10),
                      child: SafeArea(
                        top: false,
                        child: _PrimaryActionBlock(
                          colorScheme: colorScheme,
                          child: _buildPrimaryAction(
                            context: context,
                            s: s,
                            theme: theme,
                            colorScheme: colorScheme,
                            done: done,
                            effective: effective,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }

  Widget _buildPrimaryAction({
    required BuildContext context,
    required AppStrings s,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required CompletedTaskDemoSnapshot? done,
    required DemoTaskPublicState effective,
  }) {
    if (reviewOnly) {
      if (done != null) {
        return FilledButton(
          onPressed: () => _onOpenResult(context),
          child: Text(s.taskOpenResultButton),
        );
      }
      if (effective == DemoTaskPublicState.completed ||
          effective == DemoTaskPublicState.completedWithIssues) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            s.archiveReviewNoLocalSnapshot,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          s.archiveReviewNoLocalSnapshot,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      );
    }

    if (done != null) {
      return FilledButton(
        onPressed: () => _onOpenResult(context),
        child: Text(s.taskOpenResultButton),
      );
    }
    return FilledButton(
      onPressed: () => _onStartInspection(context),
      child: Text(s.startRoundButton),
    );
  }
}

class _PrimaryActionBlock extends StatelessWidget {
  const _PrimaryActionBlock({
    required this.child,
    required this.colorScheme,
  });

  final Widget child;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(width: double.infinity, child: child),
    );
  }
}

class _HeroSummaryCard extends StatelessWidget {
  const _HeroSummaryCard({
    required this.session,
    required this.theme,
    required this.colorScheme,
    required this.s,
    required this.statusLabel,
    required this.statusColor,
  });

  final InspectorTaskSession session;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppStrings s;
  final String statusLabel;
  final Color statusColor;

  String _locationLine() {
    if (session.isRemote) {
      final site = session.remoteSiteName?.trim() ?? '';
      final area = session.remoteAreaName?.trim() ?? '';
      if (site.isNotEmpty && area.isNotEmpty) return '$site · $area';
      if (site.isNotEmpty) return site;
      if (area.isNotEmpty) return area;
    }
    return session.siteAreaLine;
  }

  @override
  Widget build(BuildContext context) {
    final assignRaw = session.assignmentExecutionStatusRaw;
    final hasAssign = session.isRemote &&
        assignRaw != null &&
        assignRaw.isNotEmpty;
    final assignState = hasAssign
        ? demoStateFromAssignmentExecution(assignRaw)
        : null;
    final assignLabel = assignState != null ? s.taskStateLabel(assignState) : null;
    final assignChipColor = assignState == DemoTaskPublicState.completedWithIssues
        ? colorScheme.error
        : colorScheme.secondary;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: colorScheme.surfaceContainerHighest,
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.38),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            session.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.35,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _locationLine(),
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.92),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TaskFlowStatusPill(label: statusLabel, accent: statusColor),
              if (assignLabel != null)
                TaskFlowStatusPill(
                  label: assignLabel,
                  accent: assignChipColor,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 18,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  session.shiftOrDueLine,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (session.isRemote && session.assignmentDurationMinutes != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  s.taskDurationMinutesValue(session.assignmentDurationMinutes!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _RouteItemTile extends StatelessWidget {
  const _RouteItemTile({
    required this.index,
    required this.item,
    required this.theme,
    required this.colorScheme,
    required this.s,
    required this.done,
    required this.itemIndex,
  });

  final int index;
  final InspectorRouteItemRow item;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final AppStrings s;
  final CompletedTaskDemoSnapshot? done;
  final int itemIndex;

  @override
  Widget build(BuildContext context) {
    final snapshot = done;
    final issueLabel = snapshot != null &&
            itemIndex < snapshot.itemHasIssue.length
        ? (snapshot.itemHasIssue[itemIndex]
            ? s.routeStatusHasIssue
            : s.statusCompleted)
        : null;
    final issueColor = snapshot != null &&
            itemIndex < snapshot.itemHasIssue.length
        ? (snapshot.itemHasIssue[itemIndex]
            ? colorScheme.error
            : colorScheme.primary)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.14),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.28),
                ),
              ),
              child: Text(
                '$index',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.equipmentName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ),
                      if (issueLabel != null && issueColor != null) ...[
                        const SizedBox(width: 8),
                        TaskFlowStatusPill(
                          label: issueLabel,
                          accent: issueColor,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.equipmentLocation,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                  if (item.equipmentCode.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      s.labelEquipmentCode,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.equipmentCode,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OutcomeRow extends StatelessWidget {
  const _OutcomeRow({
    required this.label,
    required this.value,
    required this.theme,
    required this.colorScheme,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
