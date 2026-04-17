import 'inspection_object_resume_state.dart';

/// Holds the last submitted inspection form state per task store key + route index
/// so workers can edit/resubmit from the result screens in the same app session.
class InspectionLastSubmitCache {
  InspectionLastSubmitCache._();
  static final InspectionLastSubmitCache instance = InspectionLastSubmitCache._();

  final Map<String, InspectionObjectResumeState> _map = {};

  static String _key(String storeKey, int routeItemIndex) =>
      '$storeKey::${routeItemIndex.clamp(0, 1 << 30)}';

  void put({
    required String storeKey,
    required int routeItemIndex,
    required InspectionObjectResumeState state,
  }) {
    _map[_key(storeKey, routeItemIndex)] = state;
  }

  InspectionObjectResumeState? peek(String storeKey, int routeItemIndex) =>
      _map[_key(storeKey, routeItemIndex)];
}
