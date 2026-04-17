import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../../core/util/mock_uuid.dart';
import '../../../core/localization/language_controller.dart';
import '../../tasks/data/assigned_inspection_task_service.dart';
import '../../tasks/data/demo_task_completion_store.dart';
import '../../tasks/data/inspector_task_session.dart';
import '../../tasks/presentation/widgets/task_flow_visual.dart';
import '../data/pending_inspection_store.dart';
import '../data/remote_send_availability.dart';
import 'inspection_object_screen.dart';
import 'inspection_task_summary_screen.dart';

enum _RouteSlotState { pending, completed, completedWithIssue }

class InspectionRouteScreen extends StatefulWidget {
  const InspectionRouteScreen({super.key, required this.session});

  final InspectorTaskSession session;

  @override
  State<InspectionRouteScreen> createState() => _InspectionRouteScreenState();
}

class _InspectionRouteScreenState extends State<InspectionRouteScreen>
    with WidgetsBindingObserver {
  late List<_RouteSlotState> _slotStates;
  late List<int> _photosPerSlot;
  late List<int> _audioPerSlot;
  late List<bool> _slotAwaitingRemoteSync;
  int _photosRunningTotal = 0;
  int _audioRunningTotal = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final key = widget.session.storeKey;
    DemoTaskCompletionStore.instance.markRouteStarted(key);
    unawaited(
      AssignedInspectionTaskService.markAssignmentStarted(
        assignmentId: widget.session.remoteAssignmentId,
        remoteTaskId: widget.session.remoteTaskId,
      ),
    );
    final n = widget.session.routeItemCount;
    _slotStates = List<_RouteSlotState>.filled(
      n,
      _RouteSlotState.pending,
    );
    _photosPerSlot = List<int>.filled(n, 0);
    _audioPerSlot = List<int>.filled(n, 0);
    _slotAwaitingRemoteSync = List<bool>.filled(n, false);
    unawaited(flushPendingInspectionSubmissions());
    unawaited(_refreshAwaitingSyncFromStore());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(flushPendingInspectionSubmissions());
      unawaited(_refreshAwaitingSyncFromStore());
    }
  }

  String _taskIdForPendingMatch() {
    final sess = widget.session;
    if (sess.isRemote && (sess.remoteTaskId ?? '').isNotEmpty) {
      return sess.remoteTaskId!;
    }
    final m = sess.mockTaskIndex ?? 0;
    return mockUuidFromSeed('task|$m');
  }

  Future<void> _refreshAwaitingSyncFromStore() async {
    final records = await PendingInspectionStore.instance.loadAll();
    final taskId = _taskIdForPendingMatch();
    if (!mounted) return;
    final next = List<bool>.filled(_slotAwaitingRemoteSync.length, false);
    for (final p in records) {
      if (p.taskId != taskId) continue;
      final idx = widget.session.items.indexWhere((e) => e.id == p.equipmentId);
      if (idx >= 0 && idx < next.length) {
        next[idx] = true;
      }
    }
    setState(() {
      _slotAwaitingRemoteSync = next;
    });
  }

  void _applyObjectResult(int index, InspectionObjectResult result) {
    if (index < 0 || index >= _photosPerSlot.length) return;
    _photosPerSlot[index] = result.photoCount;
    _audioPerSlot[index] = result.audioCount;
    _photosRunningTotal = _photosPerSlot.fold<int>(0, (a, b) => a + b);
    _audioRunningTotal = _audioPerSlot.fold<int>(0, (a, b) => a + b);
  }

  int? _firstPendingIndex() {
    for (var i = 0; i < _slotStates.length; i++) {
      if (_slotStates[i] == _RouteSlotState.pending) return i;
    }
    return null;
  }

  int get _finishedCount =>
      _slotStates.where((s) => s != _RouteSlotState.pending).length;

  bool get _allProcessed =>
      _slotStates.isNotEmpty &&
      _slotStates.every(
        (s) =>
            s == _RouteSlotState.completed ||
            s == _RouteSlotState.completedWithIssue,
      );

  Future<void> _maybeNavigateToSummary() async {
    if (!_allProcessed) return;
    final flags = _slotStates
        .map((st) => st == _RouteSlotState.completedWithIssue)
        .toList();
    final anyIssue = flags.any((x) => x);
    DemoTaskCompletionStore.instance.recordRouteFinished(
      storeKey: widget.session.storeKey,
      itemHasIssue: flags,
      totalPhotosSubmitted: _photosRunningTotal,
      totalAudioClipsSubmitted: _audioRunningTotal,
      itemPhotoCounts: List<int>.from(_photosPerSlot),
      itemAudioCounts: List<int>.from(_audioPerSlot),
    );
    await AssignedInspectionTaskService.completeAssignmentAndTask(
      assignmentId: widget.session.remoteAssignmentId,
      remoteTaskId: widget.session.remoteTaskId,
      anyRouteIssue: anyIssue,
      knownStartedAt: widget.session.assignmentStartedAt,
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      AppPageRoute<void>(
        builder: (context) => InspectionTaskSummaryScreen(
          session: widget.session,
          itemHasIssue: flags,
        ),
      ),
    );
  }

  Future<void> _openObjectAt(int index) async {
    if (index < 0 || index >= _slotStates.length) return;

    final result = await Navigator.of(context).push<InspectionObjectResult?>(
      AppPageRoute<InspectionObjectResult?>(
        builder: (context) => InspectionObjectScreen(
          session: widget.session,
          routeItemIndex: index,
        ),
      ),
    );

    if (!mounted || result == null) return;
    setState(() {
      _applyObjectResult(index, result);
      _slotAwaitingRemoteSync[index] = result.pendingRemoteSync;
      _slotStates[index] = result.hadDefect
          ? _RouteSlotState.completedWithIssue
          : _RouteSlotState.completed;
    });
    unawaited(_refreshAwaitingSyncFromStore());
    unawaited(
      AssignedInspectionTaskService.touchAssignmentProgress(
        widget.session.remoteAssignmentId,
      ),
    );
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_maybeNavigateToSummary());
    });
  }

  Future<void> _openCurrentObject() async {
    final i = _firstPendingIndex();
    if (i == null) return;
    await _openObjectAt(i);
  }

  String _badgeText(AppStrings s, int index) {
    switch (_slotStates[index]) {
      case _RouteSlotState.completed:
        if (_slotAwaitingRemoteSync[index]) return s.routeBadgeAwaitingSync;
        return s.statusCompleted;
      case _RouteSlotState.completedWithIssue:
        if (_slotAwaitingRemoteSync[index]) {
          return '${s.routeStatusHasIssue} · ${s.routeBadgeAwaitingSync}';
        }
        return s.routeStatusHasIssue;
      case _RouteSlotState.pending:
        final first = _firstPendingIndex();
        if (first == index) return s.badgeCurrent;
        return s.badgePending;
    }
  }

  Color _badgeColor(ColorScheme colorScheme, int index) {
    switch (_slotStates[index]) {
      case _RouteSlotState.completed:
        if (_slotAwaitingRemoteSync[index]) {
          return colorScheme.tertiary;
        }
        return colorScheme.primary;
      case _RouteSlotState.completedWithIssue:
        return colorScheme.error;
      case _RouteSlotState.pending:
        final first = _firstPendingIndex();
        if (first == index) return colorScheme.primary;
        return colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = context.languageController;
    final items = widget.session.items;
    final total = items.length;
    final progressValue = total == 0 ? 0.0 : _finishedCount / total;
    final pending = _firstPendingIndex();
    final allDone = pending == null && total > 0;

    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        final s = context.strings;
        return Scaffold(
          appBar: AppBar(
            title: Text(s.inspectionExecutionAppTitle),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.session.title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.session.siteAreaLine,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 16,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    widget.session.shiftOrDueLine,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      s.labelProgress.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 10,
                        backgroundColor: colorScheme.surfaceContainerHighest,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s.progressObjectsChecked(_finishedCount, total),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      s.sectionInspectionObjects.toUpperCase(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        letterSpacing: 0.9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...items.asMap().entries.map((entry) {
                      final index = entry.key;
                      final item = entry.value;
                      final order = index + 1;
                      final badgeText = _badgeText(s, index);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(
                            onTap: () => _openObjectAt(index),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: colorScheme.primary
                                          .withValues(alpha: 0.14),
                                    ),
                                    child: Text(
                                      '$order',
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.equipmentName,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          item.equipmentLocation,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color:
                                                colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  TaskFlowStatusPill(
                                    label: badgeText,
                                    accent: _badgeColor(colorScheme, index),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                child: FilledButton(
                  onPressed: allDone ? null : _openCurrentObject,
                  child: Text(s.openCurrentObjectButton),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
