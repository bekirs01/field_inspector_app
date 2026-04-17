import 'dart:convert';

/// Appends machine-readable JSON after a marker so legacy admin UIs still read the
/// human narrative in [inspection_task_requests.description] while structured
/// fields remain available for improved tooling.
class TaskRequestPayload {
  TaskRequestPayload._();

  static const metaMarker = '\n\n----FIELD_INSPECTOR_REQUEST_META_JSON----\n';

  static String composeDescription({
    required String humanNarrative,
    required Map<String, dynamic> meta,
  }) {
    final narrative = humanNarrative.trim();
    final payload = <String, dynamic>{
      ...meta,
      'human_narrative': narrative,
    };
    final jsonStr = jsonEncode(payload);
    if (narrative.isEmpty) {
      return '${metaMarker.trim()}\n$jsonStr';
    }
    return '$narrative$metaMarker$jsonStr';
  }
}
