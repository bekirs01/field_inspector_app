import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/localization/language_menu_button.dart';
import '../data/equipment_nodes_repository.dart';
import '../data/inspection_task_request_service.dart';
import 'widgets/equipment_nodes_picker.dart';
import 'widgets/task_flow_visual.dart';

class TaskRequestCreateScreen extends StatefulWidget {
  const TaskRequestCreateScreen({
    super.key,
    this.embedInMainShell = false,
  });

  final bool embedInMainShell;

  @override
  State<TaskRequestCreateScreen> createState() =>
      _TaskRequestCreateScreenState();
}

class _TaskRequestCreateScreenState extends State<TaskRequestCreateScreen> {
  final _issueSummary = TextEditingController();
  final _detailedDescription = TextEditingController();
  int _priorityIndex = 0;
  int _requestTypeIndex = 0;
  DateTime? _preferredDueDate;
  bool _submitting = false;

  EquipmentNodesQueryResult? _forest;
  bool _loadingForest = true;
  Object? _forestError;

  final Set<String> _selectedEquipmentIds = <String>{};

  static const _requestTypeKeys = [
    'inspection',
    'maintenance',
    'defect',
    'repair',
  ];

  @override
  void initState() {
    super.initState();
    _loadForest();
  }

  Future<void> _loadForest() async {
    setState(() {
      _loadingForest = true;
      _forestError = null;
    });
    try {
      final f = await EquipmentNodesRepository.fetchForest();
      if (!mounted) return;
      setState(() {
        _forest = f;
        _loadingForest = false;
        _forestError = null;
      });
    } catch (e, st) {
      debugPrint('[TaskRequest] equipment forest load failed: $e\n$st');
      if (!mounted) return;
      setState(() {
        _forestError = e;
        _loadingForest = false;
      });
    }
  }

  @override
  void dispose() {
    _issueSummary.dispose();
    _detailedDescription.dispose();
    super.dispose();
  }

  String _priorityKey() {
    const keys = ['low', 'medium', 'high'];
    return keys[_priorityIndex.clamp(0, 2)];
  }

  String _requestTypeKey() =>
      _requestTypeKeys[_requestTypeIndex.clamp(0, _requestTypeKeys.length - 1)];

  String? _preferredDueIso() {
    final d = _preferredDueDate;
    if (d == null) return null;
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  String _pickedDateLabel(AppStrings s, DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    switch (s.language) {
      case AppLanguage.ru:
      case AppLanguage.tr:
        return '$dd.$mm.$yyyy';
      case AppLanguage.en:
        return '$mm/$dd/$yyyy';
    }
  }

  String _errorMessage(AppStrings s, String code) {
    switch (code) {
      case 'no_worker':
        return s.taskRequestErrorNoWorker;
      case 'not_ready':
        return s.taskRequestErrorNotReady;
      case 'insert_failed':
        return s.taskRequestErrorInsert;
      default:
        return s.taskRequestErrorInsert;
    }
  }

  String _buildTitle(AppStrings s) {
    final issue = _issueSummary.text.trim();
    if (issue.isNotEmpty) {
      return issue.length > 120 ? '${issue.substring(0, 117)}…' : issue;
    }
    return s.taskRequestAutoTitleInspection(_selectedEquipmentIds.length);
  }

  String _composeDescriptionBody(AppStrings s, SiteAreaDerived derived) {
    final parts = <String>[];
    final detail = _detailedDescription.text.trim();
    if (detail.isNotEmpty) parts.add(detail);
    if (derived.hasMultipleSites || derived.hasMultipleAreas) {
      parts.add(s.taskRequestDescriptionMultipleLocationsNote);
    }
    parts.add(s.taskRequestEquipmentListHeading);
    final ids = _selectedEquipmentIds.toList()..sort();
    final byId = _forest!.byId;
    for (final id in ids) {
      final row = byId[id];
      if (row != null) {
        parts.add('• ${row.name} ($id)');
      }
    }
    return parts.join('\n\n');
  }

  void _clearForm() {
    _issueSummary.clear();
    _detailedDescription.clear();
    setState(() {
      _priorityIndex = 0;
      _requestTypeIndex = 0;
      _preferredDueDate = null;
      _selectedEquipmentIds.clear();
    });
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final s = context.strings;
    final now = DateTime.now();
    final initial = _preferredDueDate ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      helpText: s.labelRequestPreferredDueDate,
    );
    if (picked != null && mounted) {
      setState(() => _preferredDueDate = picked);
    }
  }

  Future<void> _submit(BuildContext context) async {
    final s = context.strings;
    final messenger = ScaffoldMessenger.of(context);

    if (_forest == null || _loadingForest) {
      messenger.showSnackBar(
        SnackBar(content: Text(s.taskRequestEquipmentLoading)),
      );
      return;
    }
    if (_forestError != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(s.taskRequestEquipmentLoadFailed)),
      );
      return;
    }
    if (_selectedEquipmentIds.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(s.taskRequestValidationNeedEquipment)),
      );
      return;
    }
    if (_issueSummary.text.trim().isEmpty &&
        _detailedDescription.text.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(s.taskRequestValidationNeedIssueOrDetail)),
      );
      return;
    }

    final derived = SiteAreaDerived.fromSelection(
      _selectedEquipmentIds,
      _forest!.byId,
    );
    final title = _buildTitle(s);
    final descriptionBody = _composeDescriptionBody(s, derived);
    final equipmentIds = _selectedEquipmentIds.toList()..sort();

    setState(() => _submitting = true);
    try {
      await InspectionTaskRequestService.submitRequest(
        title: title,
        siteName: derived.siteName,
        areaName: derived.areaName,
        description: descriptionBody,
        priority: _priorityKey(),
        equipmentNodeIds: equipmentIds,
        issueSummary: _issueSummary.text,
        requestTypeKey: _requestTypeKey(),
        preferredDueDateIso: _preferredDueIso(),
      );
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(s.taskRequestSuccess)),
      );
      if (widget.embedInMainShell) {
        _clearForm();
      } else {
        Navigator.of(context).pop();
      }
    } on InspectionTaskRequestException catch (e) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(_errorMessage(s, e.message))),
      );
    } catch (_) {
      if (!context.mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(s.taskRequestErrorInsert)),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _toggleEquipment(String id, bool selected) {
    setState(() {
      if (selected) {
        _selectedEquipmentIds.add(id);
      } else {
        _selectedEquipmentIds.remove(id);
      }
    });
  }

  Widget _sectionCard({
    required ThemeData theme,
    required ColorScheme colorScheme,
    required String title,
    String? subtitle,
    required List<Widget> children,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (subtitle != null && subtitle.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: InputBorder.none,
      alignLabelWithHint: true,
    );
  }

  Widget _equipmentSection(AppStrings s, ThemeData theme, ColorScheme cs) {
    if (_loadingForest) {
      return _sectionCard(
        theme: theme,
        colorScheme: cs,
        title: s.taskRequestSectionEquipment,
        subtitle: s.taskRequestEquipmentSectionSubtitle,
        children: const [
          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(),
            ),
          ),
        ],
      );
    }
    if (_forestError != null) {
      return _sectionCard(
        theme: theme,
        colorScheme: cs,
        title: s.taskRequestSectionEquipment,
        subtitle: s.taskRequestEquipmentSectionSubtitle,
        children: [
          Text(
            s.taskRequestEquipmentLoadFailed,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: cs.error,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _loadForest,
              icon: const Icon(Icons.refresh),
              label: Text(s.tasksRetry),
            ),
          ),
        ],
      );
    }
    final roots = _forest!.roots;
    if (roots.isEmpty) {
      return _sectionCard(
        theme: theme,
        colorScheme: cs,
        title: s.taskRequestSectionEquipment,
        subtitle: s.taskRequestEquipmentSectionSubtitle,
        children: [
          Text(
            s.taskRequestEquipmentEmpty,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      );
    }
    return _sectionCard(
      theme: theme,
      colorScheme: cs,
      title: s.taskRequestSectionEquipment,
      subtitle: s.taskRequestEquipmentSectionSubtitle,
      children: [
        EquipmentNodesPicker(
          roots: roots,
          selectedIds: _selectedEquipmentIds,
          onToggleEquipment: _toggleEquipment,
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
        final requestTypeLabels = [
          s.requestTypeInspection,
          s.requestTypeMaintenance,
          s.requestTypeDefect,
          s.requestTypeRepair,
        ];

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: buildTaskFlowAppBar(
            context: context,
            title: Text(
              s.taskRequestScreenTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            actions: const [
              LanguageMenuButton(),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              _equipmentSection(s, theme, colorScheme),
              const SizedBox(height: 16),
              _sectionCard(
                theme: theme,
                colorScheme: colorScheme,
                title: s.taskRequestSectionProblem,
                children: [
                  TextField(
                    controller: _issueSummary,
                    decoration: _fieldDecoration(
                      label: s.labelRequestIssueSummary,
                      hint: s.hintRequestIssueSummary,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const Divider(height: 20),
                  TextField(
                    controller: _detailedDescription,
                    minLines: 3,
                    maxLines: 8,
                    decoration: _fieldDecoration(
                      label: s.labelRequestDetailedDescription,
                      hint: s.hintRequestDetailedDescription,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.labelRequestType,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(4, (i) {
                      final sel = _requestTypeIndex == i;
                      return ChoiceChip(
                        label: Text(requestTypeLabels[i]),
                        selected: sel,
                        onSelected: (_) =>
                            setState(() => _requestTypeIndex = i),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.labelRequestPreferredDueDate,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.hintRequestPreferredDueDateOptional,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _preferredDueDate == null
                              ? '—'
                              : _pickedDateLabel(s, _preferredDueDate!),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => _pickDueDate(context),
                        child: Text(s.taskRequestSelectDueDate),
                      ),
                      TextButton(
                        onPressed: _preferredDueDate == null
                            ? null
                            : () => setState(() => _preferredDueDate = null),
                        child: Text(s.taskRequestClearDueDate),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                s.labelRequestPriority,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              _PrioritySegmented(
                colorScheme: colorScheme,
                theme: theme,
                s: s,
                index: _priorityIndex,
                onChanged: (i) => setState(() => _priorityIndex = i),
              ),
              const SizedBox(height: 28),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withValues(alpha: 0.22),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : () => _submit(context),
                    child: _submitting
                        ? SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.onPrimary,
                            ),
                          )
                        : Text(s.taskRequestSubmitButton),
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

class _PrioritySegmented extends StatelessWidget {
  const _PrioritySegmented({
    required this.colorScheme,
    required this.theme,
    required this.s,
    required this.index,
    required this.onChanged,
  });

  final ColorScheme colorScheme;
  final ThemeData theme;
  final AppStrings s;
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final labels = [s.priorityLow, s.priorityMedium, s.priorityHigh];
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        children: List.generate(3, (i) {
          final sel = index == i;
          return Expanded(
            child: Material(
              color: sel
                  ? colorScheme.primary.withValues(alpha: 0.2)
                  : Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(
                    labels[i],
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: sel
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
