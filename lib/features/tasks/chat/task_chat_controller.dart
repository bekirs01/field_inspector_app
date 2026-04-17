import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/inspector_task_session.dart';
import '../data/task_chat_service.dart';

/// UI state for [TaskChatScreen]. Loads thread + messages with timeouts; realtime after ready.
class TaskChatController extends ChangeNotifier {
  TaskChatController({required this.session}) : _readOnly = _computeReadOnly(session) {
    final id = session.remoteTaskId?.trim() ?? '';
    if (!session.isRemote || id.isEmpty) {
      _phase = TaskChatPhase.error;
      _errorMessageKey = TaskChatErrorKey.notRemoteTask;
      initialLoadFuture = Future<void>.value();
      notifyListeners();
      return;
    }
    _taskId = id;
    initialLoadFuture = _bootstrap();
  }

  /// Completes when the first load attempt finishes (success or error).
  /// Reassigned on [retry].
  late Future<void> initialLoadFuture;

  final InspectorTaskSession session;
  String _taskId = '';
  String get taskId => _taskId;

  TaskChatPhase _phase = TaskChatPhase.loading;
  TaskChatErrorKey? _errorMessageKey;
  String? _threadId;
  List<TaskChatMessageVm> _messages = [];
  RealtimeChannel? _channel;
  final bool _readOnly;

  bool _sending = false;

  TaskChatPhase get phase => _phase;
  TaskChatErrorKey? get errorKey => _errorMessageKey;
  String? get threadId => _threadId;
  List<TaskChatMessageVm> get messages => List.unmodifiable(_messages);
  bool get readOnly => _readOnly;
  bool get sending => _sending;

  /// Composer visible for active tasks unless we hit a hard error.
  bool get canShowComposer =>
      !_readOnly && _phase != TaskChatPhase.error;

  bool get canCompose => canShowComposer;

  static const Duration _networkTimeout = Duration(seconds: 18);

  static bool _computeReadOnly(InspectorTaskSession session) {
    final ex =
        session.assignmentExecutionStatusRaw?.toLowerCase().trim() ?? '';
    if (ex == 'completed' || ex == 'completed_with_issues') return true;
    final ts = session.remoteStatusRaw?.toLowerCase().trim() ?? '';
    if (ts == 'completed' || ts == 'completed_with_issues') return true;
    return false;
  }

  @override
  void dispose() {
    final ch = _channel;
    if (ch != null) {
      unawaited(Supabase.instance.client.removeChannel(ch));
    }
    super.dispose();
  }

  Future<void> retry() async {
    if (!session.isRemote || _taskId.isEmpty) return;
    _phase = TaskChatPhase.loading;
    _errorMessageKey = null;
    notifyListeners();
    initialLoadFuture = _bootstrap();
    await initialLoadFuture;
  }

  Future<void> _bootstrap() async {
    try {
      final tid = await TaskChatService.getThreadIdForTaskIfExists(_taskId)
          .timeout(_networkTimeout);
      var msgs = <TaskChatMessageVm>[];
      if (tid != null && tid.isNotEmpty) {
        msgs =
            await TaskChatService.fetchMessages(tid).timeout(_networkTimeout);
      }
      _threadId = tid;
      _messages = msgs;
      _phase = TaskChatPhase.ready;
      _errorMessageKey = null;
      notifyListeners();

      if (tid != null && tid.isNotEmpty) {
        unawaited(_afterReady(tid));
      }
    } on TimeoutException {
      _phase = TaskChatPhase.error;
      _errorMessageKey = TaskChatErrorKey.timeout;
      notifyListeners();
    } catch (e, st) {
      debugPrint('[TaskChatController] bootstrap $e\n$st');
      _phase = TaskChatPhase.error;
      _errorMessageKey = _classifyError(e);
      notifyListeners();
    }
  }

  TaskChatErrorKey _classifyError(Object e) {
    if (e is TaskChatUserException) {
      switch (e.code) {
        case TaskChatUserCode.notAuthenticated:
          return TaskChatErrorKey.noAuthSession;
        case TaskChatUserCode.profileRequired:
          return TaskChatErrorKey.profileRequired;
        case TaskChatUserCode.permissionDenied:
          return TaskChatErrorKey.permission;
        case TaskChatUserCode.rlsInsertDenied:
          return TaskChatErrorKey.rlsInsertDenied;
        case TaskChatUserCode.threadCreateFailed:
          return TaskChatErrorKey.createThreadFailed;
        case TaskChatUserCode.serverSchemaMismatch:
          return TaskChatErrorKey.sendFailed;
        case TaskChatUserCode.messageReturnEmpty:
        case TaskChatUserCode.messageSendFailed:
        case TaskChatUserCode.attachmentMetadataFailed:
          return TaskChatErrorKey.sendFailed;
        case TaskChatUserCode.storageBucketMissing:
        case TaskChatUserCode.storageUploadFailed:
          return TaskChatErrorKey.storageFailed;
        case TaskChatUserCode.fileTooLarge:
          return TaskChatErrorKey.fileTooLarge;
      }
    }
    if (e is PostgrestException) {
      final msg = '${e.message}${e.details}'.toLowerCase();
      final code = (e.code ?? '').toUpperCase();
      if (code == '401' ||
          msg.contains('jwt') ||
          msg.contains('invalid refresh token')) {
        return TaskChatErrorKey.noAuthSession;
      }
      if (code == '403' ||
          code == '42501' ||
          msg.contains('permission') ||
          msg.contains('rls') ||
          msg.contains('policy')) {
        return TaskChatErrorKey.permission;
      }
      if (msg.contains('task_chat_requires_profile') ||
          msg.contains('requires_profile')) {
        return TaskChatErrorKey.profileRequired;
      }
    }
    return TaskChatErrorKey.generic;
  }

  Future<void> _afterReady(String tid) async {
    try {
      await TaskChatService.upsertLastRead(tid);
    } catch (e, st) {
      debugPrint('[TaskChatController] upsertLastRead $e\n$st');
    }
    _subscribe(tid);
  }

  void _subscribe(String tid) {
    try {
      _channel?.unsubscribe();
      _channel = TaskChatService.subscribeToNewMessages(
        threadId: tid,
        onInsert: (m) {
          final idx = _messages.indexWhere((x) => x.id == m.id);
          if (idx < 0) {
            _messages = [..._messages, m];
          } else {
            final old = _messages[idx];
            if (old.attachments.isEmpty && m.attachments.isNotEmpty) {
              final copy = List<TaskChatMessageVm>.from(_messages);
              copy[idx] = m;
              _messages = copy;
            }
          }
          notifyListeners();
        },
      );
    } catch (e, st) {
      debugPrint('[TaskChatController] subscribe $e\n$st');
    }
  }

  /// Ensures a thread row exists; throws [TaskChatUserException] on failure (so UI can show [technicalDetail] in debug).
  Future<String> ensureThreadForSend() async {
    var tid = _threadId;
    if (tid != null && tid.isNotEmpty) return tid;
    try {
      tid =
          await TaskChatService.ensureThreadId(_taskId).timeout(_networkTimeout);
      _threadId = tid;
      notifyListeners();
      unawaited(_afterReady(tid));
      return tid;
    } on TaskChatUserException catch (e, st) {
      debugPrint('[TaskChatController] ensureThread $e\n$st');
      if (e.technicalDetail != null) {
        debugPrint('[TaskChatController] ensureThread technical:\n${e.technicalDetail}');
      }
      rethrow;
    } on PostgrestException catch (e, st) {
      debugPrint('[TaskChatController] ensureThread $e\n$st');
      final tech = TaskChatService.formatPostgrestTechnical(
        e,
        table: 'task_chat_threads',
        operation: 'insert',
        payloadKeys: const ['id', 'task_id'],
        meta: TaskChatSendDebugMeta(
          taskId: _taskId,
          threadId: '(creating)',
          threadKnownBeforeEnsure: false,
        ),
      );
      throw TaskChatUserException(
        TaskChatUserCode.threadCreateFailed,
        debugDetail: e.message,
        technicalDetail: tech,
      );
    } catch (e, st) {
      debugPrint('[TaskChatController] ensureThread $e\n$st');
      throw TaskChatUserException(
        TaskChatUserCode.threadCreateFailed,
        debugDetail: '$e',
        technicalDetail: TaskChatService.formatGenericExceptionTechnical(e, st),
      );
    }
  }

  Future<bool> sendText(String text) async {
    if (_readOnly) return false;
    await initialLoadFuture;
    if (_phase != TaskChatPhase.ready) return false;
    final threadKnownBeforeEnsure =
        _threadId != null && _threadId!.isNotEmpty;
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;
    _sending = true;
    notifyListeners();
    try {
      final tid = await ensureThreadForSend();
      final sendMeta = TaskChatSendDebugMeta(
        taskId: _taskId,
        threadId: tid,
        threadKnownBeforeEnsure: threadKnownBeforeEnsure,
      );
      final m = await TaskChatService.sendText(
        taskId: _taskId,
        threadId: tid,
        body: trimmed,
        sendMeta: sendMeta,
      ).timeout(_networkTimeout);
      if (!_messages.any((x) => x.id == m.id)) {
        _messages = [..._messages, m];
      }
      try {
        final synced =
            await TaskChatService.fetchMessages(tid).timeout(_networkTimeout);
        if (synced.any((x) => x.id == m.id)) {
          _messages = synced;
        } else {
          debugPrint(
            '[TaskChatController] post-send list has no id=${m.id} (read RLS or replication lag)',
          );
        }
      } catch (e, st) {
        debugPrint('[TaskChatController] post-send fetchMessages $e\n$st');
      }
      _sending = false;
      notifyListeners();
      return true;
    } on TaskChatUserException catch (e, st) {
      debugPrint('[TaskChatController] sendText $e\n$st');
      _sending = false;
      notifyListeners();
      rethrow;
    } on TimeoutException catch (e, st) {
      debugPrint('[TaskChatController] sendText timeout $e\n$st');
      _sending = false;
      notifyListeners();
      throw TaskChatUserException(
        TaskChatUserCode.messageSendFailed,
        debugDetail: 'timeout',
        technicalDetail:
            'TimeoutException after ${_networkTimeout.inSeconds}s\n$st',
      );
    } catch (e, st) {
      debugPrint('[TaskChatController] sendText $e\n$st');
      _sending = false;
      notifyListeners();
      final tech = e is PostgrestException
          ? TaskChatService.formatPostgrestTechnical(
              e,
              table: 'task_chat_messages',
              operation: 'insert',
              payloadKeys: const [
                'id',
                'thread_id',
                kTaskChatMessageTaskIdColumn,
                kTaskChatMessageBodyColumn,
              ],
            )
          : TaskChatService.formatGenericExceptionTechnical(e, st);
      throw TaskChatUserException(
        TaskChatUserCode.messageSendFailed,
        debugDetail: '$e',
        technicalDetail: tech,
      );
    }
  }

  /// Returns false if the thread could not be opened or send was skipped.
  Future<bool> sendFile({
    required File file,
    required String displayName,
    required String? mime,
    String caption = '',
  }) async {
    if (_readOnly) return false;
    await initialLoadFuture;
    if (_phase != TaskChatPhase.ready) return false;
    final threadKnownBeforeEnsure =
        _threadId != null && _threadId!.isNotEmpty;
    _sending = true;
    notifyListeners();
    try {
      final tid = await ensureThreadForSend();
      final sendMeta = TaskChatSendDebugMeta(
        taskId: _taskId,
        threadId: tid,
        threadKnownBeforeEnsure: threadKnownBeforeEnsure,
      );
      final m = await TaskChatService.sendWithLocalFile(
        taskId: _taskId,
        threadId: tid,
        body: caption,
        file: file,
        fileName: displayName,
        mimeType: mime,
        sendMeta: sendMeta,
      ).timeout(_networkTimeout);
      final idx = _messages.indexWhere((x) => x.id == m.id);
      if (idx >= 0) {
        final copy = List<TaskChatMessageVm>.from(_messages);
        copy[idx] = m;
        _messages = copy;
      } else {
        _messages = [..._messages, m];
      }
      try {
        final synced =
            await TaskChatService.fetchMessages(tid).timeout(_networkTimeout);
        if (synced.any((x) => x.id == m.id)) {
          _messages = synced;
        }
      } catch (e, st) {
        debugPrint('[TaskChatController] post-send file fetchMessages $e\n$st');
      }
      _sending = false;
      notifyListeners();
      return true;
    } on TaskChatUserException catch (e, st) {
      debugPrint('[TaskChatController] sendFile $e\n$st');
      _sending = false;
      notifyListeners();
      rethrow;
    } on TimeoutException catch (e, st) {
      debugPrint('[TaskChatController] sendFile timeout $e\n$st');
      _sending = false;
      notifyListeners();
      throw TaskChatUserException(
        TaskChatUserCode.storageUploadFailed,
        debugDetail: 'timeout',
        technicalDetail:
            'TimeoutException after ${_networkTimeout.inSeconds}s\n$st',
      );
    } catch (e, st) {
      debugPrint('[TaskChatController] sendFile $e\n$st');
      _sending = false;
      notifyListeners();
      throw TaskChatUserException(
        TaskChatUserCode.storageUploadFailed,
        debugDetail: '$e',
        technicalDetail: TaskChatService.formatGenericExceptionTechnical(e, st),
      );
    }
  }
}

enum TaskChatPhase { loading, ready, error }

enum TaskChatErrorKey {
  notRemoteTask,
  timeout,
  permission,
  profileRequired,
  noAuthSession,
  rlsInsertDenied,
  createThreadFailed,
  sendFailed,
  storageFailed,
  fileTooLarge,
  generic,
}
