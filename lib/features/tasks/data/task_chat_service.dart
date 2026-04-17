import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_env.dart';
import '../../../core/config/worker_identity.dart';
import '../../../core/config/worker_profile_service.dart';
import '../../../core/util/random_uuid.dart';

/// Max attachment size for task chat uploads (bytes).
const int kTaskChatMaxAttachmentBytes = 25 * 1024 * 1024;

/// DB column for message text (`20260417140000_task_chat.sql`). Inserts/selects use this name.
const String kTaskChatMessageBodyColumn = 'body';

/// Denormalized task reference on `task_chat_messages` (production / `20260422170000` migration).
const String kTaskChatMessageTaskIdColumn = 'task_id';

/// Values for `task_chat_attachments.attachment_type` (production schema; text / enum).
const String kTaskChatAttachmentTypeImage = 'image';
const String kTaskChatAttachmentTypeVideo = 'video';
const String kTaskChatAttachmentTypePdf = 'pdf';
const String kTaskChatAttachmentTypeFile = 'file';

/// User-facing send/load failures from [TaskChatService] (map to [AppStrings] in UI).
enum TaskChatUserCode {
  notAuthenticated,
  profileRequired,
  permissionDenied,
  threadCreateFailed,
  messageSendFailed,
  /// NOT NULL / missing column / missing trigger — DB schema out of sync with app.
  serverSchemaMismatch,
  /// Insert likely succeeded but server returned no row (e.g. RLS on SELECT / RETURNING).
  messageReturnEmpty,
  rlsInsertDenied,
  attachmentMetadataFailed,
  storageUploadFailed,
  storageBucketMissing,
  fileTooLarge,
}

class TaskChatUserException implements Exception {
  TaskChatUserException(
    this.code, {
    this.debugDetail,
    this.technicalDetail,
  });

  final TaskChatUserCode code;
  final String? debugDetail;

  /// Multi-line backend detail for logs and debug SnackBars (not for release-only UX).
  final String? technicalDetail;

  @override
  String toString() =>
      'TaskChatUserException($code${debugDetail != null ? ': $debugDetail' : ''})';
}

/// Context for developer-visible send diagnostics (task / thread / first-load state).
class TaskChatSendDebugMeta {
  const TaskChatSendDebugMeta({
    required this.taskId,
    required this.threadId,
    required this.threadKnownBeforeEnsure,
  });

  final String taskId;
  final String threadId;
  final bool threadKnownBeforeEnsure;
}

class TaskChatAttachmentVm {
  const TaskChatAttachmentVm({
    required this.id,
    required this.storagePath,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.storageBucket,
  });

  final String id;
  final String storagePath;
  final String fileName;
  final String? mimeType;
  final int? sizeBytes;
  /// When set (production), signed URLs use this bucket; else [AppEnv.taskChatMediaBucket].
  final String? storageBucket;
}

class TaskChatMessageVm {
  const TaskChatMessageVm({
    required this.id,
    required this.threadId,
    required this.senderUserId,
    required this.senderRole,
    required this.body,
    required this.createdAt,
    this.attachments = const [],
  });

  final String id;
  final String threadId;
  final String senderUserId;
  final String senderRole;
  final String body;
  final DateTime createdAt;
  final List<TaskChatAttachmentVm> attachments;

  TaskChatMessageVm copyWith({
    List<TaskChatAttachmentVm>? attachments,
  }) {
    return TaskChatMessageVm(
      id: id,
      threadId: threadId,
      senderUserId: senderUserId,
      senderRole: senderRole,
      body: body,
      createdAt: createdAt,
      attachments: attachments ?? this.attachments,
    );
  }
}

/// Supabase-backed task-scoped chat (see `task_chat_*` tables).
class TaskChatService {
  TaskChatService._();

  static bool isClientReady() {
    try {
      return Supabase.instance.isInitialized;
    } on AssertionError {
      return false;
    } catch (_) {
      return false;
    }
  }

  static SupabaseClient get _client => Supabase.instance.client;

  static String? get currentAuthUserId =>
      _client.auth.currentSession?.user.id;

  /// Supabase [auth.uid()] for chat writes — same identity as [WorkerIdentity.resolveWorkerUserId]
  /// when the user is signed in with a non-anonymous account.
  static String requireChatActorUserId() {
    if (!WorkerIdentity.hasAuthenticatedWorkerSession()) {
      throw TaskChatUserException(
        TaskChatUserCode.notAuthenticated,
        debugDetail: 'need_non_anonymous_session',
        technicalDetail:
            'WorkerIdentity.hasAuthenticatedWorkerSession() == false\n'
            'Chat requires a non-anonymous Supabase session (auth.currentUser).',
      );
    }
    final uid = _client.auth.currentUser?.id;
    if (uid == null || uid.isEmpty) {
      throw TaskChatUserException(
        TaskChatUserCode.notAuthenticated,
        debugDetail: 'missing_current_user',
        technicalDetail: 'auth.currentUser.id is null or empty after session check.',
      );
    }
    final resolved = WorkerIdentity.resolveWorkerUserId();
    if (resolved != null &&
        resolved.isNotEmpty &&
        resolved.toLowerCase() != uid.toLowerCase()) {
      throw TaskChatUserException(
        TaskChatUserCode.notAuthenticated,
        debugDetail: 'worker_identity_mismatch',
        technicalDetail:
            'auth.currentUser.id ($uid) != WorkerIdentity.resolveWorkerUserId() ($resolved)\n'
            'Assignments and chat RLS both expect the same worker id.',
      );
    }
    return uid;
  }

  static Future<String> createSignedUrl(
    String storagePath, {
    String? bucket,
  }) async {
    final b = (bucket != null && bucket.trim().isNotEmpty)
        ? bucket.trim()
        : AppEnv.taskChatMediaBucket;
    final res = await _client.storage.from(b).createSignedUrl(storagePath, 3600);
    return res;
  }

  static void _throwIfPostgrestDenied(Object e) {
    if (e is! PostgrestException) return;
    final msg = '${e.message}${e.details}${e.hint}'.toLowerCase();
    if (msg.contains('task_chat_requires_profile') ||
        msg.contains('requires_profile')) {
      throw TaskChatUserException(
        TaskChatUserCode.profileRequired,
        debugDetail: e.message,
      );
    }
    final code = e.code ?? '';
    if (code == '42501' ||
        msg.contains('permission denied') ||
        msg.contains('row-level security') ||
        msg.contains('rls') ||
        msg.contains('policy')) {
      throw TaskChatUserException(
        TaskChatUserCode.permissionDenied,
        debugDetail: e.message,
      );
    }
  }

  /// Full PostgREST / Postgres fields for logs and [TaskChatUserException.technicalDetail].
  static String formatPostgrestTechnical(
    PostgrestException e, {
    required String table,
    required String operation,
    required List<String> payloadKeys,
    TaskChatSendDebugMeta? meta,
    String? authUid,
  }) {
    final buf = StringBuffer();
    buf.writeln('exception: PostgrestException');
    buf.writeln('code: ${e.code}');
    buf.writeln('message: ${e.message}');
    buf.writeln('details: ${e.details}');
    buf.writeln('hint: ${e.hint}');
    buf.writeln('table: $table');
    buf.writeln('operation: $operation');
    buf.writeln('payload_keys: ${payloadKeys.join(', ')}');
    if (authUid != null && authUid.isNotEmpty) {
      buf.writeln('auth.uid (client session): $authUid');
    }
    if (meta != null) {
      buf.writeln('task_id: ${meta.taskId}');
      buf.writeln('thread_id: ${meta.threadId}');
      buf.writeln(
        'thread_existed_before_ensure: ${meta.threadKnownBeforeEnsure}',
      );
    }
    return buf.toString().trim();
  }

  static String formatStorageExceptionTechnical(
    StorageException e, {
    required String bucket,
    required String operation,
    required String pathShape,
  }) {
    return 'exception: StorageException\n'
        'statusCode: ${e.statusCode}\n'
        'message: ${e.message}\n'
        'bucket: $bucket\n'
        'operation: $operation\n'
        'path_shape: $pathShape';
  }

  static String formatGenericExceptionTechnical(Object e, StackTrace st) {
    return 'exception: ${e.runtimeType}\n$e\n$st';
  }

  /// Single string for matching (PostgREST puts RLS text in [details] / [hint], not only [message]).
  static String _postgrestFullLower(PostgrestException e) {
    final d = e.details;
    final detailPart = switch (d) {
      null => '',
      Map _ => d.toString(),
      List _ => d.toString(),
      final x => x.toString(),
    };
    return '${e.message} $detailPart ${e.hint ?? ''}'.toLowerCase();
  }

  /// PostgREST may put the Postgres error in [PostgrestException.code] **or** only HTTP status there.
  static Iterable<String> _allPostgrestCodes(PostgrestException e) sync* {
    final c = (e.code ?? '').trim();
    if (c.isNotEmpty) yield c.toUpperCase();
    final d = e.details;
    if (d is Map) {
      final ic = d['code'];
      if (ic != null && '$ic'.trim().isNotEmpty) yield '$ic'.trim().toUpperCase();
    }
  }

  static TaskChatUserException _mapPostgrestSendFailure(
    PostgrestException e, {
    required String table,
    required String operation,
    required List<String> payloadKeys,
    TaskChatSendDebugMeta? meta,
    String? authUid,
  }) {
    final tech = formatPostgrestTechnical(
      e,
      table: table,
      operation: operation,
      payloadKeys: payloadKeys,
      meta: meta,
      authUid: authUid,
    );
    debugPrint('[TaskChat] PostgREST failure (full):\n$tech');

    final msg = _postgrestFullLower(e);
    final codes = _allPostgrestCodes(e).toSet();
    final code = (e.code ?? '').toUpperCase();

    // Schema cache / missing column (e.g. production table without `body`).
    if (code == 'PGRST204' ||
        codes.contains('PGRST204') ||
        (msg.contains('could not find') &&
            msg.contains('column') &&
            msg.contains('schema cache'))) {
      return TaskChatUserException(
        TaskChatUserCode.serverSchemaMismatch,
        debugDetail: e.message,
        technicalDetail: tech,
      );
    }

    if (msg.contains('task_chat_requires_profile') ||
        msg.contains('requires_profile')) {
      return TaskChatUserException(
        TaskChatUserCode.profileRequired,
        debugDetail: e.message,
        technicalDetail: tech,
      );
    }

    if (codes.contains('401') ||
        msg.contains('jwt') ||
        msg.contains('invalid refresh token') ||
        msg.contains('invalid login')) {
      return TaskChatUserException(
        TaskChatUserCode.notAuthenticated,
        debugDetail: e.message,
        technicalDetail: tech,
      );
    }

    if (codes.contains('403') ||
        code == '42501' ||
        codes.contains('42501') ||
        msg.contains('pgrst301') ||
        msg.contains('new row violates row-level security') ||
        msg.contains('violates row-level security') ||
        (msg.contains('violates') && msg.contains('policy')) ||
        msg.contains('row security')) {
      return TaskChatUserException(
        TaskChatUserCode.rlsInsertDenied,
        debugDetail: e.message,
        technicalDetail: tech,
      );
    }

    if (msg.contains('permission denied') ||
        msg.contains('denied for table') ||
        msg.contains('forbidden') ||
        msg.contains('not acceptable') ||
        msg.contains('rls') ||
        msg.contains('policy')) {
      return TaskChatUserException(
        TaskChatUserCode.rlsInsertDenied,
        debugDetail: e.message,
        technicalDetail: tech,
      );
    }

    if (code == '23503' ||
        msg.contains('foreign key') ||
        msg.contains('violates foreign key')) {
      return TaskChatUserException(
        TaskChatUserCode.messageSendFailed,
        debugDetail: 'fk:${e.message}',
        technicalDetail: tech,
      );
    }

    if (code == '23514' || msg.contains('check constraint')) {
      return TaskChatUserException(
        TaskChatUserCode.profileRequired,
        debugDetail: 'role_check:${e.message}',
        technicalDetail: tech,
      );
    }

    final notNullViolation = code == '23502' ||
        (msg.contains('null value') && msg.contains('column')) ||
        (msg.contains('not null') &&
            (msg.contains('violates') || msg.contains('constraint')));
    if (notNullViolation ||
        code == '42703' ||
        code == '42P01' ||
        msg.contains('undefined column') ||
        msg.contains('undefined table')) {
      return TaskChatUserException(
        TaskChatUserCode.serverSchemaMismatch,
        debugDetail: '${e.code} ${e.message}',
        technicalDetail: tech,
      );
    }

    return TaskChatUserException(
      TaskChatUserCode.messageSendFailed,
      debugDetail: '${e.code} ${e.message}',
      technicalDetail: tech,
    );
  }

  /// Local view model after insert — **no** follow-up `select()` (avoids RLS on read).
  static TaskChatMessageVm _localMessageVmAfterInsert({
    required String messageId,
    required String threadId,
    required String body,
    required String uid,
    required String senderRole,
  }) {
    final role =
        senderRole.trim().isEmpty ? 'worker' : senderRole.trim().toLowerCase();
    final safeRole = (role == 'admin' || role == 'worker') ? role : 'worker';
    return TaskChatMessageVm(
      id: messageId,
      threadId: threadId,
      senderUserId: uid,
      senderRole: safeRole,
      body: body,
      createdAt: DateTime.now().toUtc(),
    );
  }

  /// Returns existing thread id or null (does not create a row).
  /// Throws on network / RLS errors so the UI can show an error state.
  static Future<String?> getThreadIdForTaskIfExists(String taskId) async {
    final trimmed = taskId.trim();
    if (trimmed.isEmpty) return null;
    try {
      final row = await _client
          .from('task_chat_threads')
          .select('id')
          .eq('task_id', trimmed)
          .maybeSingle();
      if (row == null) return null;
      final id = row['id']?.toString();
      if (id == null || id.isEmpty) return null;
      return id;
    } on PostgrestException catch (e) {
      _throwIfPostgrestDenied(e);
      rethrow;
    }
  }

  static Future<String> ensureThreadId(String taskId) async {
    final trimmed = taskId.trim();
    if (trimmed.isEmpty) {
      throw TaskChatUserException(
        TaskChatUserCode.threadCreateFailed,
        debugDetail: 'empty_task_id',
        technicalDetail:
            'table: task_chat_threads\noperation: (skipped)\nreason: empty task_id',
      );
    }
    final existingId = await getThreadIdForTaskIfExists(trimmed);
    if (existingId != null && existingId.isNotEmpty) {
      return existingId;
    }
    try {
      final newId = randomUuidV4();
      await _client.from('task_chat_threads').insert({
        'id': newId,
        'task_id': trimmed,
      });
      return newId;
    } on TaskChatUserException {
      rethrow;
    } on PostgrestException catch (e) {
      final code = e.code?.toString() ?? '';
      final dup = code == '23505' ||
          '${e.message}${e.details}'.toLowerCase().contains('duplicate');
      if (dup) {
        final existing = await getThreadIdForTaskIfExists(trimmed);
        if (existing != null && existing.isNotEmpty) return existing;
        throw TaskChatUserException(
          TaskChatUserCode.threadCreateFailed,
          debugDetail: 'duplicate_no_row',
          technicalDetail:
              'table: task_chat_threads\noperation: insert\n'
              'payload_keys: id, task_id\n'
              'reason: unique violation but re-select returned no row (race or RLS on select)',
        );
      }
      throw _mapPostgrestSendFailure(
        e,
        table: 'task_chat_threads',
        operation: 'insert',
        payloadKeys: const ['id', 'task_id'],
        meta: TaskChatSendDebugMeta(
          taskId: trimmed,
          threadId: '(new)',
          threadKnownBeforeEnsure: false,
        ),
      );
    }
  }

  static Future<void> upsertLastRead(String threadId) async {
    try {
      final uid = requireChatActorUserId();
      await _client.from('task_chat_reads').upsert({
        'thread_id': threadId,
        'user_id': uid,
        'last_read_at': DateTime.now().toUtc().toIso8601String(),
      });
    } on TaskChatUserException {
      // Optional marker; skip if session is not a real worker JWT.
    }
  }

  static TaskChatMessageVm? messageFromRow(Map<String, dynamic> row) {
    try {
      final id = row['id']?.toString();
      final threadId = row['thread_id']?.toString();
      final senderUserId = row['sender_user_id']?.toString();
      final senderRole = row['sender_role']?.toString() ?? 'worker';
      // Canonical column is [kTaskChatMessageBodyColumn] (see repo migrations).
      var body = row[kTaskChatMessageBodyColumn]?.toString() ?? '';
      if (body.isEmpty) {
        body = row['content']?.toString() ??
            row['message']?.toString() ??
            row['message_text']?.toString() ??
            row['text']?.toString() ??
            '';
      }
      final rawCreated = row['created_at']?.toString();
      if (id == null ||
          id.isEmpty ||
          threadId == null ||
          threadId.isEmpty ||
          senderUserId == null ||
          senderUserId.isEmpty) {
        return null;
      }
      final createdAt =
          DateTime.tryParse(rawCreated ?? '')?.toUtc() ?? DateTime.now().toUtc();
      return TaskChatMessageVm(
        id: id,
        threadId: threadId,
        senderUserId: senderUserId,
        senderRole: senderRole,
        body: body,
        createdAt: createdAt,
        attachments: const [],
      );
    } catch (_) {
      return null;
    }
  }

  /// Reads first non-empty string among [keys] (PostgREST / legacy column names).
  static String? _rowString(Map<String, dynamic> row, List<String> keys) {
    for (final k in keys) {
      final v = row[k];
      if (v == null) continue;
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
    return null;
  }

  static String? _fileNameFromStoragePath(String path) {
    final i = path.lastIndexOf('/');
    if (i < 0 || i >= path.length - 1) return null;
    final s = path.substring(i + 1).trim();
    return s.isEmpty ? null : s;
  }

  static TaskChatAttachmentVm? attachmentFromRow(Map<String, dynamic> row) {
    try {
      final id = _rowString(row, const ['id']);
      final messageId = _rowString(row, const ['message_id', 'messageId']);
      var path = _rowString(
        row,
        const ['storage_path', 'storagePath', 'path', 'object_path'],
      );
      var name = _rowString(
        row,
        const [
          'file_name',
          'fileName',
          'filename',
          'name',
          'original_filename',
        ],
      );
      if (path != null && (name == null || name.isEmpty)) {
        name = _fileNameFromStoragePath(path);
      }
      if (id == null ||
          id.isEmpty ||
          messageId == null ||
          messageId.isEmpty ||
          path == null ||
          path.isEmpty ||
          name == null ||
          name.isEmpty) {
        return null;
      }
      final mime = _rowString(row, const ['mime_type', 'mimeType', 'content_type']);
      final bucketRaw = _rowString(row, const ['storage_bucket', 'storageBucket', 'bucket']);
      int? size;
      final sb = row['size_bytes'] ?? row['sizeBytes'];
      if (sb is num) size = sb.toInt();
      return TaskChatAttachmentVm(
        id: id,
        storagePath: path,
        fileName: name,
        mimeType: mime,
        sizeBytes: size,
        storageBucket: bucketRaw,
      );
    } catch (_) {
      return null;
    }
  }

  /// After [fetchMessages], keep attachment metadata we already had when the
  /// server list comes back empty for that row (RLS/cache lag / column quirks).
  static List<TaskChatMessageVm> mergeFetchedMessages(
    List<TaskChatMessageVm> previous,
    List<TaskChatMessageVm> fetched,
  ) {
    if (fetched.isEmpty) return previous;
    final prevById = {for (final m in previous) m.id: m};
    return [
      for (final n in fetched)
        n.attachments.isNotEmpty
            ? n
            : ((prevById[n.id]?.attachments.isNotEmpty ?? false)
                ? n.copyWith(attachments: prevById[n.id]!.attachments)
                : n),
    ];
  }

  static Future<List<TaskChatMessageVm>> fetchMessages(String threadId) async {
    final msgRes = await _client
        .from('task_chat_messages')
        .select()
        .eq('thread_id', threadId)
        .order('created_at', ascending: true);

    final list = msgRes as List<dynamic>? ?? const [];
    final messages = <TaskChatMessageVm>[];
    final idOrder = <String>[];
    for (final raw in list) {
      if (raw is! Map<String, dynamic>) continue;
      final m = messageFromRow(raw);
      if (m != null) {
        messages.add(m);
        idOrder.add(m.id);
      }
    }
    if (idOrder.isEmpty) return messages;

    final attRes = await _client
        .from('task_chat_attachments')
        .select()
        .inFilter('message_id', idOrder);

    final attList = attRes as List<dynamic>? ?? const [];
    final byMessage = <String, List<TaskChatAttachmentVm>>{};
    for (final raw in attList) {
      if (raw is! Map<String, dynamic>) continue;
      final a = attachmentFromRow(raw);
      final mid = _rowString(raw, const ['message_id', 'messageId']);
      if (a == null || mid == null) continue;
      byMessage.putIfAbsent(mid, () => []).add(a);
    }

    return [
      for (final m in messages)
        m.copyWith(attachments: byMessage[m.id] ?? const []),
    ];
  }

  /// Subscribe to new rows for [threadId]. Caller must [RealtimeChannel.unsubscribe] / removeChannel.
  static RealtimeChannel subscribeToNewMessages({
    required String threadId,
    required void Function(TaskChatMessageVm message) onInsert,
    void Function(String messageId, TaskChatAttachmentVm attachment)?
        onAttachmentInsert,
  }) {
    final channel = _client.channel('task_chat_$threadId');
    try {
      channel
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'task_chat_messages',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'thread_id',
              value: threadId,
            ),
            callback: (payload) async {
              final row = payload.newRecord;
              final m = messageFromRow(row);
              if (m == null) return;
              try {
                var withAtt = await _fetchAttachmentsForMessage(m);
                if (withAtt.attachments.isEmpty) {
                  await Future<void>.delayed(const Duration(milliseconds: 350));
                  withAtt = await _fetchAttachmentsForMessage(m);
                }
                onInsert(withAtt);
              } catch (e, st) {
                debugPrint('[TaskChat] realtime enrich failed $e\n$st');
                onInsert(m);
              }
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'task_chat_attachments',
            callback: (payload) async {
              if (onAttachmentInsert == null) return;
              final raw = payload.newRecord;
              final row = Map<String, dynamic>.from(raw);
              final att = attachmentFromRow(row);
              final mid = _rowString(row, const ['message_id', 'messageId']);
              if (att == null || mid == null) return;
              try {
                final msg = await _client
                    .from('task_chat_messages')
                    .select('id')
                    .eq('id', mid)
                    .eq('thread_id', threadId)
                    .maybeSingle();
                if (msg == null) return;
              } catch (e, st) {
                debugPrint('[TaskChat] attachment thread check $e\n$st');
                return;
              }
              onAttachmentInsert(mid, att);
            },
          )
          .subscribe();
    } catch (e, st) {
      debugPrint('[TaskChat] realtime subscribe failed $e\n$st');
    }
    return channel;
  }

  static Future<TaskChatMessageVm> _fetchAttachmentsForMessage(
    TaskChatMessageVm m,
  ) async {
    final attRes = await _client
        .from('task_chat_attachments')
        .select()
        .eq('message_id', m.id);
    final attList = attRes as List<dynamic>? ?? const [];
    final attachments = <TaskChatAttachmentVm>[];
    for (final raw in attList) {
      if (raw is! Map<String, dynamic>) continue;
      final a = attachmentFromRow(raw);
      if (a != null) attachments.add(a);
    }
    return m.copyWith(attachments: attachments);
  }

  static Future<TaskChatMessageVm> sendText({
    required String taskId,
    required String threadId,
    required String body,
    TaskChatSendDebugMeta? sendMeta,
  }) async {
    final trimmedTaskId = taskId.trim();
    if (trimmedTaskId.isEmpty) {
      throw TaskChatUserException(
        TaskChatUserCode.messageSendFailed,
        debugDetail: 'missing_task_id',
        technicalDetail:
            'table: task_chat_messages\noperation: insert\n'
            'reason: task_id is required (NOT NULL in DB); pass InspectorTaskSession.remoteTaskId',
      );
    }
    final trimmed = body.trim();
    final uid = requireChatActorUserId();
    final profile = await WorkerProfileService.fetchProfileForUserId(uid);
    if (profile == null) {
      throw TaskChatUserException(
        TaskChatUserCode.profileRequired,
        debugDetail: 'no_profiles_row',
        technicalDetail:
            'table: profiles\nlookup: id = auth.uid()\nauth.uid (client): $uid\n'
            'reason: no profiles row; chat insert trigger also requires profiles.role',
      );
    }

    final messageId = randomUuidV4();
    final meta = sendMeta ??
        TaskChatSendDebugMeta(
          taskId: trimmedTaskId,
          threadId: threadId,
          threadKnownBeforeEnsure: false,
        );
    debugPrint(
      '[TaskChat] sendText → table=task_chat_messages operation=insert '
      'payload_keys=id,thread_id,$kTaskChatMessageTaskIdColumn,$kTaskChatMessageBodyColumn '
      'message_id=$messageId thread_id=$threadId task_id=$trimmedTaskId '
      'thread_existed_before_ensure=${meta.threadKnownBeforeEnsure} '
      'auth.uid=$uid',
    );
    try {
      await _client.from('task_chat_messages').insert({
        'id': messageId,
        'thread_id': threadId,
        kTaskChatMessageTaskIdColumn: trimmedTaskId,
        kTaskChatMessageBodyColumn: trimmed,
      });
    } on TaskChatUserException {
      rethrow;
    } on PostgrestException catch (e) {
      throw _mapPostgrestSendFailure(
        e,
        table: 'task_chat_messages',
        operation: 'insert',
        payloadKeys: const [
          'id',
          'thread_id',
          kTaskChatMessageTaskIdColumn,
          kTaskChatMessageBodyColumn,
        ],
        meta: meta,
        authUid: uid,
      );
    }

    return _localMessageVmAfterInsert(
      messageId: messageId,
      threadId: threadId,
      body: trimmed,
      uid: uid,
      senderRole: profile.role,
    );
  }

  static String _safeFileSegment(String name) {
    return name
        .replaceAll(RegExp(r'[^\w\.\-]'), '_')
        .replaceAll(RegExp(r'_+'), '_');
  }

  static String? _inferContentType(String fileName, String? mimeType) {
    if (mimeType != null && mimeType.trim().isNotEmpty) {
      return mimeType.trim();
    }
    final lower = fileName.toLowerCase();
    final dot = lower.lastIndexOf('.');
    if (dot < 0 || dot >= lower.length - 1) return null;
    switch (lower.substring(dot + 1)) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
      case 'heif':
        return 'image/heic';
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'webm':
        return 'video/webm';
      case 'm4v':
        return 'video/x-m4v';
      case 'pdf':
        return 'application/pdf';
      default:
        return null;
    }
  }

  /// Maps MIME / filename to `task_chat_attachments.attachment_type`.
  static String inferAttachmentType(String? contentType, String fileName) {
    final mime = contentType?.toLowerCase().trim() ?? '';
    if (mime.startsWith('image/')) return kTaskChatAttachmentTypeImage;
    if (mime.startsWith('video/')) return kTaskChatAttachmentTypeVideo;
    if (mime == 'application/pdf') return kTaskChatAttachmentTypePdf;

    final lower = fileName.toLowerCase();
    final dot = lower.lastIndexOf('.');
    final ext = dot >= 0 && dot < lower.length - 1
        ? lower.substring(dot + 1)
        : '';
    if (const {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'}.contains(ext)) {
      return kTaskChatAttachmentTypeImage;
    }
    if (const {'mp4', 'mov', 'webm', 'm4v', '3gp'}.contains(ext)) {
      return kTaskChatAttachmentTypeVideo;
    }
    if (ext == 'pdf') return kTaskChatAttachmentTypePdf;
    return kTaskChatAttachmentTypeFile;
  }

  static Future<void> _removeStorageSilently(String path) async {
    try {
      await _client.storage.from(AppEnv.taskChatMediaBucket).remove([path]);
    } catch (_) {}
  }

  static Future<void> _deleteMessageIfEmptyBodyOnly(String messageId) async {
    try {
      await _client.from('task_chat_messages').delete().eq('id', messageId);
    } catch (_) {}
  }

  /// Inserts message, uploads to [AppEnv.taskChatMediaBucket], inserts attachment row.
  static Future<TaskChatMessageVm> sendWithLocalFile({
    required String taskId,
    required String threadId,
    required String body,
    required File file,
    required String fileName,
    required String? mimeType,
    TaskChatSendDebugMeta? sendMeta,
  }) async {
    final uid = requireChatActorUserId();
    final profile = await WorkerProfileService.fetchProfileForUserId(uid);
    if (profile == null) {
      throw TaskChatUserException(
        TaskChatUserCode.profileRequired,
        debugDetail: 'no_profiles_row',
        technicalDetail:
            'table: profiles\nlookup: id = auth.uid()\nauth.uid (client): $uid',
      );
    }

    final bytes = await file.readAsBytes();
    if (bytes.length > kTaskChatMaxAttachmentBytes) {
      throw TaskChatUserException(
        TaskChatUserCode.fileTooLarge,
        debugDetail: '${bytes.length} bytes',
        technicalDetail:
            'max_allowed_bytes: $kTaskChatMaxAttachmentBytes actual: ${bytes.length}',
      );
    }

    final caption = body.trim();
    final messageId = randomUuidV4();
    final meta = sendMeta ??
        TaskChatSendDebugMeta(
          taskId: taskId,
          threadId: threadId,
          threadKnownBeforeEnsure: false,
        );
    final trimmedTaskId = taskId.trim();
    if (trimmedTaskId.isEmpty) {
      throw TaskChatUserException(
        TaskChatUserCode.messageSendFailed,
        debugDetail: 'missing_task_id',
        technicalDetail:
            'table: task_chat_messages\noperation: insert (file caption row)\n'
            'reason: task_id required for NOT NULL column',
      );
    }
    debugPrint(
      '[TaskChat] sendWithLocalFile message insert → table=task_chat_messages '
      'payload_keys=id,thread_id,$kTaskChatMessageTaskIdColumn,$kTaskChatMessageBodyColumn '
      'message_id=$messageId task_id=$trimmedTaskId',
    );
    try {
      await _client.from('task_chat_messages').insert({
        'id': messageId,
        'thread_id': threadId,
        kTaskChatMessageTaskIdColumn: trimmedTaskId,
        kTaskChatMessageBodyColumn: caption,
      });
    } on TaskChatUserException {
      rethrow;
    } on PostgrestException catch (e) {
      throw _mapPostgrestSendFailure(
        e,
        table: 'task_chat_messages',
        operation: 'insert',
        payloadKeys: const [
          'id',
          'thread_id',
          kTaskChatMessageTaskIdColumn,
          kTaskChatMessageBodyColumn,
        ],
        meta: meta,
        authUid: uid,
      );
    }

    final m = _localMessageVmAfterInsert(
      messageId: messageId,
      threadId: threadId,
      body: caption,
      uid: uid,
      senderRole: profile.role,
    );

    final ts = DateTime.now().toUtc().millisecondsSinceEpoch;
    final safeName = _safeFileSegment(fileName);
    final path = 'tasks/$trimmedTaskId/$messageId/${ts}_$safeName';
    final contentType = _inferContentType(fileName, mimeType);

    try {
      await _client.storage.from(AppEnv.taskChatMediaBucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: false,
              contentType: contentType,
            ),
          );
    } on StorageException catch (e) {
      if (caption.isEmpty) {
        await _deleteMessageIfEmptyBodyOnly(messageId);
      }
      final tech = formatStorageExceptionTechnical(
        e,
        bucket: AppEnv.taskChatMediaBucket,
        operation: 'uploadBinary',
        pathShape: 'tasks/<task_id>/<message_id>/<ts>_<file>',
      );
      debugPrint('[TaskChat] Storage failure:\n$tech');
      final msg = e.message.toLowerCase();
      final sc = e.statusCode ?? '';
      if (msg.contains('bucket') ||
          msg.contains('not found') ||
          sc == '404' ||
          msg.contains('invalid bucket')) {
        throw TaskChatUserException(
          TaskChatUserCode.storageBucketMissing,
          debugDetail: e.message,
          technicalDetail: tech,
        );
      }
      if (msg.contains('policy') ||
          msg.contains('denied') ||
          msg.contains('forbidden') ||
          sc == '403') {
        throw TaskChatUserException(
          TaskChatUserCode.permissionDenied,
          debugDetail: e.message,
          technicalDetail: tech,
        );
      }
      throw TaskChatUserException(
        TaskChatUserCode.storageUploadFailed,
        debugDetail: e.message,
        technicalDetail: tech,
      );
    } catch (e, st) {
      if (caption.isEmpty) {
        await _deleteMessageIfEmptyBodyOnly(messageId);
      }
      if (e is TaskChatUserException) rethrow;
      throw TaskChatUserException(
        TaskChatUserCode.storageUploadFailed,
        debugDetail: '$e',
        technicalDetail: formatGenericExceptionTechnical(e, st),
      );
    }

    final resolvedMime = contentType ?? mimeType;
    final attachmentType = inferAttachmentType(resolvedMime, fileName);
    const attachmentPayloadKeys = [
      'message_id',
      'task_id',
      'uploaded_by',
      'attachment_type',
      'file_name',
      'storage_bucket',
      'storage_path',
      'mime_type',
      'size_bytes',
    ];
    try {
      debugPrint(
        '[TaskChat] attachment insert → table=task_chat_attachments '
        'payload_keys=${attachmentPayloadKeys.join(',')} '
        'attachment_type=$attachmentType bucket=${AppEnv.taskChatMediaBucket}',
      );
      await _client.from('task_chat_attachments').insert({
        'message_id': messageId,
        'task_id': trimmedTaskId,
        'uploaded_by': uid,
        'attachment_type': attachmentType,
        'file_name': fileName,
        'storage_bucket': AppEnv.taskChatMediaBucket,
        'storage_path': path,
        'mime_type': resolvedMime,
        'size_bytes': bytes.length,
      });
    } on PostgrestException catch (e) {
      await _removeStorageSilently(path);
      if (caption.isEmpty) {
        await _deleteMessageIfEmptyBodyOnly(messageId);
      }
      debugPrint(
        '[TaskChat] attachment insert failed (storage object may be removed): '
        '${e.code} ${e.message} details=${e.details}',
      );
      throw _mapPostgrestSendFailure(
        e,
        table: 'task_chat_attachments',
        operation: 'insert',
        payloadKeys: attachmentPayloadKeys,
        meta: meta,
        authUid: uid,
      );
    } catch (e, st) {
      await _removeStorageSilently(path);
      if (caption.isEmpty) {
        await _deleteMessageIfEmptyBodyOnly(messageId);
      }
      if (e is TaskChatUserException) rethrow;
      throw TaskChatUserException(
        TaskChatUserCode.attachmentMetadataFailed,
        debugDetail: '$e',
        technicalDetail: formatGenericExceptionTechnical(e, st),
      );
    }

    return _fetchAttachmentsForMessage(m);
  }
}

