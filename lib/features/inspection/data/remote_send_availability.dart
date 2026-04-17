import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'inspection_supabase_service.dart';
import 'pending_inspection_store.dart';

/// Lightweight "can we plausibly reach the internet?" probe (not a guarantee).
Future<bool> quickInternetLookupHint() async {
  try {
    final r = await InternetAddress.lookup(
      'supabase.com',
    ).timeout(const Duration(seconds: 3));
    return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
  } on SocketException catch (e) {
    debugPrint('[RemoteSend] lookup fail $e');
    return false;
  } on TimeoutException {
    debugPrint('[RemoteSend] lookup timeout');
    return false;
  } catch (e) {
    debugPrint('[RemoteSend] lookup error $e');
    return false;
  }
}

/// Try to drain the pending inspection queue (silent; no UI spam).
Future<void> flushPendingInspectionSubmissions() async {
  if (!InspectionSupabaseService.isSupabaseClientReady()) return;
  final online = await quickInternetLookupHint();
  if (!online) return;

  final items = await PendingInspectionStore.instance.loadAll();
  if (items.isEmpty) return;

  debugPrint('[PendingInspection] flush start count=${items.length}');
  for (final r in items) {
    try {
      await PendingInspectionStore.instance.tryUploadAndConsume(r);
    } catch (e, st) {
      debugPrint(
        '[PendingInspection] flush stop on failure id=${r.id} err=$e\n$st',
      );
      break;
    }
  }
}
