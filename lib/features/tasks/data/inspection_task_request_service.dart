import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/worker_profile_service.dart';

class InspectionTaskRequestException implements Exception {
  InspectionTaskRequestException(this.code);
  final String code;

  @override
  String toString() => 'InspectionTaskRequestException($code)';
}

/// Inserts worker-originated task requests for admin review.
///
/// Target table: `public.inspection_task_requests`.
/// Inserts only columns required for worker submit; other columns use DB defaults.
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

  /// Narrow "schema mismatch" to real missing/unknown column problems — not generic PostgREST codes.
  static bool _isRealSchemaMismatch(PostgrestException e) {
    final code = e.code?.toString() ?? '';
    final msg = '${e.message} ${e.details} ${e.hint}'.toLowerCase();

    if (code == '42703') return true;

    if (msg.contains('undefined column')) return true;

    if (msg.contains('column') &&
        (msg.contains('does not exist') ||
            msg.contains('not exist in') ||
            msg.contains('unknown'))) {
      return true;
    }

    if (msg.contains('could not find') && msg.contains('column')) return true;

    return false;
  }

  static String _mapPostgrest(PostgrestException e) {
    final code = e.code?.toString() ?? '';
    final msg = '${e.message} ${e.details} ${e.hint}'.toLowerCase();

    if (code == '42501' ||
        msg.contains('permission denied') ||
        (msg.contains('row-level security') && msg.contains('violat')) ||
        (msg.contains('policy') && msg.contains('denied'))) {
      return 'rls_denied';
    }

    if (_isRealSchemaMismatch(e)) {
      return 'schema_mismatch';
    }

    return 'insert_failed';
  }

  static String _mapGeneric(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('socketexception') ||
        s.contains('failed host lookup') ||
        s.contains('connection refused') ||
        s.contains('connection reset') ||
        s.contains('timed out') ||
        s.contains('network is unreachable')) {
      return 'network';
    }
    return 'unknown';
  }

  /// Inserts one row. [description] is the full worker-visible narrative (incl. equipment context from UI).
  static Future<void> submitRequest({
    required String shortTitle,
    required String description,
    required String priority,
    required String requestTypeKey,
    DateTime? desiredDueAt,
  }) async {
    if (!_clientReady()) {
      throw InspectionTaskRequestException('supabase_not_configured');
    }

    final user = _client.auth.currentUser;
    if (user == null || user.isAnonymous) {
      debugPrint(
        '[TaskRequest] submit blocked: no non-anonymous auth session',
      );
      throw InspectionTaskRequestException('no_auth_session');
    }
    final authId = user.id;
    if (authId.isEmpty) {
      throw InspectionTaskRequestException('no_auth_session');
    }

    final profile = await WorkerProfileService.fetchProfileForUserId(authId);
    if (profile == null) {
      debugPrint('[TaskRequest] submit blocked: no profiles row for $authId');
      throw InspectionTaskRequestException('profile_missing');
    }

    var p = priority.trim().toLowerCase();
    if (!const {'low', 'medium', 'high'}.contains(p)) {
      throw InspectionTaskRequestException('validation_priority');
    }

    var rt = requestTypeKey.trim().toLowerCase();
    if (!const {'inspection', 'maintenance', 'defect', 'repair'}.contains(rt)) {
      throw InspectionTaskRequestException('validation_request_type');
    }

    final st = shortTitle.trim();
    final desc = description.trim();
    if (st.isEmpty) {
      throw InspectionTaskRequestException('validation_title');
    }
    if (desc.isEmpty) {
      throw InspectionTaskRequestException('validation_description');
    }

    final row = <String, dynamic>{
      'requested_by': authId,
      'short_title': st.length > 500 ? '${st.substring(0, 497)}…' : st,
      'description': desc,
      'request_type': rt,
      'priority': p,
      'status': 'pending',
      'desired_due_at': desiredDueAt?.toUtc().toIso8601String(),
    };

    try {
      await _client.from('inspection_task_requests').insert(row);
    } on PostgrestException catch (e, st) {
      debugPrint(
        '[TaskRequest] Postgrest code=${e.code} message=${e.message} '
        'details=${e.details} hint=${e.hint}\n$st',
      );
      throw InspectionTaskRequestException(_mapPostgrest(e));
    } on SocketException catch (e, st) {
      debugPrint('[TaskRequest] network error $e\n$st');
      throw InspectionTaskRequestException('network');
    } catch (e, st) {
      debugPrint('[TaskRequest] insert failed $e\n$st');
      final mapped = _mapGeneric(e);
      if (mapped == 'network') {
        throw InspectionTaskRequestException('network');
      }
      throw InspectionTaskRequestException('unknown');
    }
  }
}
