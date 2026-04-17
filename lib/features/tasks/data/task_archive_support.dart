import '../../../core/localization/demo_task_public_state.dart';
import 'demo_task_completion_store.dart';
import 'inspector_task_session.dart';

/// Whether [session] is finished (completed or completed with issues),
/// using the same [DemoTaskCompletionStore] + baseline rules as the task list.
bool taskSessionIsArchived({
  required InspectorTaskSession session,
  required DemoTaskCompletionStore store,
}) {
  final baseline = session.baselineState();
  final effective = store.effectiveState(
    storeKey: session.storeKey,
    baseline: baseline,
  );
  return effective == DemoTaskPublicState.completed ||
      effective == DemoTaskPublicState.completedWithIssues;
}

/// Parses assignment `completed_at` for sorting / display.
DateTime? taskSessionAssignmentCompletedAt(InspectorTaskSession session) {
  final raw = session.assignmentCompletedAtRaw;
  if (raw == null || raw.isEmpty) return null;
  return DateTime.tryParse(raw)?.toUtc();
}
