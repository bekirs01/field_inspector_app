import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Picks local files for [TaskChatScreen]. Does not upload.
class TaskChatAttachmentPicker {
  TaskChatAttachmentPicker._();

  static final ImagePicker _picker = ImagePicker();

  static Future<TaskChatPickedFile?> pickPhotoFromGallery() async {
    try {
      final x = await _picker.pickImage(source: ImageSource.gallery);
      if (x == null) return null;
      final file = File(x.path);
      final name = x.name.isNotEmpty ? x.name : 'photo.jpg';
      return TaskChatPickedFile(file: file, displayName: name, mime: x.mimeType);
    } on PlatformException {
      rethrow;
    }
  }

  static Future<TaskChatPickedFile?> takePhotoWithCamera() async {
    try {
      final x = await _picker.pickImage(source: ImageSource.camera);
      if (x == null) return null;
      final file = File(x.path);
      final name = x.name.isNotEmpty ? x.name : 'photo.jpg';
      return TaskChatPickedFile(file: file, displayName: name, mime: x.mimeType);
    } on PlatformException {
      rethrow;
    }
  }

  static Future<TaskChatPickedFile?> pickVideoFromGallery() async {
    try {
      final x = await _picker.pickVideo(source: ImageSource.gallery);
      if (x == null) return null;
      final file = File(x.path);
      final name = x.name.isNotEmpty ? x.name : 'video.mp4';
      return TaskChatPickedFile(file: file, displayName: name, mime: x.mimeType);
    } on PlatformException {
      rethrow;
    }
  }

  static Future<TaskChatPickedFile?> pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (result == null || result.files.isEmpty) return null;
    final pf = result.files.single;
    final file = await _materializePickerFile(pf);
    final name = pf.name.isNotEmpty ? pf.name : file.uri.pathSegments.last;
    return TaskChatPickedFile(file: file, displayName: name, mime: 'application/pdf');
  }

  static Future<TaskChatPickedFile?> pickGenericFile() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;
    final pf = result.files.single;
    final file = await _materializePickerFile(pf);
    final name = pf.name.isNotEmpty ? pf.name : file.uri.pathSegments.last;
    return TaskChatPickedFile(file: file, displayName: name, mime: null);
  }

  static Future<File> _materializePickerFile(PlatformFile pf) async {
    final path = pf.path;
    if (path != null && path.isNotEmpty) {
      return File(path);
    }
    final bytes = pf.bytes;
    if (bytes == null) {
      throw StateError('picker_no_file');
    }
    final dir = await getTemporaryDirectory();
    final name =
        pf.name.isNotEmpty ? pf.name : 'attachment_${DateTime.now().millisecondsSinceEpoch}';
    final f = File(
      '${dir.path}/task_chat_${DateTime.now().millisecondsSinceEpoch}_$name',
    );
    await f.writeAsBytes(bytes, flush: true);
    return f;
  }
}

class TaskChatPickedFile {
  const TaskChatPickedFile({
    required this.file,
    required this.displayName,
    required this.mime,
  });

  final File file;
  final String displayName;
  final String? mime;
}
