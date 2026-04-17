import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// One row from [equipment_nodes] (active-only fetch).
class EquipmentNodeRow {
  EquipmentNodeRow({
    required this.id,
    required this.parentId,
    required this.name,
    required this.nodeType,
  });

  final String id;
  final String? parentId;
  final String name;

  /// Normalized: plant | site | workshop | section | equipment
  final String nodeType;

  bool get isEquipment => nodeType == 'equipment';
}

/// Tree node for UI (children sorted by name, UTF-8 / simple lexicographic).
class EquipmentTreeNode {
  EquipmentTreeNode({required this.row, required this.children});

  final EquipmentNodeRow row;
  final List<EquipmentTreeNode> children;
}

class EquipmentNodesQueryResult {
  EquipmentNodesQueryResult({required this.roots, required this.byId});

  final List<EquipmentTreeNode> roots;
  final Map<String, EquipmentNodeRow> byId;
}

class EquipmentNodesRepository {
  EquipmentNodesRepository._();

  static bool _clientReady() {
    try {
      return Supabase.instance.isInitialized;
    } catch (_) {
      return false;
    }
  }

  static SupabaseClient get _client => Supabase.instance.client;

  /// Loads active nodes and builds a forest (roots = rows with null [parent_id]).
  static Future<EquipmentNodesQueryResult> fetchForest() async {
    if (!_clientReady()) {
      throw StateError('supabase_not_ready');
    }
    final raw = await _client
        .from('equipment_nodes')
        .select('id, parent_id, name, node_type')
        .eq('is_active', true)
        .order('name');

    final list = raw as List<dynamic>;
    final byId = <String, EquipmentNodeRow>{};
    for (final e in list) {
      final m = Map<String, dynamic>.from(e as Map);
      final id = m['id']?.toString();
      if (id == null || id.isEmpty) continue;
      final typeRaw = m['node_type']?.toString().trim().toLowerCase() ?? '';
      if (!_knownTypes.contains(typeRaw)) {
        debugPrint('[EquipmentNodes] skip unknown node_type: $typeRaw');
        continue;
      }
      byId[id] = EquipmentNodeRow(
        id: id,
        parentId: m['parent_id']?.toString(),
        name: m['name']?.toString() ?? '',
        nodeType: typeRaw,
      );
    }

    final childrenOf = <String?, List<EquipmentNodeRow>>{};
    for (final row in byId.values) {
      childrenOf.putIfAbsent(row.parentId, () => []).add(row);
    }
    for (final entry in childrenOf.entries) {
      entry.value.sort((a, b) {
        final ca = a.name.toLowerCase();
        final cb = b.name.toLowerCase();
        final c = ca.compareTo(cb);
        if (c != 0) return c;
        return a.id.compareTo(b.id);
      });
    }

    EquipmentTreeNode build(EquipmentNodeRow row) {
      final kids = childrenOf[row.id] ?? const <EquipmentNodeRow>[];
      return EquipmentTreeNode(
        row: row,
        children: kids.map(build).toList(),
      );
    }

    final rootsRows = childrenOf[null] ?? const <EquipmentNodeRow>[];
    final roots = rootsRows.map(build).toList();
    return EquipmentNodesQueryResult(roots: roots, byId: byId);
  }

  static const _knownTypes = {
    'plant',
    'site',
    'workshop',
    'section',
    'equipment',
  };
}

/// Nearest [site] and nearest [workshop]/[section] when walking up from each equipment node.
class SiteAreaDerived {
  SiteAreaDerived({
    required this.siteName,
    required this.areaName,
    required this.hasMultipleSites,
    required this.hasMultipleAreas,
  });

  final String siteName;
  final String areaName;
  final bool hasMultipleSites;
  final bool hasMultipleAreas;

  static SiteAreaDerived fromSelection(
    Set<String> equipmentIds,
    Map<String, EquipmentNodeRow> byId,
  ) {
    final sites = <String>{};
    final areas = <String>{};
    for (final id in equipmentIds) {
      final start = byId[id];
      if (start == null || !start.isEquipment) continue;
      String? site;
      String? area;
      var p = start.parentId;
      while (p != null) {
        final node = byId[p];
        if (node == null) break;
        if (node.nodeType == 'site' && site == null) {
          site = node.name;
        }
        if ((node.nodeType == 'workshop' || node.nodeType == 'section') &&
            area == null) {
          area = node.name;
        }
        p = node.parentId;
      }
      if (site != null && site.isNotEmpty) sites.add(site);
      if (area != null && area.isNotEmpty) areas.add(area);
    }
    return SiteAreaDerived(
      siteName: sites.join(' · '),
      areaName: areas.join(' · '),
      hasMultipleSites: sites.length > 1,
      hasMultipleAreas: areas.length > 1,
    );
  }
}
