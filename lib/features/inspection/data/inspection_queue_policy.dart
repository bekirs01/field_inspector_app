import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';

import 'inspection_save_failure.dart';

bool _looksLikePostgrestException(Object? o) {
  if (o == null) return false;
  return o.runtimeType.toString().contains('Postgrest');
}

/// Heuristics for offline queueing (no huge sync engine — transport vs policy errors).
bool inspectionTransportLooksLikely(Object? cause) {
  if (cause == null) return false;
  if (cause is SocketException) return true;
  if (cause is TimeoutException) return true;
  if (cause is HttpException) return true;
  if (cause is HandshakeException) return true;
  if (cause is FileSystemException) return true;
  final t = cause.runtimeType.toString();
  if (t.contains('ClientException')) return true;
  final s = cause.toString().toLowerCase();
  if (s.contains('connection refused')) return true;
  if (s.contains('connection reset')) return true;
  if (s.contains('host lookup failed')) return true;
  if (s.contains('failed host lookup')) return true;
  if (s.contains('network is unreachable')) return true;
  if (s.contains('software caused connection abort')) return true;
  if (s.contains('connection timed out')) return true;
  if (s.contains('errno = 7')) return true; // failed lookup on some platforms
  return false;
}

bool _uploadPermissionNoise(Object? cause) {
  if (cause == null) return false;
  if (cause is PlatformException) {
    final c = cause.code.toLowerCase();
    return c.contains('permission') || c == 'permission_denied';
  }
  final msg = cause.toString().toLowerCase();
  return msg.contains('permission_denied') || msg.contains('permission denied');
}

/// When true, persist as pending and retry later instead of blocking the worker.
bool shouldQueueInspectionAfterFailure(InspectionSaveException e) {
  final c = e.cause;
  switch (e.failure) {
    case InspectionSaveFailure.supabaseNotConfigured:
      return true;
    case InspectionSaveFailure.supabaseAnonymousSignInFailed:
      return inspectionTransportLooksLikely(c);
    case InspectionSaveFailure.missingTaskId:
    case InspectionSaveFailure.missingEquipmentId:
    case InspectionSaveFailure.preparePayloadFailed:
    case InspectionSaveFailure.localPhotoMissing:
    case InspectionSaveFailure.recordingNotFound:
    case InspectionSaveFailure.permissionDenied:
    case InspectionSaveFailure.reportReturningEmpty:
    case InspectionSaveFailure.reportForeignKeyViolation:
    case InspectionSaveFailure.reportRowLevelSecurityBlocked:
    case InspectionSaveFailure.mediaMetadataFailedAfterReportSaved:
      return false;
    case InspectionSaveFailure.photoUploadFailed:
    case InspectionSaveFailure.audioUploadFailed:
      if (_uploadPermissionNoise(c)) return false;
      return inspectionTransportLooksLikely(c) || c == null;
    case InspectionSaveFailure.reportInsertFailed:
    case InspectionSaveFailure.mediaInsertFailed:
    case InspectionSaveFailure.databaseSaveFailed:
      if (_looksLikePostgrestException(c)) return false;
      return inspectionTransportLooksLikely(c);
    case InspectionSaveFailure.unknown:
      return inspectionTransportLooksLikely(c);
  }
}
