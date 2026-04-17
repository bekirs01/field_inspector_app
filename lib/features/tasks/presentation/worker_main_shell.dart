import 'package:flutter/material.dart';

import 'task_list_screen.dart';
import 'task_request_create_screen.dart';
import 'worker_archive_tab_screen.dart';
import 'worker_profile_tab_screen.dart';
import 'widgets/floating_worker_nav_bar.dart';

/// Top-level worker experience: tasks, request, profile + floating bottom nav.
class WorkerMainShell extends StatefulWidget {
  const WorkerMainShell({super.key});

  @override
  State<WorkerMainShell> createState() => _WorkerMainShellState();
}

class _WorkerMainShellState extends State<WorkerMainShell> {
  int _tabIndex = 0;

  static const double _navBarReserve = 74;

  @override
  Widget build(BuildContext context) {
    final bottomSafe = MediaQuery.paddingOf(context).bottom;
    final bottomPad = _navBarReserve + bottomSafe;

    return Scaffold(
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(bottom: bottomPad),
        child: IndexedStack(
          index: _tabIndex,
          children: const [
            TaskListScreen(embedInMainShell: true),
            TaskRequestCreateScreen(embedInMainShell: true),
            WorkerArchiveTabScreen(),
            WorkerProfileTabScreen(),
          ],
        ),
      ),
      bottomNavigationBar: FloatingWorkerNavBar(
        currentIndex: _tabIndex,
        onSelect: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}
