import 'package:flutter/material.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/config/worker_identity.dart';
import '../../../core/localization/language_controller.dart';
import '../data/inspector_task_session.dart';
import '../data/task_chat_picker_service.dart';
import '../data/task_chat_service.dart';
import 'task_chat_picker_sheet.dart';
import 'task_chat_screen.dart';

bool taskChatSupportedForSession(InspectorTaskSession session) {
  final id = session.remoteTaskId?.trim() ?? '';
  return session.isRemote && id.isNotEmpty;
}

Future<void> openTaskChatForSession({
  required BuildContext context,
  required InspectorTaskSession session,
}) async {
  final s = context.strings;
  if (!taskChatSupportedForSession(session)) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.taskChatNotAvailableOffline)),
    );
    return;
  }
  if (!TaskChatService.isClientReady()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.taskChatErrorUnavailable)),
    );
    return;
  }
  if (!WorkerIdentity.hasAuthenticatedWorkerSession()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          TaskChatService.currentAuthUserId == null
              ? s.taskChatErrorNoAuthSession
              : s.taskChatErrorAnonymousSession,
        ),
      ),
    );
    return;
  }
  await Navigator.of(context).push<void>(
    AppPageRoute<void>(
      builder: (ctx) => TaskChatScreen(session: session),
    ),
  );
}

/// Profile entry: loads all relevant tasks (active + archive + chat history), then sheet or direct open.
Future<void> openTaskChatQuickAccess(BuildContext context) async {
  final s = context.strings;
  if (!TaskChatService.isClientReady()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.taskChatErrorUnavailable)),
    );
    return;
  }
  if (!WorkerIdentity.hasAuthenticatedWorkerSession()) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          TaskChatService.currentAuthUserId == null
              ? s.taskChatErrorNoAuthSession
              : s.taskChatErrorAnonymousSession,
        ),
      ),
    );
    return;
  }

  final result = await TaskChatPickerService.loadPickerEntries();
  if (!context.mounted) return;

  if (result.error != TaskChatPickerLoadError.none) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.taskChatUnableToLoad)),
    );
    return;
  }

  if (result.entries.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.taskChatNoTasksForChat)),
    );
    return;
  }

  if (result.entries.length == 1) {
    final e = result.entries.single;
    final session = InspectorTaskSession.fromRemoteTask(
      assignmentRow: e.bundle.assignmentRow,
      taskRow: e.bundle.taskRow,
      itemRows: e.bundle.itemRows,
      s: s,
    );
    await openTaskChatForSession(context: context, session: session);
    return;
  }

  await showTaskChatPickerSheet(context, preloaded: result);
}
