import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/navigation/app_page_route.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/demo_task_public_state.dart';
import '../../../core/localization/language_controller.dart';
import '../chat/task_chat_attachment_picker.dart';
import '../chat/task_chat_controller.dart';
import '../data/inspector_task_session.dart';
import '../data/task_chat_service.dart';
import 'task_chat_image_compose.dart';
import 'widgets/task_flow_visual.dart';

String _taskChatErrorBody(TaskChatErrorKey? key, AppStrings s) {
  switch (key) {
    case TaskChatErrorKey.notRemoteTask:
      return s.taskChatNotAvailableOffline;
    case TaskChatErrorKey.timeout:
      return s.taskChatErrorTimeout;
    case TaskChatErrorKey.permission:
      return s.taskChatErrorUnavailable;
    case TaskChatErrorKey.profileRequired:
      return s.taskChatErrorProfileRequired;
    case TaskChatErrorKey.noAuthSession:
      return s.taskChatErrorNoAuthSession;
    case TaskChatErrorKey.rlsInsertDenied:
      return s.taskChatErrorRlsInsertDenied;
    case TaskChatErrorKey.createThreadFailed:
      return s.taskChatErrorCreateThreadFailed;
    case TaskChatErrorKey.sendFailed:
      return s.taskChatErrorDatabaseInsertFailed;
    case TaskChatErrorKey.storageFailed:
      return s.taskChatErrorStorageUnavailable;
    case TaskChatErrorKey.fileTooLarge:
      return s.taskChatErrorFileTooLarge;
    case TaskChatErrorKey.generic:
    case null:
      return s.taskChatUnableToLoad;
  }
}

String _taskChatUserMessageForFileSend(TaskChatUserException e, AppStrings s) {
  switch (e.code) {
    case TaskChatUserCode.notAuthenticated:
      return s.taskChatErrorNoAuthSession;
    case TaskChatUserCode.profileRequired:
      return s.taskChatErrorProfileRequired;
    case TaskChatUserCode.fileTooLarge:
      return s.taskChatErrorFileTooLarge;
    case TaskChatUserCode.threadCreateFailed:
      return s.taskChatErrorCreateThreadFailed;
    case TaskChatUserCode.permissionDenied:
    case TaskChatUserCode.rlsInsertDenied:
    case TaskChatUserCode.messageSendFailed:
    case TaskChatUserCode.messageReturnEmpty:
    case TaskChatUserCode.serverSchemaMismatch:
    case TaskChatUserCode.attachmentMetadataFailed:
    case TaskChatUserCode.storageUploadFailed:
    case TaskChatUserCode.storageBucketMissing:
      return s.taskChatFailedToSendFile;
  }
}

String _taskChatUserMessage(TaskChatUserException e, AppStrings s) {
  switch (e.code) {
    case TaskChatUserCode.notAuthenticated:
      return s.taskChatErrorNoAuthSession;
    case TaskChatUserCode.profileRequired:
      return s.taskChatErrorProfileRequired;
    case TaskChatUserCode.permissionDenied:
      return s.taskChatErrorUnavailable;
    case TaskChatUserCode.rlsInsertDenied:
      return s.taskChatErrorRlsInsertDenied;
    case TaskChatUserCode.threadCreateFailed:
      return s.taskChatErrorCreateThreadFailed;
    case TaskChatUserCode.serverSchemaMismatch:
      return s.taskChatErrorServerSchemaMismatch;
    case TaskChatUserCode.messageSendFailed:
    case TaskChatUserCode.messageReturnEmpty:
      return s.taskChatErrorDatabaseInsertFailed;
    case TaskChatUserCode.attachmentMetadataFailed:
      return s.taskChatErrorDatabaseInsertFailed;
    case TaskChatUserCode.storageUploadFailed:
      return s.taskChatErrorUploadFailed;
    case TaskChatUserCode.storageBucketMissing:
      return s.taskChatErrorStorageUnavailable;
    case TaskChatUserCode.fileTooLarge:
      return s.taskChatErrorFileTooLarge;
  }
}

class TaskChatScreen extends StatefulWidget {
  const TaskChatScreen({
    super.key,
    required this.session,
  });

  final InspectorTaskSession session;

  @override
  State<TaskChatScreen> createState() => _TaskChatScreenState();
}

class _TaskChatScreenState extends State<TaskChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  late final TaskChatController _chat;

  InspectorTaskSession get session => widget.session;

  @override
  void initState() {
    super.initState();
    _chat = TaskChatController(session: session);
    _chat.addListener(_onChatChanged);
  }

  void _onChatChanged() {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _chat.removeListener(_onChatChanged);
    _chat.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  DemoTaskPublicState _effectiveStatus() {
    final ex = session.assignmentExecutionStatusRaw;
    if (ex != null && ex.isNotEmpty) {
      return demoStateFromAssignmentExecution(ex);
    }
    return demoTaskStateFromRemoteInspectionStatus(session.remoteStatusRaw);
  }

  void _snack(String message, {Duration? duration}) {
    if (!mounted) return;
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration ?? const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        backgroundColor: cs.inverseSurface,
        content: Text(
          message,
          style: TextStyle(color: cs.onInverseSurface),
        ),
      ),
    );
  }

  void _presentTaskChatUserError(
    TaskChatUserException e,
    AppStrings s, {
    bool fileAttachmentFlow = false,
  }) {
    final userMsg = fileAttachmentFlow
        ? _taskChatUserMessageForFileSend(e, s)
        : _taskChatUserMessage(e, s);
    debugPrint('[TaskChat UI] localized: $userMsg');
    final tech = e.technicalDetail?.trim();
    if (tech != null && tech.isNotEmpty) {
      debugPrint('[TaskChat UI] technical:\n$tech');
    }
    _snack(userMsg);
  }

  String _fileExtension(String name) {
    final i = name.lastIndexOf('.');
    if (i < 0 || i >= name.length - 1) return '';
    return name.substring(i + 1).toLowerCase();
  }

  bool _isAllowedFile(String name, int size, String? mime) {
    if (size > kTaskChatMaxAttachmentBytes) return false;
    final m = mime?.toLowerCase() ?? '';
    if (m.startsWith('image/') || m.startsWith('video/')) return true;
    if (m == 'application/pdf') return true;
    final ext = _fileExtension(name);
    const ok = {
      'jpg',
      'jpeg',
      'png',
      'gif',
      'webp',
      'heic',
      'heif',
      'mp4',
      'mov',
      'webm',
      'm4v',
      '3gp',
      'pdf',
      'doc',
      'docx',
      'txt',
    };
    return ok.contains(ext);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  Future<void> _sendText() async {
    if (!_chat.canShowComposer ||
        _chat.phase != TaskChatPhase.ready ||
        _chat.sending) {
      return;
    }
    final s = context.strings;
    if (_textController.text.trim().isEmpty) return;
    try {
      final ok = await _chat.sendText(_textController.text);
      if (!mounted) return;
      if (ok) {
        _textController.clear();
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        return;
      }
      if (_chat.errorKey != null) {
        _snack(_taskChatErrorBody(_chat.errorKey, s));
      } else {
        _snack(s.taskChatErrorMessageSendFailed);
      }
    } on TaskChatUserException catch (e, st) {
      debugPrint('[TaskChat] sendText $e\n$st');
      if (!mounted) return;
      _presentTaskChatUserError(e, s);
    } catch (e, st) {
      debugPrint('[TaskChat] sendText $e\n$st');
      if (!mounted) return;
      _snack(s.taskChatErrorMessageSendFailed);
    }
  }

  /// Sends an attachment with [caption]. When [clearComposerOnSuccess] is true,
  /// the main composer field is cleared after a successful send (PDF / video / file).
  Future<bool> _sendFileWithCaption(
    File file,
    String displayName,
    String? mime, {
    required String caption,
    required bool clearComposerOnSuccess,
  }) async {
    if (!_chat.canShowComposer ||
        _chat.phase != TaskChatPhase.ready ||
        _chat.sending) {
      return false;
    }
    final s = context.strings;
    final len = await file.length();
    if (!_isAllowedFile(displayName, len, mime)) {
      if (len > kTaskChatMaxAttachmentBytes) {
        _snack(s.taskChatErrorFileTooLarge);
      } else {
        _snack(s.taskChatErrorUnsupportedFile);
      }
      return false;
    }

    try {
      final ok = await _chat.sendFile(
        file: file,
        displayName: displayName,
        mime: mime,
        caption: caption,
      );
      if (!mounted) return false;
      if (ok) {
        if (clearComposerOnSuccess) {
          _textController.clear();
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        return true;
      }
      if (_chat.errorKey != null) {
        _snack(_taskChatErrorBody(_chat.errorKey, s));
      } else {
        _snack(s.taskChatThreadNotFound);
      }
      return false;
    } on TaskChatUserException catch (e, st) {
      debugPrint('[TaskChat] sendFile $e\n$st');
      if (!mounted) return false;
      _presentTaskChatUserError(e, s, fileAttachmentFlow: true);
      return false;
    } catch (e, st) {
      debugPrint('[TaskChat] sendFile $e\n$st');
      if (!mounted) return false;
      _snack(s.taskChatFailedToSendFile);
      return false;
    }
  }

  Future<void> _sendFile(
    File file,
    String displayName,
    String? mime, {
    String caption = '',
  }) async {
    await _sendFileWithCaption(
      file,
      displayName,
      mime,
      caption: caption,
      clearComposerOnSuccess: true,
    );
  }

  Future<bool> _sendImageFromCompose(
    TaskChatPickedFile picked,
    String caption,
  ) {
    return _sendFileWithCaption(
      picked.file,
      picked.displayName,
      picked.mime,
      caption: caption,
      clearComposerOnSuccess: false,
    );
  }

  Future<void> _openPhotoCompose(TaskChatPickedFile? picked) async {
    if (picked == null || !mounted) return;
    final s = context.strings;
    final sent = await Navigator.of(context).push<bool>(
      AppPageRoute<bool>(
        fullscreenDialog: true,
        builder: (ctx) => TaskChatImageComposePage(
          imageFile: picked.file,
          strings: s,
          onSend: (caption) => _sendImageFromCompose(picked, caption),
        ),
      ),
    );
    if (sent == true && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    }
  }

  bool _isPermissionDenied(PlatformException e) {
    final c = e.code.toLowerCase();
    return c.contains('permission') ||
        c.contains('access_denied') ||
        c == 'photo_access_denied' ||
        c == 'camera_access_denied';
  }

  Future<void> _openAttachMenu() async {
    if (!_chat.canShowComposer ||
        _chat.phase != TaskChatPhase.ready ||
        _chat.sending) {
      return;
    }
    final s = context.strings;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  s.taskChatChooseAttachment,
                  style: Theme.of(ctx).textTheme.titleSmall,
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(s.taskChatPhotoFromGallery),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final p = await TaskChatAttachmentPicker.pickPhotoFromGallery();
                    await _openPhotoCompose(p);
                  } on PlatformException catch (e) {
                    if (!mounted) return;
                    _snack(_isPermissionDenied(e)
                        ? s.taskChatPermissionDenied
                        : s.taskChatFailedToSendFile);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: Text(s.taskChatTakePhoto),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final p = await TaskChatAttachmentPicker.takePhotoWithCamera();
                    await _openPhotoCompose(p);
                  } on PlatformException catch (e) {
                    if (!mounted) return;
                    _snack(_isPermissionDenied(e)
                        ? s.taskChatPermissionDenied
                        : s.taskChatFailedToSendFile);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf_outlined),
                title: Text(s.taskChatAttachPdfDocument),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final p = await TaskChatAttachmentPicker.pickPdf();
                    await _sendPicked(p);
                  } catch (e, st) {
                    debugPrint('[TaskChat] pick pdf $e\n$st');
                    if (!mounted) return;
                    _snack(context.strings.taskChatErrorUploadFailed);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam_outlined),
                title: Text(s.taskChatAttachVideo),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final p = await TaskChatAttachmentPicker.pickVideoFromGallery();
                    await _sendPicked(p);
                  } on PlatformException catch (e) {
                    if (!mounted) return;
                    _snack(_isPermissionDenied(e)
                        ? s.taskChatPermissionDenied
                        : s.taskChatErrorUploadFailed);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.attach_file_rounded),
                title: Text(s.taskChatAttachFile),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final p = await TaskChatAttachmentPicker.pickGenericFile();
                    await _sendPicked(p);
                  } catch (e, st) {
                    debugPrint('[TaskChat] pick file $e\n$st');
                    if (!mounted) return;
                    _snack(context.strings.taskChatErrorUploadFailed);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _sendPicked(TaskChatPickedFile? picked) async {
    if (picked == null || !mounted) return;
    await _sendFile(
      picked.file,
      picked.displayName,
      picked.mime,
      caption: _textController.text.trim(),
    );
  }

  Widget _buildComposer(
    ThemeData theme,
    ColorScheme colorScheme,
    AppStrings s, {
    required bool interactionEnabled,
  }) {
    return Material(
      color: theme.scaffoldBackgroundColor.withValues(alpha: 0.92),
      elevation: 0,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.only(bottom: 4),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                onPressed:
                    interactionEnabled && !_chat.sending ? _openAttachMenu : null,
                icon: const Icon(Icons.add_circle_outline_rounded),
                color: colorScheme.primary,
              ),
              Expanded(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: TextField(
                  controller: _textController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  enabled: interactionEnabled && !_chat.sending,
                  scrollPhysics: const BouncingScrollPhysics(),
                  decoration: InputDecoration(
                    hintText: s.taskChatMessageHint,
                    filled: true,
                    fillColor: colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                ),
                ),
              ),
              const SizedBox(width: 4),
              _chat.sending
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                    )
                  : IconButton.filled(
                      onPressed: interactionEnabled ? _sendText : null,
                      icon: const Icon(Icons.send_rounded),
                      tooltip: s.taskChatSend,
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = context.languageController;

    return ListenableBuilder(
      listenable: Listenable.merge([lang, _chat]),
      builder: (context, _) {
        final s = context.strings;
        final statusLabel = s.taskStateLabel(_effectiveStatus());
        final phase = _chat.phase;
        final errKey = _chat.errorKey;
        final effectiveStatus = _effectiveStatus();
        final statusAccent = effectiveStatus == DemoTaskPublicState.completedWithIssues
            ? colorScheme.error
            : colorScheme.primary;
        final composerReady =
            phase == TaskChatPhase.ready && _chat.canShowComposer;

        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: buildTaskFlowAppBar(
            context: context,
            title: Text(
              session.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (phase != TaskChatPhase.error)
                _TaskChatCompactContextBar(
                  session: session,
                  statusLabel: statusLabel,
                  statusAccent: statusAccent,
                  readOnly: _chat.readOnly,
                  s: s,
                  theme: theme,
                  colorScheme: colorScheme,
                ),
              if (_chat.readOnly)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Material(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              s.taskChatReadOnlyClosedTask,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (phase == TaskChatPhase.error)
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _taskChatErrorBody(errKey, s),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 18),
                          FilledButton(
                            onPressed: () => _chat.retry(),
                            child: Text(s.tasksRetry),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                if (phase == TaskChatPhase.loading)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: LinearProgressIndicator(
                      minHeight: 2,
                      backgroundColor:
                          colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      color: colorScheme.primary,
                    ),
                  ),
                Expanded(
                  child: _chat.messages.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  s.taskChatEmpty,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s.taskChatEmptySubtitle,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          key: ValueKey<String>(
                            _chat.threadId ?? 'task_chat_msgs',
                          ),
                          primary: false,
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                          itemCount: _chat.messages.length,
                          itemBuilder: (context, i) {
                            final msg = _chat.messages[i];
                            return _MessageBubble(
                              key: ValueKey<String>('msg_${msg.id}'),
                              message: msg,
                              strings: s,
                              theme: theme,
                              colorScheme: colorScheme,
                            );
                          },
                        ),
                ),
                if (_chat.canShowComposer) ...[
                  Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withValues(alpha: 0.35),
                  ),
                  _buildComposer(
                    theme,
                    colorScheme,
                    s,
                    interactionEnabled: composerReady,
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _TaskChatCompactContextBar extends StatelessWidget {
  const _TaskChatCompactContextBar({
    required this.session,
    required this.statusLabel,
    required this.statusAccent,
    required this.readOnly,
    required this.s,
    required this.theme,
    required this.colorScheme,
  });

  final InspectorTaskSession session;
  final String statusLabel;
  final Color statusAccent;
  final bool readOnly;
  final AppStrings s;
  final ThemeData theme;
  final ColorScheme colorScheme;

  String? _locationLine() {
    final site = session.remoteSiteName?.trim() ?? '';
    final area = session.remoteAreaName?.trim() ?? '';
    if (site.isEmpty && area.isEmpty) return null;
    if (site.isNotEmpty && area.isNotEmpty) return '$site · $area';
    return site.isNotEmpty ? site : area;
  }

  @override
  Widget build(BuildContext context) {
    final loc = _locationLine();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (loc != null) ...[
            Text(
              loc,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              TaskFlowStatusPill(
                label: statusLabel,
                accent: statusAccent,
              ),
              if (readOnly)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.9),
                    ),
                  ),
                  child: Text(
                    s.taskChatBadgeArchived,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    super.key,
    required this.message,
    required this.strings,
    required this.theme,
    required this.colorScheme,
  });

  final TaskChatMessageVm message;
  final AppStrings strings;
  final ThemeData theme;
  final ColorScheme colorScheme;

  String _timeLabel() {
    final l = message.createdAt.toLocal();
    final h = l.hour.toString().padLeft(2, '0');
    final m = l.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  bool _isMine() {
    final uid = TaskChatService.currentAuthUserId;
    return uid != null && uid == message.senderUserId;
  }

  String _roleCaption() {
    if (_isMine()) return strings.taskChatYou;
    if (message.senderRole == 'admin') return strings.taskChatSenderAdmin;
    return strings.taskChatSenderWorker;
  }

  @override
  Widget build(BuildContext context) {
    final mine = _isMine();
    final screenW = MediaQuery.sizeOf(context).width;
    final maxBubbleW = math.min(screenW * 0.78, 340.0);

    final bodyText = message.body.trim();
    final hasText = bodyText.isNotEmpty;
    final attachments = message.attachments;

    final fill = mine
        ? colorScheme.primaryContainer.withValues(alpha: 0.38)
        : colorScheme.surfaceContainerHighest.withValues(alpha: 0.92);
    final border = mine
        ? colorScheme.primary.withValues(alpha: 0.22)
        : colorScheme.outlineVariant.withValues(alpha: 0.45);

    final rMain = 18.0;
    final rTail = 5.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxBubbleW),
          child: DecoratedBox(
              decoration: BoxDecoration(
                color: fill,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(rMain),
                  topRight: Radius.circular(rMain),
                  bottomLeft: Radius.circular(mine ? rMain : rTail),
                  bottomRight: Radius.circular(mine ? rTail : rMain),
                ),
                border: Border.all(color: border, width: 1),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              _roleCaption(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.78),
                                fontWeight: FontWeight.w600,
                                letterSpacing: -0.12,
                                height: 1.1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _timeLabel(),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.55),
                              fontSize:
                                  (theme.textTheme.labelSmall?.fontSize ?? 11) *
                                      0.92,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (hasText) ...[
                      const SizedBox(height: 5),
                      Text(
                        bodyText,
                        textAlign: TextAlign.start,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                          height: 1.28,
                          letterSpacing: -0.15,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                    for (var i = 0; i < attachments.length; i++)
                      Padding(
                        padding: EdgeInsets.only(
                          top: (hasText || i > 0) ? 8 : 4,
                        ),
                        child: _AttachmentPreview(
                          key: ValueKey<String>(
                            'att_${message.id}_${attachments[i].id}',
                          ),
                          attachment: attachments[i],
                          strings: strings,
                          theme: theme,
                          colorScheme: colorScheme,
                          maxContentWidth: maxBubbleW - 22,
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }
}

class _AttachmentPreview extends StatelessWidget {
  const _AttachmentPreview({
    super.key,
    required this.attachment,
    required this.strings,
    required this.theme,
    required this.colorScheme,
    this.maxContentWidth,
  });

  final TaskChatAttachmentVm attachment;
  final AppStrings strings;
  final ThemeData theme;
  final ColorScheme colorScheme;
  final double? maxContentWidth;

  String _ext() {
    final i = attachment.fileName.lastIndexOf('.');
    if (i < 0) return '';
    return attachment.fileName.substring(i + 1).toLowerCase();
  }

  bool get _isImage {
    final m = attachment.mimeType?.toLowerCase() ?? '';
    if (m.startsWith('image/')) return true;
    final e = _ext();
    return const {'jpg', 'jpeg', 'png', 'gif', 'webp', 'heic', 'heif'}
        .contains(e);
  }

  bool get _isVideo {
    final m = attachment.mimeType?.toLowerCase() ?? '';
    if (m.startsWith('video/')) return true;
    final e = _ext();
    return const {'mp4', 'mov', 'webm'}.contains(e);
  }

  bool get _isPdf {
    final m = attachment.mimeType?.toLowerCase() ?? '';
    return m == 'application/pdf' || _ext() == 'pdf';
  }

  String _typeLabel() {
    if (_isImage) return strings.taskChatAttachmentImage;
    if (_isVideo) return strings.taskChatAttachmentVideo;
    if (_isPdf) return strings.taskChatAttachmentPdf;
    return strings.taskChatAttachmentFile;
  }

  Future<void> _open() async {
    try {
      final url = await TaskChatService.createSignedUrl(
        attachment.storagePath,
        bucket: attachment.storageBucket,
      );
      final uri = Uri.parse(url);
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) {
        debugPrint('[TaskChat] launchUrl failed');
      }
    } catch (e, st) {
      debugPrint('[TaskChat] signed url $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    final maxW = maxContentWidth;

    Widget constrainChild(Widget child) {
      if (maxW == null || !maxW.isFinite) return child;
      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: child,
      );
    }

    if (_isImage) {
      return constrainChild(
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _ChatSignedAttachmentImage(
            attachment: attachment,
            colorScheme: colorScheme,
            onOpen: _open,
          ),
        ),
      );
    }

    return constrainChild(
      Material(
        color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: _open,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Icon(
                  _isVideo
                      ? Icons.video_file_outlined
                      : _isPdf
                          ? Icons.picture_as_pdf_outlined
                          : Icons.insert_drive_file_outlined,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attachment.fileName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${_typeLabel()} · ${strings.taskChatAttachmentOpen}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.open_in_new_rounded,
                  color: colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// One signed-URL [Future] per widget instance — avoids new requests every
/// [ListView] rebuild (less jank / scroll subtree churn).
class _ChatSignedAttachmentImage extends StatefulWidget {
  const _ChatSignedAttachmentImage({
    required this.attachment,
    required this.colorScheme,
    required this.onOpen,
  });

  final TaskChatAttachmentVm attachment;
  final ColorScheme colorScheme;
  final VoidCallback onOpen;

  @override
  State<_ChatSignedAttachmentImage> createState() =>
      _ChatSignedAttachmentImageState();
}

class _ChatSignedAttachmentImageState extends State<_ChatSignedAttachmentImage> {
  late final Future<String> _urlFuture = TaskChatService.createSignedUrl(
    widget.attachment.storagePath,
    bucket: widget.attachment.storageBucket,
  );

  @override
  Widget build(BuildContext context) {
    final colorScheme = widget.colorScheme;
    return FutureBuilder<String>(
      future: _urlFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError || !snapshot.hasData) {
          return Container(
            height: 120,
            width: double.infinity,
            alignment: Alignment.center,
            color: colorScheme.surfaceContainerHigh,
            child: snapshot.hasError
                ? Icon(Icons.broken_image_outlined, color: colorScheme.error)
                : const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
          );
        }
        return GestureDetector(
          onTap: widget.onOpen,
          child: Image.network(
            snapshot.data!,
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            loadingBuilder: (ctx, child, prog) {
              if (prog == null) return child;
              return Container(
                height: 200,
                width: double.infinity,
                alignment: Alignment.center,
                color: colorScheme.surfaceContainerHigh,
                child: const CircularProgressIndicator(strokeWidth: 2),
              );
            },
          ),
        );
      },
    );
  }
}
