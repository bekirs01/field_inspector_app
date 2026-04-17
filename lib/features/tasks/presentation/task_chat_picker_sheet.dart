import 'package:flutter/material.dart';

import '../../../core/localization/language_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../data/inspector_task_session.dart';
import '../data/task_chat_picker_service.dart';
import 'task_chat_navigation.dart';

/// Modal sheet: grouped task list for opening task-scoped chat.
/// [hostContext] must be the navigator context *under* the modal (caller’s context).
Future<void> showTaskChatPickerSheet(
  BuildContext hostContext, {
  TaskChatPickerLoadResult? preloaded,
}) async {
  await showModalBottomSheet<void>(
    context: hostContext,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        minChildSize: 0.45,
        initialChildSize: 0.72,
        maxChildSize: 0.94,
        expand: false,
        builder: (context, scrollController) {
          return _TaskChatPickerBody(
            hostContext: hostContext,
            sheetContext: sheetContext,
            scrollController: scrollController,
            preloaded: preloaded,
          );
        },
      );
    },
  );
}

class _TaskChatPickerBody extends StatefulWidget {
  const _TaskChatPickerBody({
    required this.hostContext,
    required this.sheetContext,
    required this.scrollController,
    this.preloaded,
  });

  final BuildContext hostContext;
  final BuildContext sheetContext;
  final ScrollController scrollController;
  final TaskChatPickerLoadResult? preloaded;

  @override
  State<_TaskChatPickerBody> createState() => _TaskChatPickerBodyState();
}

class _TaskChatPickerBodyState extends State<_TaskChatPickerBody> {
  late Future<TaskChatPickerLoadResult> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.preloaded != null
        ? Future.value(widget.preloaded!)
        : TaskChatPickerService.loadPickerEntries();
  }

  void _retry() {
    setState(() {
      _future = TaskChatPickerService.loadPickerEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = context.languageController;
    final host = widget.hostContext;

    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        final s = host.strings;
        return Material(
          color: kAppCanvas,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: FutureBuilder<TaskChatPickerLoadResult>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.taskChatLoadingConversationHint,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(strokeWidth: 2.5),
                    ],
                  ),
                );
              }

              final data = snapshot.data;
              if (data == null ||
                  data.error != TaskChatPickerLoadError.none) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        s.taskChatUnableToLoad,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _retry,
                        child: Text(s.tasksRetry),
                      ),
                    ],
                  ),
                );
              }

              if (data.entries.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 40,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        s.taskChatNoTasksForChat,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final active =
                  data.entries.where((e) => !e.isArchived).toList();
              final archived =
                  data.entries.where((e) => e.isArchived).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                    child: Text(
                      s.taskChatPickTaskTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: widget.scrollController,
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
                      children: [
                        if (active.isNotEmpty) ...[
                          _SectionHeader(label: s.taskChatPickerSectionActive),
                          for (final e in active)
                            _PickerTile(
                              entry: e,
                              hostContext: widget.hostContext,
                              sheetContext: widget.sheetContext,
                            ),
                        ],
                        if (archived.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _SectionHeader(label: s.taskChatPickerSectionArchive),
                          for (final e in archived)
                            _PickerTile(
                              entry: e,
                              hostContext: widget.hostContext,
                              sheetContext: widget.sheetContext,
                            ),
                        ],
                      ],
                    ),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.95),
          letterSpacing: 0.9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.entry,
    required this.hostContext,
    required this.sheetContext,
  });

  final TaskChatPickerEntry entry;
  final BuildContext hostContext;
  final BuildContext sheetContext;

  Future<void> _open() async {
    final s = hostContext.strings;
    final session = InspectorTaskSession.fromRemoteTask(
      assignmentRow: entry.bundle.assignmentRow,
      taskRow: entry.bundle.taskRow,
      itemRows: entry.bundle.itemRows,
      s: s,
    );
    Navigator.of(sheetContext).pop();
    await Future<void>.delayed(Duration.zero);
    if (hostContext.mounted) {
      await openTaskChatForSession(
        context: hostContext,
        session: session,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = hostContext.strings;
    final b = entry.bundle;
    final title = '${b.taskRow['title']}'.trim().isEmpty
        ? s.tasksUntitledTask
        : '${b.taskRow['title']}';
    final site = '${b.taskRow['site_name'] ?? ''}'.trim();
    final area = '${b.taskRow['area_name'] ?? ''}'.trim();
    String sub = '';
    if (site.isNotEmpty && area.isNotEmpty) {
      sub = '$site · $area';
    } else {
      sub = site.isNotEmpty ? site : area;
    }
    final statusLabel = s.inspectionTaskRemoteStatusCaption(
      b.taskRow['status']?.toString(),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: _open,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (entry.isArchived)
                      _MiniBadge(
                        label: s.taskChatBadgeArchived,
                        color: colorScheme.tertiary,
                      ),
                    if (entry.hasChatHistory) ...[
                      if (entry.isArchived) const SizedBox(width: 6),
                      _MiniBadge(
                        label: s.taskChatBadgeHasHistory,
                        color: colorScheme.primary,
                      ),
                    ],
                  ],
                ),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    sub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${s.labelStatus}: $statusLabel',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.88),
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

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Color.lerp(color, Colors.white, 0.35),
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
