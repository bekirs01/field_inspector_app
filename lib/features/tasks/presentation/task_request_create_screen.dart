import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/localization/language_controller.dart';
import '../../../core/localization/language_menu_button.dart';
import '../data/inspection_task_request_service.dart';
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
  final _title = TextEditingController();
  final _site = TextEditingController();
  final _area = TextEditingController();
  final _description = TextEditingController();
  int _priorityIndex = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _site.dispose();
    _area.dispose();
    _description.dispose();
    super.dispose();
  }

  String _priorityKey() {
    const keys = ['low', 'medium', 'high'];
    return keys[_priorityIndex.clamp(0, 2)];
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

  void _clearForm() {
    _title.clear();
    _site.clear();
    _area.clear();
    _description.clear();
    setState(() => _priorityIndex = 0);
  }

  Future<void> _submit(BuildContext context) async {
    final s = context.strings;
    final messenger = ScaffoldMessenger.of(context);
    if (_title.text.trim().isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(s.hintRequestTitle)),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await InspectionTaskRequestService.submitRequest(
        title: _title.text,
        siteName: _site.text,
        areaName: _area.text,
        description: _description.text,
        priority: _priorityKey(),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lang = context.languageController;

    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) {
        final s = context.strings;
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
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            children: [
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: TextField(
                    controller: _title,
                    decoration: InputDecoration(
                      labelText: s.labelRequestTitle,
                      hintText: s.hintRequestTitle,
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: TextField(
                    controller: _site,
                    decoration: InputDecoration(
                      labelText: s.labelRequestSiteName,
                      hintText: s.hintRequestSiteName,
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: TextField(
                    controller: _area,
                    decoration: InputDecoration(
                      labelText: s.labelRequestAreaName,
                      hintText: s.hintRequestAreaName,
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: TextField(
                    controller: _description,
                    minLines: 3,
                    maxLines: 6,
                    decoration: InputDecoration(
                      labelText: s.labelRequestDescription,
                      hintText: s.hintRequestDescription,
                      alignLabelWithHint: true,
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
