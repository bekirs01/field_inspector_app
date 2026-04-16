import 'package:flutter/material.dart';

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

const List<_MockTask> _mockTasks = [
  _MockTask(
    title: 'Обход котельной №1',
    area: 'Котельная, зона А',
    status: 'В процессе',
  ),
  _MockTask(
    title: 'Плановый осмотр трансформаторной',
    area: 'ТП-12',
    status: 'Ожидает',
  ),
  _MockTask(
    title: 'Обход насосной станции',
    area: 'Насосная — корпус 2',
    status: 'Выполнено',
  ),
];

const List<String> _mockShifts = [
  'Смена А, 16.04.2026',
  'Смена Б, 16.04.2026',
  'Смена А, 15.04.2026',
];

List<MockRouteItem> _routeItemsForIndex(int index) {
  switch (index) {
    case 0:
      return const [
        MockRouteItem(
          name: 'Насос Н-12',
          subtitle: 'Котельная, линия подачи',
        ),
        MockRouteItem(
          name: 'Клапан К-3',
          subtitle: 'Зона А, узел регулировки',
        ),
        MockRouteItem(
          name: 'Датчик температуры T-7',
          subtitle: 'Коллектор горячей воды',
        ),
        MockRouteItem(
          name: 'Щит управления ШУ-2',
          subtitle: 'Помещение автоматики',
        ),
      ];
    case 1:
      return const [
        MockRouteItem(
          name: 'Силовой трансформатор Т-1',
          subtitle: 'ТП-12, камера 1',
        ),
        MockRouteItem(
          name: 'Разъединитель Р-5',
          subtitle: 'Ячейка ввода',
        ),
        MockRouteItem(
          name: 'Датчик температуры T-7',
          subtitle: 'Секция шин',
        ),
        MockRouteItem(
          name: 'Щит управления ШУ-2',
          subtitle: 'Пульт оператора',
        ),
        MockRouteItem(
          name: 'Клапан К-3',
          subtitle: 'Пожарный сегмент',
        ),
      ];
    default:
      return const [
        MockRouteItem(
          name: 'Насос Н-12',
          subtitle: 'Насосная, агрегат 1',
        ),
        MockRouteItem(
          name: 'Клапан К-3',
          subtitle: 'Обвязка напорная',
        ),
        MockRouteItem(
          name: 'Датчик температуры T-7',
          subtitle: 'Резервуар, датчик погружной',
        ),
        MockRouteItem(
          name: 'Щит управления ШУ-2',
          subtitle: 'Корпус 2, щитовая',
        ),
      ];
  }
}

void _openTaskDetail(BuildContext context, _MockTask task, int index) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => TaskDetailScreen(
        title: task.title,
        area: task.area,
        status: task.status,
        shift: _mockShifts[index],
        routeItems: _routeItemsForIndex(index),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Задачи'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Назначенные обходы',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          ..._mockTasks.asMap().entries.map(
            (entry) {
              final index = entry.key;
              final task = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _openTaskDetail(context, task, index),
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
