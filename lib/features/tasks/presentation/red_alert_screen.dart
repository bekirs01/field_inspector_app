import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_controller.dart';
import '../data/equipment_red_alert_service.dart'
    show EquipmentRedAlertException, EquipmentRedAlertService;
import '../data/inspector_task_session.dart';
import '../data/red_alert_machine_catalog.dart';
import 'widgets/task_flow_visual.dart';

class RedAlertScreen extends StatefulWidget {
  const RedAlertScreen({
    super.key,
    this.prefillSession,
  });

  final InspectorTaskSession? prefillSession;

  @override
  State<RedAlertScreen> createState() => _RedAlertScreenState();
}

class _RedAlertScreenState extends State<RedAlertScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  List<RedAlertMachineOption> _options = [];
  String? _selectedEquipmentId;
  bool _loadingCatalog = true;
  bool _submitting = false;

  RedAlertMachineOption? get _selected {
    final id = _selectedEquipmentId;
    if (id == null) return null;
    for (final o in _options) {
      if (o.equipmentId == id) return o;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _loadCatalog();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCatalog() async {
    setState(() {
      _loadingCatalog = true;
    });
    try {
      final list = await RedAlertMachineCatalog.loadOptions();
      if (!mounted) return;
      setState(() {
        _options = list;
        _loadingCatalog = false;
      });
      _applyPrefill();
    } catch (e, st) {
      debugPrint('[RedAlertScreen] catalog $e\n$st');
      if (!mounted) return;
      setState(() {
        _options = [];
        _loadingCatalog = false;
      });
    }
  }

  void _applyPrefill() {
    final sess = widget.prefillSession;
    if (sess == null || !sess.isRemote) return;
    final tid = sess.remoteTaskId?.trim();
    if (tid == null || tid.isEmpty) return;
    for (final o in _options) {
      if (o.taskId == tid) {
        setState(() => _selectedEquipmentId = o.equipmentId);
        return;
      }
    }
  }

  String _errorMessage(AppStrings s, String code) {
    switch (code) {
      case 'no_auth_session':
        return s.redAlertErrorNoAuth;
      case 'not_ready':
        return s.redAlertErrorNotReady;
      case 'profile_missing':
        return s.redAlertErrorProfileMissing;
      case 'invalid_machine':
        return s.redAlertErrorInvalidMachine;
      case 'validation_title':
        return s.redAlertErrorShortReason;
      case 'rls_denied':
        return s.redAlertErrorRlsDenied;
      case 'schema_mismatch':
        return s.redAlertErrorSchemaMismatch;
      case 'network':
      case 'insert_failed':
        return s.redAlertErrorSendFailed;
      default:
        return s.redAlertErrorSendFailed;
    }
  }

  Future<void> _pickMachine(BuildContext context) async {
    final s = context.strings;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final query = ValueNotifier<String>('');
    try {
      final picked = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) {
          return SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(ctx).bottom,
              ),
              child: StatefulBuilder(
                builder: (ctx, setModal) {
                  final sheetH = MediaQuery.sizeOf(ctx).height * 0.58;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                        child: Text(
                          s.redAlertSelectMachine,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: s.redAlertMachineSearchHint,
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onChanged: (v) {
                            query.value = v;
                            setModal(() {});
                          },
                        ),
                      ),
                      SizedBox(
                        height: sheetH,
                        child: ValueListenableBuilder<String>(
                          valueListenable: query,
                          builder: (context, q, _) {
                            final ql = q.toLowerCase().trim();
                            final filtered = ql.isEmpty
                                ? _options
                                : _options.where((o) {
                                    final hay =
                                        '${o.equipmentName} ${o.subtitle(s)} ${o.equipmentId}'
                                            .toLowerCase();
                                    return hay.contains(ql);
                                  }).toList();
                            if (filtered.isEmpty) {
                              return Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text(
                                  s.redAlertNoMachinesFound,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              );
                            }
                            return ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final o = filtered[i];
                                return ListTile(
                                  title: Text(
                                    o.equipmentName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Text(
                                    o.subtitle(s),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: () =>
                                      Navigator.of(ctx).pop(o.equipmentId),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          );
        },
      );
      if (picked != null && mounted) {
        setState(() => _selectedEquipmentId = picked);
      }
    } finally {
      query.dispose();
    }
  }

  Future<void> _confirmAndSend(BuildContext context) async {
    final s = context.strings;
    final messenger = ScaffoldMessenger.of(context);

    if (!EquipmentRedAlertService.isReady()) {
      messenger.showSnackBar(SnackBar(content: Text(s.redAlertErrorNotReady)));
      return;
    }

    final machine = _selected;
    if (machine == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(s.redAlertChooseMachineFirst)),
      );
      return;
    }

    final title = _titleController.text.trim();
    if (title.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(s.redAlertErrorShortReason)),
      );
      return;
    }

    final desc = _descriptionController.text.trim();

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final th = Theme.of(ctx);
        final cs = th.colorScheme;
        return AlertDialog(
          backgroundColor: cs.surfaceContainerHigh,
          title: Text(s.redAlertConfirmTitle),
          content: Text(
            s.redAlertConfirmBody,
            style: th.textTheme.bodyMedium?.copyWith(height: 1.35),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(s.redAlertCancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
                foregroundColor: cs.onError,
              ),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(s.redAlertConfirmSend),
            ),
          ],
        );
      },
    );

    if (ok != true || !context.mounted) return;

    setState(() => _submitting = true);
    try {
      await EquipmentRedAlertService.submitCriticalAlert(
        machine: machine,
        title: title,
        description: desc,
      );
      if (!context.mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final th = Theme.of(ctx);
          final cs = th.colorScheme;
          return AlertDialog(
            backgroundColor: cs.surfaceContainerHigh,
            title: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: cs.primary, size: 28),
                const SizedBox(width: 10),
                Expanded(child: Text(s.redAlertSuccessTitle)),
              ],
            ),
            content: Text(
              s.redAlertSuccessBody,
              style: th.textTheme.bodyMedium?.copyWith(height: 1.35),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(s.redAlertSuccessDone),
              ),
            ],
          );
        },
      );
      if (!context.mounted) return;
      Navigator.of(context).pop();
    } on EquipmentRedAlertException catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_errorMessage(s, e.code))),
      );
    } catch (e, st) {
      debugPrint('[RedAlertScreen] submit $e\n$st');
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(s.redAlertErrorSendFailed)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
        final sel = _selected;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: buildTaskFlowAppBar(
            context: context,
            title: Text(
              s.redAlertScreenTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: _loadingCatalog
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(strokeWidth: 2.5),
                      const SizedBox(height: 16),
                      Text(
                        s.redAlertLoadingCatalog,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : _options.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.precision_manufacturing_outlined,
                              size: 48,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.redAlertCatalogEmpty,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _loadCatalog,
                              icon: const Icon(Icons.refresh_rounded),
                              label: Text(s.tasksRetry),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: colorScheme.error,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        s.redAlertIntroTitle,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  s.redAlertIntroBody,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.redAlertSelectMachine.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 0.9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          color: colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.65),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => _pickMachine(context),
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                14,
                                12,
                                14,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          sel?.equipmentName ??
                                              s.redAlertMachineHint,
                                          style: theme.textTheme.titleSmall
                                              ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: sel == null
                                                ? colorScheme.onSurfaceVariant
                                                : colorScheme.onSurface,
                                          ),
                                        ),
                                        if (sel != null) ...[
                                          const SizedBox(height: 4),
                                          Text(
                                            sel.subtitle(s),
                                            style: theme.textTheme.bodySmall
                                                ?.copyWith(
                                              color: colorScheme
                                                  .onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: colorScheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (widget.prefillSession != null &&
                            widget.prefillSession!.isRemote) ...[
                          const SizedBox(height: 8),
                          Text(
                            s.redAlertPrefillHint,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Text(
                          s.redAlertShortReasonLabel.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 0.9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          maxLines: 2,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            hintText: s.redAlertShortReasonHint,
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          s.redAlertDescriptionLabel.toUpperCase(),
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 0.9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          minLines: 4,
                          maxLines: 10,
                          decoration: InputDecoration(
                            hintText: s.redAlertDescriptionHint,
                            alignLabelWithHint: true,
                            filled: true,
                            fillColor: colorScheme.surfaceContainerHighest,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.error.withValues(
                                  alpha: 0.35,
                                ),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: colorScheme.error,
                                foregroundColor: colorScheme.onError,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              onPressed: _submitting
                                  ? null
                                  : () => _confirmAndSend(context),
                              child: _submitting
                                  ? SizedBox(
                                      height: 22,
                                      width: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: colorScheme.onError,
                                      ),
                                    )
                                  : Text(
                                      s.redAlertSendButton,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
        );
      },
    );
  }
}
