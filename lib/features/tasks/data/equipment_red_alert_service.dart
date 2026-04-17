import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/worker_identity.dart';
import '../../../core/config/worker_profile_service.dart';
import 'red_alert_machine_catalog.dart';

class EquipmentRedAlertException implements Exception {
  EquipmentRedAlertException(this.code);

  final String code;

  @override
  String toString() => 'EquipmentRedAlertException($code)';
}

class EquipmentRedAlertService {
  EquipmentRedAlertService._();

  static bool isReady() {
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  static SupabaseClient get _client => Supabase.instance.client;

  static Future<void> submitCriticalAlert({
    required RedAlertMachineOption machine,
    required String title,
    required String description,
  }) async {
    if (!isReady()) {
      throw EquipmentRedAlertException('not_ready');
    }
    final uid = WorkerIdentity.resolveWorkerUserId();
    if (uid == null || uid.isEmpty) {
      throw EquipmentRedAlertException('no_auth_session');
    }

    final profile = await WorkerProfileService.fetchProfileForUserId(uid);
    if (profile == null) {
      throw EquipmentRedAlertException('profile_missing');
    }

    final t = title.trim();
    final d = description.trim();
    if (t.isEmpty) {
      throw EquipmentRedAlertException('validation_title');
    }

    final equipmentId = machine.equipmentId.trim();
    final equipmentName = machine.equipmentName.trim();
    if (equipmentId.isEmpty || equipmentName.isEmpty) {
      throw EquipmentRedAlertException('invalid_machine');
    }

    final payload = <String, dynamic>{
      'equipment_id': equipmentId,
      'equipment_name': equipmentName.length > 500
          ? '${equipmentName.substring(0, 497)}…'
          : equipmentName,
      'site_name': machine.siteName.trim().isEmpty
          ? null
          : machine.siteName.trim(),
      'area_name': machine.areaName.trim().isEmpty
          ? null
          : machine.areaName.trim(),
      'task_id': machine.taskId?.trim().isEmpty ?? true
          ? null
          : machine.taskId!.trim(),
      'triggered_by': uid,
      'triggered_by_name': profile.displayName.length > 200
          ? '${profile.displayName.substring(0, 197)}…'
          : profile.displayName,
      'source': 'worker_manual',
      'severity': 'critical',
      'title': t.length > 300 ? '${t.substring(0, 297)}…' : t,
      'description': d.length > 8000 ? '${d.substring(0, 7997)}…' : d,
      'status': 'open',
    };

    try {
      await _client.from('equipment_red_alerts').insert(payload);
    } on PostgrestException catch (e, st) {
      debugPrint('[RedAlert] insert Postgrest $e\n$st');
      final msg = '${e.message}${e.details}'.toLowerCase();
      if (msg.contains('permission') ||
          msg.contains('rls') ||
          e.code == '42501') {
        throw EquipmentRedAlertException('rls_denied');
      }
      if (msg.contains('relation') && msg.contains('does not exist')) {
        throw EquipmentRedAlertException('schema_mismatch');
      }
      throw EquipmentRedAlertException('insert_failed');
    } catch (e, st) {
      if (e is EquipmentRedAlertException) rethrow;
      debugPrint('[RedAlert] insert $e\n$st');
      throw EquipmentRedAlertException('network');
    }
  }
}
