import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/localization/language_menu_button.dart';
import 'mock_route_item.dart';
import 'task_detail_screen.dart';

class _MockTask {
  const _MockTask({
    required this.title,
    required this.area,
    required this.status,
  });

  final String title;
  final String area;
  final String status;
}

List<_MockTask> _mockTasksFromStrings(AppStrings s) {
  return [
    _MockTask(
      title: s.mockTask0Title,
      area: s.mockTask0Area,
      status: s.statusInProgress,
    ),
    _MockTask(
      title: s.mockTask1Title,
      area: s.mockTask1Area,
      status: s.statusPending,
    ),
    _MockTask(
      title: s.mockTask2Title,
      area: s.mockTask2Area,
      status: s.statusCompleted,
    ),
  ];
}

List<String> _mockShifts(AppStrings s) {
  return [s.mockShift0, s.mockShift1, s.mockShift2];
}

List<MockRouteItem> _routeItemsForIndex(int index, AppStrings s) {
  switch (index) {
    case 0:
      return [
        MockRouteItem(name: s.r0i0n, subtitle: s.r0i0s),
        MockRouteItem(name: s.r0i1n, subtitle: s.r0i1s),
        MockRouteItem(name: s.r0i2n, subtitle: s.r0i2s),
        MockRouteItem(name: s.r0i3n, subtitle: s.r0i3s),
      ];
    case 1:
      return [
        MockRouteItem(name: s.r1i0n, subtitle: s.r1i0s),
        MockRouteItem(name: s.r1i1n, subtitle: s.r1i1s),
        MockRouteItem(name: s.r1i2n, subtitle: s.r1i2s),
        MockRouteItem(name: s.r1i3n, subtitle: s.r1i3s),
        MockRouteItem(name: s.r1i4n, subtitle: s.r1i4s),
      ];
    default:
      return [
        MockRouteItem(name: s.r2i0n, subtitle: s.r2i0s),
        MockRouteItem(name: s.r2i1n, subtitle: s.r2i1s),
        MockRouteItem(name: s.r2i2n, subtitle: s.r2i2s),
        MockRouteItem(name: s.r2i3n, subtitle: s.r2i3s),
      ];
  }
}

void _openTaskDetail(
  BuildContext context,
  _MockTask task,
  int index,
  List<String> shifts,
  List<MockRouteItem> routeItems,
) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => TaskDetailScreen(
        title: task.title,
        area: task.area,
        status: task.status,
        shift: shifts[index],
        routeItems: routeItems,
      ),
    ),
  );
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final s = context.strings;
    final tasks = _mockTasksFromStrings(s);
    final shifts = _mockShifts(s);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.tasksAppTitle),
        actions: const [
          LanguageMenuButton(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            s.tasksSectionAssignedRounds,
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ...tasks.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final task = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _openTaskDetail(
                      context,
                      task,
                      index,
                      shifts,
                      _routeItemsForIndex(index, s),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            task.area,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            task.status,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
