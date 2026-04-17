import 'package:flutter/foundation.dart';

import '../../../core/localization/app_strings.dart';
import 'assigned_inspection_task_service.dart';
import 'equipment_nodes_repository.dart';

/// One selectable machine for a critical (red) alert.
class RedAlertMachineOption {
  const RedAlertMachineOption({
    required this.equipmentId,
    required this.equipmentName,
    required this.siteName,
    required this.areaName,
    this.taskId,
    this.taskTitle,
    required this.sortPriority,
    required this.fromTaskRoute,
  });

  final String equipmentId;
  final String equipmentName;
  final String siteName;
  final String areaName;
  final String? taskId;
  final String? taskTitle;

  /// 0 = active assignment route item, 1 = archived assignment route item, 2 = equipment_nodes.
  final int sortPriority;
  final bool fromTaskRoute;

  String subtitle(AppStrings s) {
    if (taskTitle != null && taskTitle!.trim().isNotEmpty) {
      return '${s.labelTask}: ${taskTitle!.trim()}';
    }
    final parts = <String>[];
    if (siteName.trim().isNotEmpty) parts.add(siteName.trim());
    if (areaName.trim().isNotEmpty) parts.add(areaName.trim());
    if (parts.isEmpty) {
      return fromTaskRoute
          ? s.redAlertCatalogTaskRoute
          : s.redAlertCatalogEquipmentDirectory;
    }
    return parts.join(' · ');
  }
}

/// Loads real equipment from assigned tasks (active first) and [equipment_nodes].
class RedAlertMachineCatalog {
  RedAlertMachineCatalog._();

  static bool _taskBundleArchived(AssignedInspectionTaskBundle b) {
    final ex =
        '${b.assignmentRow['execution_status']}'.toLowerCase().trim();
    if (ex == 'completed' || ex == 'completed_with_issues') return true;
    final st = '${b.taskRow['status']}'.toLowerCase().trim();
    return st == 'completed' || st == 'completed_with_issues';
  }

  static Future<List<RedAlertMachineOption>> loadOptions() async {
    final out = <RedAlertMachineOption>[];
    final seenIds = <String>{};

    void add(RedAlertMachineOption o) {
      final id = o.equipmentId.trim();
      if (id.isEmpty) return;
      if (!seenIds.add(id)) return;
      out.add(o);
    }

    try {
      final assignLoad =
          await AssignedInspectionTaskService.loadAllWorkerAssignmentBundles();
      if (assignLoad.bundles.isNotEmpty) {
        for (final b in assignLoad.bundles) {
          final archived = _taskBundleArchived(b);
          final tid = b.taskRow['id']?.toString();
          final tTitle = b.taskRow['title']?.toString();
          final site = b.taskRow['site_name']?.toString() ?? '';
          final area = b.taskRow['area_name']?.toString() ?? '';
          for (final raw in b.itemRows) {
            final m = Map<String, dynamic>.from(raw);
            final id = m['id']?.toString() ?? '';
            final name = m['equipment_name']?.toString().trim() ?? '';
            if (id.isEmpty || name.isEmpty) continue;
            add(
              RedAlertMachineOption(
                equipmentId: id,
                equipmentName: name,
                siteName: site,
                areaName: area,
                taskId: tid?.isEmpty ?? true ? null : tid,
                taskTitle: tTitle?.isEmpty ?? true ? null : tTitle,
                sortPriority: archived ? 1 : 0,
                fromTaskRoute: true,
              ),
            );
          }
        }
      }
    } catch (e, st) {
      debugPrint('[RedAlertCatalog] assignments $e\n$st');
    }

    try {
      final forest = await EquipmentNodesRepository.fetchForest();
      for (final row in forest.byId.values) {
        if (!row.isEquipment) continue;
        final derived = SiteAreaDerived.fromSelection({row.id}, forest.byId);
        add(
          RedAlertMachineOption(
            equipmentId: row.id,
            equipmentName: row.name.trim().isEmpty ? row.id : row.name.trim(),
            siteName: derived.siteName,
            areaName: derived.areaName,
            taskId: null,
            taskTitle: null,
            sortPriority: 2,
            fromTaskRoute: false,
          ),
        );
      }
    } catch (e, st) {
      debugPrint('[RedAlertCatalog] equipment_nodes $e\n$st');
    }

    out.sort((a, b) {
      final c = a.sortPriority.compareTo(b.sortPriority);
      if (c != 0) return c;
      final na = a.equipmentName.toLowerCase();
      final nb = b.equipmentName.toLowerCase();
      final n = na.compareTo(nb);
      if (n != 0) return n;
      return a.equipmentId.compareTo(b.equipmentId);
    });

    return out;
  }
}
