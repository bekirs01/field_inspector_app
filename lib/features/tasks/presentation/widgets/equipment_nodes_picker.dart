import 'package:flutter/material.dart';

import '../../data/equipment_nodes_repository.dart';

/// Hierarchical picker: expand parents; checkboxes only on [nodeType] == equipment.
class EquipmentNodesPicker extends StatelessWidget {
  const EquipmentNodesPicker({
    super.key,
    required this.roots,
    required this.selectedIds,
    required this.onToggleEquipment,
    this.depth = 0,
  });

  final List<EquipmentTreeNode> roots;
  final Set<String> selectedIds;
  final void Function(String equipmentId, bool selected) onToggleEquipment;
  final int depth;

  @override
  Widget build(BuildContext context) {
    if (roots.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: roots.map((n) => _NodeTile(
            node: n,
            selectedIds: selectedIds,
            onToggleEquipment: onToggleEquipment,
            depth: depth,
          )).toList(),
    );
  }
}

class _NodeTile extends StatelessWidget {
  const _NodeTile({
    required this.node,
    required this.selectedIds,
    required this.onToggleEquipment,
    required this.depth,
  });

  final EquipmentTreeNode node;
  final Set<String> selectedIds;
  final void Function(String equipmentId, bool selected) onToggleEquipment;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = EdgeInsets.only(left: depth * 12.0);
    final id = node.row.id;
    final name = node.row.name;

    if (node.row.isEquipment) {
      final checked = selectedIds.contains(id);
      return Padding(
        padding: pad,
        child: CheckboxListTile(
          value: checked,
          dense: true,
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: Text(name, style: theme.textTheme.bodyLarge),
          onChanged: (v) => onToggleEquipment(id, v ?? false),
        ),
      );
    }

    if (node.children.isEmpty) {
      return Padding(
        padding: pad,
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          title: Text(
            name,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: pad,
      child: ExpansionTile(
        key: PageStorageKey<String>('eq_node_$id'),
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        title: Text(
          name,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: node.children
            .map(
              (c) => _NodeTile(
                node: c,
                selectedIds: selectedIds,
                onToggleEquipment: onToggleEquipment,
                depth: depth + 1,
              ),
            )
            .toList(),
      ),
    );
  }
}
