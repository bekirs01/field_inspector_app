import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/worker_identity.dart';
import 'assigned_inspection_task_service.dart';
import 'inspector_task_session.dart';

enum TaskChatPickerLoadError {
  none,
  noWorkerIdentity,
  supabaseNotReady,
  fetchFailed,
}

class TaskChatPickerEntry {
  const TaskChatPickerEntry({
    required this.bundle,
    required this.hasChatHistory,
    this.threadId,
  });

  final AssignedInspectionTaskBundle bundle;
  final bool hasChatHistory;

  /// Present when a `task_chat_threads` row exists for this task.
  final String? threadId;

  bool get isArchived {
    final ex =
        '${bundle.assignmentRow['execution_status']}'.toLowerCase().trim();
    if (ex == 'completed' || ex == 'completed_with_issues') return true;
    final st = '${bundle.taskRow['status']}'.toLowerCase().trim();
    return st == 'completed' || st == 'completed_with_issues';
  }

  bool get isActiveAssignment => bundle.assignmentRow['is_active'] == true;
}

class TaskChatPickerLoadResult {
  const TaskChatPickerLoadResult({
    required this.entries,
    this.error = TaskChatPickerLoadError.none,
  });

  final List<TaskChatPickerEntry> entries;
  final TaskChatPickerLoadError error;
}

/// Builds the merged task list for profile → «chats by task».
class TaskChatPickerService {
  TaskChatPickerService._();

  static bool _clientReady() {
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<Set<String>> _orphanTaskIdsFromChatParticipation({
    required String workerId,
    required Set<String> taskIdsFromAssignments,
  }) async {
    try {
      final msgRes = await _client
          .from('task_chat_messages')
          .select('thread_id')
          .eq('sender_user_id', workerId);

      final msgList = msgRes as List<dynamic>;
      final threadIds = <String>{};
      for (final raw in msgList) {
        if (raw is Map<String, dynamic>) {
          final id = raw['thread_id']?.toString();
          if (id != null && id.isNotEmpty) threadIds.add(id);
        }
      }
      if (threadIds.isEmpty) return {};

      final thrRes = await _client
          .from('task_chat_threads')
          .select('id,task_id')
          .inFilter('id', threadIds.toList());

      final thrList = thrRes as List<dynamic>;
      final out = <String>{};
      for (final raw in thrList) {
        if (raw is Map<String, dynamic>) {
          final tid = raw['task_id']?.toString();
          if (tid != null &&
              tid.isNotEmpty &&
              !taskIdsFromAssignments.contains(tid)) {
            out.add(tid);
          }
        }
      }
      return out;
    } catch (e, st) {
      debugPrint('[TaskChatPicker] orphan task ids $e\n$st');
      return {};
    }
  }

  static Future<AssignedInspectionTaskBundle?> _bundleForTaskId(
    String taskId,
  ) async {
    try {
      final task = await _client
          .from('inspection_tasks')
          .select()
          .eq('id', taskId)
          .maybeSingle();
      if (task == null) return null;

      final taskMap = Map<String, dynamic>.from(task);
      final itemsRes = await _client
          .from('inspection_task_items')
          .select()
          .eq('task_id', taskId)
          .order('sort_order', ascending: true);

      final itemsList = itemsRes as List<dynamic>;
      final itemRows = <Map<String, dynamic>>[];
      for (final raw in itemsList) {
        if (raw is Map<String, dynamic>) {
          itemRows.add(raw);
        }
      }

      return AssignedInspectionTaskBundle(
        assignmentRow: InspectorTaskSession.syntheticAssignmentRowFromTask(taskMap),
        taskRow: taskMap,
        itemRows: itemRows,
      );
    } catch (e, st) {
      debugPrint('[TaskChatPicker] bundle for task $e\n$st');
      return null;
    }
  }

  static Future<TaskChatPickerLoadResult> loadPickerEntries() async {
    final workerId = WorkerIdentity.resolveWorkerUserId();
    if (workerId == null || workerId.isEmpty) {
      return const TaskChatPickerLoadResult(
        entries: [],
        error: TaskChatPickerLoadError.noWorkerIdentity,
      );
    }
    if (!_clientReady()) {
      return const TaskChatPickerLoadResult(
        entries: [],
        error: TaskChatPickerLoadError.supabaseNotReady,
      );
    }

    try {
      final assignLoad =
          await AssignedInspectionTaskService.loadAllWorkerAssignmentBundles();
      if (assignLoad.error == TaskListLoadError.fetchFailed) {
        return const TaskChatPickerLoadResult(
          entries: [],
          error: TaskChatPickerLoadError.fetchFailed,
        );
      }

      final bundles = List<AssignedInspectionTaskBundle>.from(assignLoad.bundles);
      final taskIdsFromAssignments = <String>{
        for (final b in bundles) '${b.taskRow['id'] ?? ''}',
      }..removeWhere((e) => e.isEmpty);

      final orphanIds = await _orphanTaskIdsFromChatParticipation(
        workerId: workerId,
        taskIdsFromAssignments: taskIdsFromAssignments,
      );

      for (final tid in orphanIds) {
        final extra = await _bundleForTaskId(tid);
        if (extra != null) bundles.add(extra);
      }

      if (bundles.isEmpty) {
        return const TaskChatPickerLoadResult(entries: []);
      }

      final allTaskIds = <String>{
        for (final b in bundles) '${b.taskRow['id'] ?? ''}',
      }..removeWhere((e) => e.isEmpty);

      final threadRes = await _client
          .from('task_chat_threads')
          .select('id,task_id')
          .inFilter('task_id', allTaskIds.toList());

      final threadList = threadRes as List<dynamic>;
      final threadIdByTask = <String, String>{};
      for (final raw in threadList) {
        if (raw is Map<String, dynamic>) {
          final tid = raw['task_id']?.toString();
          final th = raw['id']?.toString();
          if (tid != null &&
              tid.isNotEmpty &&
              th != null &&
              th.isNotEmpty) {
            threadIdByTask[tid] = th;
          }
        }
      }

      final threadIds = threadIdByTask.values.toList();
      final threadsWithMessages = <String>{};
      if (threadIds.isNotEmpty) {
        final histRes = await _client
            .from('task_chat_messages')
            .select('thread_id')
            .inFilter('thread_id', threadIds);

        final histList = histRes as List<dynamic>;
        for (final raw in histList) {
          if (raw is Map<String, dynamic>) {
            final th = raw['thread_id']?.toString();
            if (th != null && th.isNotEmpty) threadsWithMessages.add(th);
          }
        }
      }

      final entries = <TaskChatPickerEntry>[];
      for (final b in bundles) {
        final tid = '${b.taskRow['id'] ?? ''}';
        if (tid.isEmpty) continue;
        final th = threadIdByTask[tid];
        final hasHistory =
            th != null && th.isNotEmpty && threadsWithMessages.contains(th);
        entries.add(
          TaskChatPickerEntry(
            bundle: b,
            threadId: th,
            hasChatHistory: hasHistory,
          ),
        );
      }

      entries.sort((a, b) {
        final aArch = a.isArchived;
        final bArch = b.isArchived;
        if (aArch != bArch) return aArch ? 1 : -1;
        final aHist = a.hasChatHistory;
        final bHist = b.hasChatHistory;
        if (aHist != bHist) return aHist ? -1 : 1;
        final ta = '${a.bundle.taskRow['title']}'.toLowerCase();
        final tb = '${b.bundle.taskRow['title']}'.toLowerCase();
        return ta.compareTo(tb);
      });

      return TaskChatPickerLoadResult(entries: entries);
    } catch (e, st) {
      debugPrint('[TaskChatPicker] load failed $e\n$st');
      return const TaskChatPickerLoadResult(
        entries: [],
        error: TaskChatPickerLoadError.fetchFailed,
      );
    }
  }
}
