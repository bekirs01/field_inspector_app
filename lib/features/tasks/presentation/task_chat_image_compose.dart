import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';

/// Fullscreen preview + optional caption before sending a photo to task chat.
/// Does not upload until the user taps send; cancel discards without upload.
class TaskChatImageComposePage extends StatefulWidget {
  const TaskChatImageComposePage({
    super.key,
    required this.imageFile,
    required this.strings,
    required this.onSend,
  });

  final File imageFile;
  final AppStrings strings;
  final Future<bool> Function(String caption) onSend;

  @override
  State<TaskChatImageComposePage> createState() =>
      _TaskChatImageComposePageState();
}

class _TaskChatImageComposePageState extends State<TaskChatImageComposePage> {
  final _captionController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _sending = true);
    try {
      final ok = await widget.onSend(_captionController.text.trim());
      if (!mounted) return;
      if (ok) Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _sending ? null : () => Navigator.of(context).pop(false),
                    icon: const Icon(Icons.close_rounded),
                    tooltip: widget.strings.redAlertCancel,
                  ),
                  Expanded(
                    child: Text(
                      widget.strings.taskChatPhotoPreviewTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            if (_sending)
              LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: cs.surfaceContainerHighest,
                color: cs.primary,
              ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight - 24),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: InteractiveViewer(
                            minScale: 1,
                            maxScale: 4,
                            child: Image.file(
                              widget.imageFile,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.medium,
                              errorBuilder: (ctx, err, st) {
                                return Container(
                                  height: 200,
                                  alignment: Alignment.center,
                                  color: cs.surfaceContainerHighest,
                                  child: Icon(
                                    Icons.broken_image_outlined,
                                    color: cs.error,
                                    size: 48,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _captionController,
                minLines: 1,
                maxLines: 4,
                enabled: !_sending,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: widget.strings.taskChatAttachmentCaptionHint,
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: cs.outlineVariant),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: cs.outlineVariant),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _sending
                          ? null
                          : () => Navigator.of(context).pop(false),
                      child: Text(widget.strings.redAlertCancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _sending ? null : _submit,
                      child: _sending
                          ? SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: cs.onPrimary,
                              ),
                            )
                          : Text(widget.strings.taskChatSend),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
