import 'package:flutter/material.dart';

import '../../../core/widgets/subtle_snowfall_background.dart';
import 'task_list_screen.dart';
import 'task_request_create_screen.dart';
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned.fill(
            child: SubtleSnowfallBackground(
              flakeCount: 72,
              intensity: 0.92,
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(bottom: bottomPad),
              child: IndexedStack(
                index: _tabIndex,
                children: const [
                  TaskListScreen(embedInMainShell: true),
                  TaskRequestCreateScreen(embedInMainShell: true),
                  WorkerProfileTabScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FloatingWorkerNavBar(
        currentIndex: _tabIndex,
        onSelect: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}
