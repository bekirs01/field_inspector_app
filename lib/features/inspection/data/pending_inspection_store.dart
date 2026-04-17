import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'inspection_supabase_service.dart';

/// Small on-disk queue: one folder per submission with `payload.json` + copied media.
class PendingInspectionRecord {
  PendingInspectionRecord({
    required this.id,
    required this.directoryPath,
    required this.taskId,
    required this.equipmentId,
    required this.checklist,
    required this.measurements,
    required this.comment,
    required this.defectFound,
    required this.defectDescription,
    required this.defectPriority,
    required this.photoPaths,
    required this.audioPath,
  });

  final String id;
  final String directoryPath;
  final String taskId;
  final String equipmentId;
  final List<Map<String, dynamic>> checklist;
  final Map<String, dynamic> measurements;
  final String comment;
  final bool defectFound;
  final String defectDescription;
  final String defectPriority;
  final List<String> photoPaths;
  final String? audioPath;

  Map<String, dynamic> toJson() => {
        'id': id,
        'taskId': taskId,
        'equipmentId': equipmentId,
        'checklist': checklist,
        'measurements': measurements,
        'comment': comment,
        'defectFound': defectFound,
        'defectDescription': defectDescription,
        'defectPriority': defectPriority,
        'photoPaths': photoPaths,
        'audioPath': audioPath,
      };

  static PendingInspectionRecord fromJsonDir(
    String directoryPath,
    Map<String, dynamic> j,
  ) {
    final checklistRaw = j['checklist'];
    final checklist = <Map<String, dynamic>>[];
    if (checklistRaw is List) {
      for (final e in checklistRaw) {
        if (e is Map) {
          checklist.add(Map<String, dynamic>.from(e));
        }
      }
    }
    final measurements = <String, dynamic>{};
    final m = j['measurements'];
    if (m is Map) {
      measurements.addAll(Map<String, dynamic>.from(m));
    }
    final photosRaw = j['photoPaths'];
    final photoPaths = <String>[];
    if (photosRaw is List) {
      for (final e in photosRaw) {
        final s = e?.toString() ?? '';
        if (s.isNotEmpty) photoPaths.add(s);
      }
    }
    final audio = j['audioPath']?.toString();
    return PendingInspectionRecord(
      id: j['id']?.toString() ?? '',
      directoryPath: directoryPath,
      taskId: j['taskId']?.toString() ?? '',
      equipmentId: j['equipmentId']?.toString() ?? '',
      checklist: checklist,
      measurements: measurements,
      comment: j['comment']?.toString() ?? '',
      defectFound: j['defectFound'] == true,
      defectDescription: j['defectDescription']?.toString() ?? '',
      defectPriority: j['defectPriority']?.toString() ?? '',
      photoPaths: photoPaths,
      audioPath: (audio != null && audio.isNotEmpty) ? audio : null,
    );
  }
}

String _joinPath(String a, String b) =>
    a.endsWith(Platform.pathSeparator) ? '$a$b' : '$a${Platform.pathSeparator}$b';

String _fileExtension(String path) {
  final i = path.lastIndexOf('.');
  if (i <= 0 || i == path.length - 1) return '.jpg';
  return path.substring(i);
}

class PendingInspectionStore {
  PendingInspectionStore._();

  static final PendingInspectionStore instance = PendingInspectionStore._();

  static const _folderName = 'pending_inspection_submissions';
  static const _payloadFile = 'payload.json';

  Future<Directory> _rootDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(_joinPath(base.path, _folderName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> removePendingForTaskEquipment(
    String taskId,
    String equipmentId,
  ) async {
    final records = await loadAll();
    for (final r in records) {
      if (r.taskId == taskId && r.equipmentId == equipmentId) {
        await deleteRecord(r.id, r.directoryPath);
      }
    }
  }

  Future<String> enqueueFromScreenState({
    required String taskId,
    required String equipmentId,
    required List<Map<String, dynamic>> checklist,
    required Map<String, dynamic> measurements,
    required String comment,
    required bool defectFound,
    required String defectDescription,
    required String defectPriority,
    required List<XFile> photos,
    required String? audioFilePath,
  }) async {
    await removePendingForTaskEquipment(taskId, equipmentId);

    final root = await _rootDir();
    final id =
        'pi_${DateTime.now().millisecondsSinceEpoch}_${equipmentId.hashCode}';
    final dirPath = _joinPath(root.path, id);
    final dir = Directory(dirPath);
    await dir.create(recursive: true);

    final photoPaths = <String>[];
    for (var i = 0; i < photos.length; i++) {
      final src = photos[i].path;
      final ext = _fileExtension(src);
      final dest = _joinPath(dirPath, 'photo_$i$ext');
      await File(src).copy(dest);
      photoPaths.add(dest);
    }

    String? audioDest;
    final a = audioFilePath?.trim();
    if (a != null && a.isNotEmpty && File(a).existsSync()) {
      audioDest = _joinPath(dirPath, 'audio.m4a');
      await File(a).copy(audioDest);
    }

    final payload = <String, dynamic>{
      'id': id,
      'taskId': taskId,
      'equipmentId': equipmentId,
      'checklist': checklist,
      'measurements': measurements,
      'comment': comment,
      'defectFound': defectFound,
      'defectDescription': defectDescription,
      'defectPriority': defectPriority,
      'photoPaths': photoPaths,
      'audioPath': audioDest,
    };

    final file = File(_joinPath(dirPath, _payloadFile));
    await file.writeAsString(jsonEncode(payload));
    debugPrint('[PendingInspection] enqueued id=$id task=$taskId equip=$equipmentId');
    return id;
  }

  Future<List<PendingInspectionRecord>> loadAll() async {
    final root = await _rootDir();
    final out = <PendingInspectionRecord>[];
    await for (final entity in root.list()) {
      if (entity is! Directory) continue;
      final payloadPath = _joinPath(entity.path, _payloadFile);
      final f = File(payloadPath);
      if (!await f.exists()) continue;
      try {
        final raw = jsonDecode(await f.readAsString());
        if (raw is! Map) continue;
        out.add(
          PendingInspectionRecord.fromJsonDir(
            entity.path,
            Map<String, dynamic>.from(raw),
          ),
        );
      } catch (e, st) {
        debugPrint('[PendingInspection] skip corrupt ${entity.path} $e\n$st');
      }
    }
    out.sort((a, b) => a.id.compareTo(b.id));
    return out;
  }

  Future<void> deleteRecord(String id, String directoryPath) async {
    try {
      final d = Directory(directoryPath);
      if (await d.exists()) {
        await d.delete(recursive: true);
      }
      debugPrint('[PendingInspection] deleted id=$id');
    } catch (e, st) {
      debugPrint('[PendingInspection] delete failed id=$id $e\n$st');
    }
  }

  Future<void> tryUploadAndConsume(PendingInspectionRecord r) async {
    if (!InspectionSupabaseService.isSupabaseClientReady()) {
      throw StateError('supabase not ready');
    }
    for (final path in r.photoPaths) {
      if (!await File(path).exists()) {
        throw StateError('missing photo $path');
      }
    }
    if (r.audioPath != null && !await File(r.audioPath!).exists()) {
      throw StateError('missing audio ${r.audioPath}');
    }
    final photos = r.photoPaths.map((e) => XFile(e)).toList();
    await InspectionSupabaseService.instance.saveInspectionCompletion(
      taskId: r.taskId,
      equipmentId: r.equipmentId,
      checklist: r.checklist,
      measurements: r.measurements,
      comment: r.comment,
      defectFound: r.defectFound,
      defectDescription: r.defectDescription,
      defectPriority: r.defectPriority,
      photos: photos,
      audioFilePath: r.audioPath,
    );
    await deleteRecord(r.id, r.directoryPath);
  }
}
