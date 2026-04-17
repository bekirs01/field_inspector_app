import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/worker_identity.dart';
import 'task_request_payload.dart';

class InspectionTaskRequestException implements Exception {
  InspectionTaskRequestException(this.message);
  final String message;
}

/// Inserts worker-originated task requests for admin review.
class InspectionTaskRequestService {
  InspectionTaskRequestService._();

  static bool _clientReady() {
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> submitRequest({
    required String title,
    required String siteName,
    required String areaName,
    required String description,
    required String priority,
    required List<String> equipmentNodeIds,
    String issueSummary = '',
    String requestTypeKey = 'inspection',
    String? preferredDueDateIso,
  }) async {
    final workerId = WorkerIdentity.resolveWorkerUserId();
    if (workerId == null || workerId.isEmpty) {
      throw InspectionTaskRequestException('no_worker');
    }
    if (!_clientReady()) {
      throw InspectionTaskRequestException('not_ready');
    }
    var p = priority.trim().toLowerCase();
    if (!const {'low', 'medium', 'high'}.contains(p)) {
      p = 'low';
    }
    var rt = requestTypeKey.trim().toLowerCase();
    if (!const {'inspection', 'maintenance', 'defect', 'repair'}.contains(rt)) {
      rt = 'inspection';
    }
    final summary = issueSummary.trim();
    final detail = description.trim();
    final humanNarrative = [
      if (summary.isNotEmpty) summary,
      if (detail.isNotEmpty) detail,
    ].join('\n\n');
    final meta = <String, dynamic>{
      'schema': 'field_inspector_task_request_v2',
      if (equipmentNodeIds.isNotEmpty) 'equipment_node_ids': equipmentNodeIds,
      'issue_summary': summary,
      'request_type': rt,
      if (preferredDueDateIso != null && preferredDueDateIso.trim().isNotEmpty)
        'preferred_due_date': preferredDueDateIso.trim(),
    };
    final composedDescription = TaskRequestPayload.composeDescription(
      humanNarrative: humanNarrative.isEmpty ? title.trim() : humanNarrative,
      meta: meta,
    );
    final now = DateTime.now().toUtc().toIso8601String();
    try {
      final row = <String, dynamic>{
        'requested_by': workerId,
        'title': title.trim(),
        'site_name': siteName.trim().isEmpty ? null : siteName.trim(),
        'area_name': areaName.trim().isEmpty ? null : areaName.trim(),
        'description': composedDescription.trim(),
        'priority': p,
        'status': 'pending',
        'requested_at': now,
      };
      if (equipmentNodeIds.isNotEmpty) {
        row['equipment_node_ids'] = equipmentNodeIds;
      }
      await _client.from('inspection_task_requests').insert(row);
    } catch (e, st) {
      debugPrint('[TaskRequest] insert failed $e\n$st');
      throw InspectionTaskRequestException('insert_failed');
    }
  }
}
