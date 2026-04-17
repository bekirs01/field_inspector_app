import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/localization/language_menu_button.dart';
import '../../../core/util/mock_uuid.dart';
import '../../tasks/data/inspector_task_session.dart';
import '../data/inspection_last_submit_cache.dart';
import '../data/inspection_object_resume_state.dart';
import '../data/inspection_queue_policy.dart';
import '../data/inspection_save_failure.dart';
import '../data/inspection_supabase_service.dart';
import '../data/pending_inspection_store.dart';
import '../data/remote_send_availability.dart';

class InspectionObjectScreen extends StatefulWidget {
  const InspectionObjectScreen({
    super.key,
    required this.session,
    required this.routeItemIndex,
    this.initialResume,
  });

  final InspectorTaskSession session;
  final int routeItemIndex;
  final InspectionObjectResumeState? initialResume;

  @override
  State<InspectionObjectScreen> createState() => _InspectionObjectScreenState();
}

class InspectionObjectResult {
  const InspectionObjectResult({
    required this.hadDefect,
    required this.routeItemIndex,
    this.photoCount = 0,
    this.audioCount = 0,
    this.pendingRemoteSync = false,
  });

  final bool hadDefect;
  final int routeItemIndex;
  final int photoCount;
  final int audioCount;

  /// True when the inspection was stored for automatic upload (offline / transport).
  final bool pendingRemoteSync;
}

class _InspectionObjectScreenState extends State<InspectionObjectScreen> {
  /// Stable keys for DB payload (`checklist` column); UI labels stay localized.
  static const _checklistItemKeys = [
    'visual_ok',
    'no_leaks',
    'no_noise',
    'access_clear',
  ];

  /// English-only labels stored in DB alongside [key] (not RU/TR UI strings).
  static const _checklistEnglishLabels = [
    'Visual condition OK',
    'No leaks detected',
    'No unusual noise',
    'Access area clear',
  ];

  final _noteController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _pressureController = TextEditingController();
  final _vibrationController = TextEditingController();
  final _defectDescriptionController = TextEditingController();
  final List<bool> _checklist = [false, false, false, false];
  bool _defectFound = false;
  int _severityIndex = 0;

  static const int _maxPhotos = 3;
  final List<XFile> _photos = [];
  final ImagePicker _imagePicker = ImagePicker();

  final AudioRecorder _voiceRecorder = AudioRecorder();
  bool _isVoiceRecording = false;
  String? _voiceFilePath;

  bool _isSaving = false;

  static const _numericKeyboard = TextInputType.numberWithOptions(
    decimal: true,
    signed: false,
  );

  String _taskIdForSave() {
    if (widget.session.isRemote &&
        (widget.session.remoteTaskId ?? '').isNotEmpty) {
      return widget.session.remoteTaskId!;
    }
    final m = widget.session.mockTaskIndex ?? 0;
    return mockUuidFromSeed('task|$m');
  }

  String _equipmentIdForSave() {
    final items = widget.session.items;
    if (widget.routeItemIndex >= 0 &&
        widget.routeItemIndex < items.length &&
        items[widget.routeItemIndex].id.isNotEmpty) {
      return items[widget.routeItemIndex].id;
    }
    if (widget.session.isRemote) {
      return '';
    }
    final m = widget.session.mockTaskIndex ?? 0;
    return mockUuidFromSeed('equip|$m|${widget.routeItemIndex}');
  }

  bool get _routeItemValid {
    final items = widget.session.items;
    final i = widget.routeItemIndex;
    return i >= 0 && i < items.length;
  }

  String _nonEmptyOr(String value, String fallback) {
    final t = value.trim();
    return t.isEmpty ? fallback : value;
  }

  @override
  void initState() {
    super.initState();
    final r = widget.initialResume;
    if (r == null) return;
    final n = _checklist.length;
    for (var i = 0; i < n && i < r.checklist.length; i++) {
      _checklist[i] = r.checklist[i];
    }
    _temperatureController.text = r.temperatureText;
    _pressureController.text = r.pressureText;
    _vibrationController.text = r.vibrationText;
    _noteController.text = r.comment;
    _defectFound = r.defectFound;
    _severityIndex = r.severityIndex.clamp(0, 2);
    _defectDescriptionController.text =
        r.defectFound ? r.defectDescription : '';
    for (final path in r.photoPaths) {
      if (_photos.length >= _maxPhotos) break;
      final trimmed = path.trim();
      if (trimmed.isEmpty) continue;
      final f = File(trimmed);
      if (f.existsSync()) {
        _photos.add(XFile(trimmed));
      }
    }
    final ap = r.audioPath?.trim();
    if (ap != null && ap.isNotEmpty && File(ap).existsSync()) {
      _voiceFilePath = ap;
    }
  }

  InspectorRouteItemRow _displayItemForUi(AppStrings s) {
    final items = widget.session.items;
    final i = widget.routeItemIndex;
    if (i >= 0 && i < items.length) {
      final raw = items[i];
      return InspectorRouteItemRow(
        id: raw.id,
        equipmentName: _nonEmptyOr(raw.equipmentName, s.tasksUntitledTask),
        equipmentLocation:
            _nonEmptyOr(raw.equipmentLocation, s.tasksScheduleNotSpecified),
        equipmentCode: raw.equipmentCode,
        sortOrder: raw.sortOrder,
      );
    }
    return InspectorRouteItemRow(
      id: '',
      equipmentName: s.tasksUntitledTask,
      equipmentLocation: s.tasksScheduleNotSpecified,
      equipmentCode: '',
      sortOrder: 0,
    );
  }

  @override
  void dispose() {
    if (_isVoiceRecording) {
      _voiceRecorder.stop();
    }
    _voiceRecorder.dispose();
    _noteController.dispose();
    _temperatureController.dispose();
    _pressureController.dispose();
    _vibrationController.dispose();
    _defectDescriptionController.dispose();
    super.dispose();
  }

  String _defectPriorityKey() {
    const keys = ['low', 'medium', 'high'];
    return keys[_severityIndex.clamp(0, 2)];
  }

  Future<void> _pickPhoto(BuildContext context) async {
    final s = context.strings;
    final messenger = ScaffoldMessenger.of(context);
    if (_photos.length >= _maxPhotos) {
      messenger.showSnackBar(
        SnackBar(content: Text(s.snackbarPhotoLimitReached)),
      );
      return;
    }
    try {
      final file = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (file == null) {
        messenger.showSnackBar(
          SnackBar(content: Text(s.snackbarPhotoPickerCancelled)),
        );
        return;
      }
      setState(() {
        _photos.add(file);
      });
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(s.snackbarPhotoPickerFailed)),
      );
    }
  }

  void _removePhotoAt(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  void _showPhotoPreview(BuildContext context, XFile file, int displayIndex) {
    final s = context.strings;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(s.mockPhotoTitle(displayIndex)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 4 / 3,
                  child: Image.file(File(file.path), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                s.photoPreviewDemoCaption,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(s.photoPreviewClose),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startVoice(BuildContext context) async {
    final s = context.strings;
    final messenger = ScaffoldMessenger.of(context);
    try {
      final permitted = await _voiceRecorder.hasPermission();
      if (!permitted) {
        debugPrint('[InspectionVoice] FAIL step=micPermission denied');
        messenger.showSnackBar(
          SnackBar(content: Text(s.snackbarMicrophoneDenied)),
        );
        return;
      }
      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/voice_${widget.routeItemIndex}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _voiceRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );
      if (!mounted) return;
      setState(() {
        _isVoiceRecording = true;
        _voiceFilePath = path;
      });
      debugPrint('[InspectionVoice] step=startRecording path=$path');
    } catch (e, st) {
      debugPrint('[InspectionVoice] FAIL step=startRecording error=$e\n$st');
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(s.errorUnknownSave)));
    }
  }

  Future<void> _stopVoice() async {
    final pathFromRecorder = await _voiceRecorder.stop();
    if (!mounted) return;
    final resolved = (pathFromRecorder != null && pathFromRecorder.isNotEmpty)
        ? pathFromRecorder
        : _voiceFilePath;
    final messenger = ScaffoldMessenger.of(context);
    final s = context.strings;
    if (resolved != null &&
        resolved.isNotEmpty &&
        File(resolved).existsSync()) {
      setState(() {
        _isVoiceRecording = false;
        _voiceFilePath = resolved;
      });
      debugPrint('[InspectionVoice] step=stopRecording ok path=$resolved');
      messenger.showSnackBar(SnackBar(content: Text(s.snackbarVoiceNoteAdded)));
    } else {
      debugPrint(
        '[InspectionVoice] FAIL step=stopRecording no file resolved=$resolved',
      );
      setState(() {
        _isVoiceRecording = false;
        _voiceFilePath = null;
      });
      messenger.showSnackBar(SnackBar(content: Text(s.errorRecordingNotFound)));
    }
  }

  Future<void> _deleteVoice() async {
    if (_isVoiceRecording) {
      await _voiceRecorder.stop();
    }
    final p = _voiceFilePath;
    if (p != null) {
      final f = File(p);
      if (await f.exists()) {
        await f.delete();
      }
    }
    if (!mounted) return;
    setState(() {
      _isVoiceRecording = false;
      _voiceFilePath = null;
    });
  }

  void _showOfflineQueuedSnackBar(AppStrings s, ScaffoldMessengerState m) {
    m.showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(s.inspectionOfflineQueuedTitle),
            const SizedBox(height: 4),
            Text(
              s.inspectionOfflineQueuedSubtitle,
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _persistQueuedAndPop({
    required BuildContext context,
    required AppStrings s,
    required ScaffoldMessengerState messenger,
    required String taskId,
    required String equipmentId,
    required List<Map<String, dynamic>> checklistForDb,
    required Map<String, dynamic> measurementsJson,
    required String defectDescription,
    required String defectPriority,
    required List<XFile> photos,
    required String? audioPathForUpload,
  }) async {
    try {
      await PendingInspectionStore.instance.enqueueFromScreenState(
        taskId: taskId,
        equipmentId: equipmentId,
        checklist: checklistForDb,
        measurements: measurementsJson,
        comment: _noteController.text,
        defectFound: _defectFound,
        defectDescription: defectDescription,
        defectPriority: defectPriority,
        photos: photos,
        audioFilePath: audioPathForUpload,
      );
    } catch (e, st) {
      debugPrint('[InspectionSubmit] FAIL enqueue local $e\n$st');
      if (!context.mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(s.errorSaveFailed)));
      return;
    }
    if (!context.mounted) return;
    unawaited(flushPendingInspectionSubmissions());
    _showOfflineQueuedSnackBar(s, messenger);
    Navigator.of(context).pop(
      InspectionObjectResult(
        hadDefect: _defectFound,
        routeItemIndex: widget.routeItemIndex,
        photoCount: photos.length,
        audioCount: audioPathForUpload != null ? 1 : 0,
        pendingRemoteSync: true,
      ),
    );
  }

  String _userMessageForSaveFailure(AppStrings s, InspectionSaveFailure f) {
    switch (f) {
      case InspectionSaveFailure.supabaseNotConfigured:
        return s.errorSupabaseNotConfigured;
      case InspectionSaveFailure.supabaseAnonymousSignInFailed:
        return s.errorAuthAnonymousFailed;
      case InspectionSaveFailure.missingTaskId:
        return s.errorMissingTaskId;
      case InspectionSaveFailure.missingEquipmentId:
        return s.errorMissingEquipmentId;
      case InspectionSaveFailure.photoUploadFailed:
        return s.errorPhotoUploadFailed;
      case InspectionSaveFailure.audioUploadFailed:
        return s.errorAudioUploadFailed;
      case InspectionSaveFailure.reportInsertFailed:
        return s.errorReportInsertFailed;
      case InspectionSaveFailure.reportReturningEmpty:
        return s.errorReportReturningEmpty;
      case InspectionSaveFailure.reportForeignKeyViolation:
        return s.errorReportForeignKey;
      case InspectionSaveFailure.reportRowLevelSecurityBlocked:
        return s.errorReportRlsBlocked;
      case InspectionSaveFailure.mediaInsertFailed:
        return s.errorMediaInsertFailed;
      case InspectionSaveFailure.mediaMetadataFailedAfterReportSaved:
        return s.errorMediaMetadataAfterReportOk;
      case InspectionSaveFailure.databaseSaveFailed:
        return s.errorDatabaseSaveFailed;
      case InspectionSaveFailure.recordingNotFound:
        return s.errorRecordingNotFound;
      case InspectionSaveFailure.permissionDenied:
        return s.errorPermissionDenied;
      case InspectionSaveFailure.localPhotoMissing:
      case InspectionSaveFailure.preparePayloadFailed:
        return s.errorSaveFailed;
      case InspectionSaveFailure.unknown:
        return s.errorUnknownSave;
    }
  }

  Future<void> _onSend(BuildContext context) async {
    if (_isSaving) return;
    final s = context.strings;
    final messenger = ScaffoldMessenger.of(context);

    if (!_routeItemValid) {
      messenger.showSnackBar(
        SnackBar(content: Text(s.inspectionRouteItemUnavailable)),
      );
      return;
    }

    final hasVoicePath = _voiceFilePath != null;
    debugPrint(
      '[InspectionSubmit] step=1_collectScreenState defect=$_defectFound '
      'photos=${_photos.length} recording=$_isVoiceRecording '
      'voicePathSet=$hasVoicePath',
    );

    final taskId = _taskIdForSave();
    final equipmentId = _equipmentIdForSave();
    if (taskId.trim().isEmpty) {
      debugPrint('[InspectionSubmit] FAIL step=2_validateIds missing taskId');
      messenger.showSnackBar(SnackBar(content: Text(s.errorMissingTaskId)));
      return;
    }
    if (equipmentId.trim().isEmpty) {
      debugPrint(
        '[InspectionSubmit] FAIL step=2_validateIds missing equipmentId',
      );
      messenger.showSnackBar(
        SnackBar(content: Text(s.errorMissingEquipmentId)),
      );
      return;
    }

    debugPrint(
      '[InspectionSubmit] step=2_validateIds ok taskLen=${taskId.length} '
      'equipmentLen=${equipmentId.length}',
    );

    if (_isVoiceRecording) {
      debugPrint(
        '[InspectionSubmit] FAIL step=7_prepareAudioFile recording still active',
      );
      messenger.showSnackBar(SnackBar(content: Text(s.errorSaveFailed)));
      return;
    }

    late final List<Map<String, dynamic>> checklistForDb;
    try {
      checklistForDb = List.generate(
        _checklist.length,
        (i) => <String, dynamic>{
          'key': _checklistItemKeys[i],
          'label': _checklistEnglishLabels[i],
          'checked': _checklist[i],
        },
      );
      debugPrint(
        '[InspectionSubmit] step=3_prepareChecklistPayload count=${_checklist.length} '
        'checklistForDb=$checklistForDb',
      );
    } catch (e, st) {
      debugPrint(
        '[InspectionSubmit] FAIL step=3_prepareChecklistPayload error=$e\n$st',
      );
      messenger.showSnackBar(SnackBar(content: Text(s.errorSaveFailed)));
      return;
    }

    late final Map<String, dynamic> measurementsJson;
    try {
      measurementsJson = {
        'temperature': _temperatureController.text.trim(),
        'pressure': _pressureController.text.trim(),
        'vibration': _vibrationController.text.trim(),
      };
      debugPrint('[InspectionSubmit] step=4_prepareMeasurementPayload ok');
    } catch (e, st) {
      debugPrint(
        '[InspectionSubmit] FAIL step=4_prepareMeasurementPayload error=$e\n$st',
      );
      messenger.showSnackBar(SnackBar(content: Text(s.errorSaveFailed)));
      return;
    }

    late final String defectDescription;
    late final String defectPriority;
    try {
      defectDescription = _defectFound ? _defectDescriptionController.text : '';
      defectPriority = _defectFound ? _defectPriorityKey() : '';
      debugPrint(
        '[InspectionSubmit] step=5_prepareDefectPayload defectFound=$_defectFound',
      );
    } catch (e, st) {
      debugPrint(
        '[InspectionSubmit] FAIL step=5_prepareDefectPayload error=$e\n$st',
      );
      messenger.showSnackBar(SnackBar(content: Text(s.errorSaveFailed)));
      return;
    }

    late final List<XFile> photos;
    try {
      photos = List<XFile>.from(_photos);
      debugPrint(
        '[InspectionSubmit] step=6_preparePhotoFiles count=${photos.length}',
      );
    } catch (e, st) {
      debugPrint(
        '[InspectionSubmit] FAIL step=6_preparePhotoFiles error=$e\n$st',
      );
      messenger.showSnackBar(SnackBar(content: Text(s.errorSaveFailed)));
      return;
    }

    late final String? audioPathForUpload;
    try {
      final p = _voiceFilePath?.trim();
      if (p != null && p.isNotEmpty && File(p).existsSync()) {
        audioPathForUpload = p;
      } else {
        if (p != null && p.isNotEmpty) {
          debugPrint(
            '[InspectionSubmit] step=7_prepareAudioFile stale path missing file=$p',
          );
        }
        audioPathForUpload = null;
      }
      debugPrint(
        '[InspectionSubmit] step=7_prepareAudioFile pathForUpload=${audioPathForUpload != null}',
      );
    } catch (e, st) {
      debugPrint(
        '[InspectionSubmit] FAIL step=7_prepareAudioFile error=$e\n$st',
      );
      messenger.showSnackBar(SnackBar(content: Text(s.errorSaveFailed)));
      return;
    }

    final supabaseReady = InspectionSupabaseService.isSupabaseClientReady();
    final sessionPresent = InspectionSupabaseService.authSessionPresent();
    debugPrint(
      '[InspectionSubmit] preSendSummary taskId=$taskId '
      'equipmentId=$equipmentId '
      'checklist=$checklistForDb measurements=$measurementsJson '
      'defect={found:$_defectFound, description:$defectDescription, priority:${_defectFound ? defectPriority : "low"}} '
      'photoCount=${photos.length} audioPath=${audioPathForUpload ?? "null"} '
      'supabaseInitialized=$supabaseReady authSessionPresent=$sessionPresent',
    );

    setState(() => _isSaving = true);
    try {
      final onlineHint = await quickInternetLookupHint();
      if (!supabaseReady || !onlineHint) {
        debugPrint(
          '[InspectionSubmit] queue path supabaseReady=$supabaseReady '
          'onlineHint=$onlineHint',
        );
        if (!context.mounted) return;
        await _persistQueuedAndPop(
          context: context,
          s: s,
          messenger: messenger,
          taskId: taskId,
          equipmentId: equipmentId,
          checklistForDb: checklistForDb,
          measurementsJson: measurementsJson,
          defectDescription: defectDescription,
          defectPriority: defectPriority,
          photos: photos,
          audioPathForUpload: audioPathForUpload,
        );
        return;
      }

      debugPrint('[InspectionSubmit] remoteFlowStart sendPrimary');
      await InspectionSupabaseService.instance.saveInspectionCompletion(
        taskId: taskId,
        equipmentId: equipmentId,
        checklist: checklistForDb,
        measurements: measurementsJson,
        comment: _noteController.text,
        defectFound: _defectFound,
        defectDescription: defectDescription,
        defectPriority: defectPriority,
        photos: photos,
        audioFilePath: audioPathForUpload,
      );
      if (!context.mounted) return;
      InspectionLastSubmitCache.instance.put(
        storeKey: widget.session.storeKey,
        routeItemIndex: widget.routeItemIndex,
        state: InspectionObjectResumeState(
          checklist: List<bool>.from(_checklist),
          temperatureText: _temperatureController.text,
          pressureText: _pressureController.text,
          vibrationText: _vibrationController.text,
          comment: _noteController.text,
          defectFound: _defectFound,
          defectDescription: _defectDescriptionController.text,
          severityIndex: _severityIndex,
          photoPaths: photos.map((p) => p.path).toList(),
          audioPath: audioPathForUpload,
        ),
      );
      debugPrint(
        '[InspectionSubmit] step=12_updateRouteProgress ok routeItemIndex=${widget.routeItemIndex}',
      );
      messenger.showSnackBar(SnackBar(content: Text(s.snackbarUploadSuccess)));
      Navigator.of(context).pop(
        InspectionObjectResult(
          hadDefect: _defectFound,
          routeItemIndex: widget.routeItemIndex,
          photoCount: photos.length,
          audioCount: audioPathForUpload != null ? 1 : 0,
        ),
      );
    } on InspectionSaveException catch (e, st) {
      debugPrint('[InspectionSubmit] FAIL remote ${e.toString()}\n$st');
      if (!context.mounted) return;
      if (shouldQueueInspectionAfterFailure(e)) {
        await _persistQueuedAndPop(
          context: context,
          s: s,
          messenger: messenger,
          taskId: taskId,
          equipmentId: equipmentId,
          checklistForDb: checklistForDb,
          measurementsJson: measurementsJson,
          defectDescription: defectDescription,
          defectPriority: defectPriority,
          photos: photos,
          audioPathForUpload: audioPathForUpload,
        );
      } else {
        messenger.showSnackBar(
          SnackBar(content: Text(_userMessageForSaveFailure(s, e.failure))),
        );
      }
    } catch (e, st) {
      debugPrint('[InspectionSubmit] FAIL remote unexpected error=$e\n$st');
      if (!context.mounted) return;
      if (inspectionTransportLooksLikely(e)) {
        await _persistQueuedAndPop(
          context: context,
          s: s,
          messenger: messenger,
          taskId: taskId,
          equipmentId: equipmentId,
          checklistForDb: checklistForDb,
          measurementsJson: measurementsJson,
          defectDescription: defectDescription,
          defectPriority: defectPriority,
          photos: photos,
          audioPathForUpload: audioPathForUpload,
        );
      } else {
        messenger.showSnackBar(SnackBar(content: Text(s.errorUnknownSave)));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  InputDecoration _measurementFieldDecoration(
    ThemeData theme,
    ColorScheme colorScheme,
    AppStrings s,
    String unit,
  ) {
    return InputDecoration(
      hintText: s.hintMeasurementValue,
      suffixText: unit,
      filled: true,
      fillColor: colorScheme.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Widget _measurementField({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required AppStrings s,
    required String label,
    required String unit,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: _numericKeyboard,
            textInputAction: TextInputAction.next,
            decoration: _measurementFieldDecoration(
              theme,
              colorScheme,
              s,
              unit,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _checklistLabels(AppStrings s) {
    return [
      s.checklistItemVisualOk,
      s.checklistItemNoLeaks,
      s.checklistItemNoNoise,
      s.checklistItemAccessClear,
    ];
  }

  Widget _voiceSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    AppStrings s,
  ) {
    final hasFile = _voiceFilePath != null && !_isVoiceRecording;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s.voiceNoteSectionTitle,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (!_isVoiceRecording)
              OutlinedButton(
                onPressed: hasFile ? null : () => _startVoice(context),
                child: Text(s.voiceStartRecording),
              ),
            if (_isVoiceRecording)
              FilledButton(
                onPressed: _stopVoice,
                child: Text(s.voiceStopRecording),
              ),
            TextButton(
              onPressed: (_voiceFilePath == null && !_isVoiceRecording)
                  ? null
                  : _deleteVoice,
              child: Text(s.voiceDeleteRecording),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          _isVoiceRecording
              ? s.voiceStateRecording
              : hasFile
              ? s.voiceStateRecorded
              : '',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = context.languageController;

    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        final s = context.strings;
        final labels = _checklistLabels(s);
        final item = _displayItemForUi(s);
        final taskTitle = widget.session.title;

        final isEdit = widget.initialResume != null;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              isEdit ? s.inspectionObjectEditTitle : s.inspectionObjectAppTitle,
            ),
            actions: const [LanguageMenuButton()],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  children: [
                    if (isEdit) ...[
                      Card(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.35,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Text(
                            s.editResultBannerHint,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (!_routeItemValid) ...[
                      Card(
                        color: colorScheme.errorContainer,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            s.inspectionRouteItemUnavailable,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.labelObject,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.equipmentName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.labelZone,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.equipmentLocation,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.labelEquipmentCode,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _nonEmptyOr(
                                item.equipmentCode,
                                s.tasksScheduleNotSpecified,
                              ),
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.labelTask,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              taskTitle,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.labelStatus,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              s.statusInProgress,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      s.sectionChecklist,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < labels.length; i++)
                            CheckboxListTile(
                              value: _checklist[i],
                              onChanged: (v) {
                                setState(() {
                                  _checklist[i] = v ?? false;
                                });
                              },
                              title: Text(
                                labels[i],
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      s.sectionMeasurements,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _measurementField(
                              theme: theme,
                              colorScheme: colorScheme,
                              s: s,
                              label: s.labelMeasurementTemperature,
                              unit: s.unitCelsius,
                              controller: _temperatureController,
                            ),
                            _measurementField(
                              theme: theme,
                              colorScheme: colorScheme,
                              s: s,
                              label: s.labelMeasurementPressure,
                              unit: s.unitPressureBar,
                              controller: _pressureController,
                            ),
                            _measurementField(
                              theme: theme,
                              colorScheme: colorScheme,
                              s: s,
                              label: s.labelMeasurementVibration,
                              unit: s.unitVibrationMmS,
                              controller: _vibrationController,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      s.sectionDefect,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SwitchListTile(
                              title: Text(
                                s.defectToggleLabel,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              value: _defectFound,
                              onChanged: (v) {
                                setState(() {
                                  _defectFound = v;
                                });
                              },
                            ),
                            if (_defectFound)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  0,
                                  16,
                                  12,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.labelDefectDescription,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: _defectDescriptionController,
                                      minLines: 2,
                                      maxLines: 4,
                                      decoration: InputDecoration(
                                        hintText: s.hintDefectDescription,
                                        filled: true,
                                        fillColor: colorScheme.surface,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.all(
                                          16,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Text(
                                      s.labelDefectPriority,
                                      style: theme.textTheme.labelLarge
                                          ?.copyWith(
                                            color: colorScheme.onSurface,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        ChoiceChip(
                                          label: Text(s.priorityLow),
                                          selected: _severityIndex == 0,
                                          onSelected: (_) {
                                            setState(() => _severityIndex = 0);
                                          },
                                        ),
                                        ChoiceChip(
                                          label: Text(s.priorityMedium),
                                          selected: _severityIndex == 1,
                                          onSelected: (_) {
                                            setState(() => _severityIndex = 1);
                                          },
                                        ),
                                        ChoiceChip(
                                          label: Text(s.priorityHigh),
                                          selected: _severityIndex == 2,
                                          onSelected: (_) {
                                            setState(() => _severityIndex = 2);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: _voiceSection(
                          context,
                          theme,
                          colorScheme,
                          s,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      s.sectionPhotoEvidence,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton(
                              onPressed: _photos.length >= _maxPhotos
                                  ? null
                                  : () => _pickPhoto(context),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(s.addPhotoButton),
                            ),
                            if (_photos.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              for (var i = 0; i < _photos.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: colorScheme.outlineVariant,
                                      ),
                                    ),
                                    child: InkWell(
                                      onTap: () => _showPhotoPreview(
                                        context,
                                        _photos[i],
                                        i + 1,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.file(
                                                File(_photos[i].path),
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    s.mockPhotoTitle(i + 1),
                                                    style: theme
                                                        .textTheme
                                                        .titleSmall
                                                        ?.copyWith(
                                                          color: colorScheme
                                                              .onSurface,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    s.photoItemSubtitleLocal,
                                                    style: theme
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: colorScheme
                                                              .onSurfaceVariant,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  _removePhotoAt(i),
                                              child: Text(s.removePhotoButton),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      s.sectionNote,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _noteController,
                      minLines: 3,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: s.noteHint,
                        filled: true,
                        fillColor: colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: FilledButton(
                  onPressed: (_isSaving ||
                          !_routeItemValid ||
                          _isVoiceRecording)
                      ? null
                      : () => _onSend(context),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isSaving
                      ? Text(s.inspectionSendingLabel)
                      : Text(s.inspectionSendButton),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
