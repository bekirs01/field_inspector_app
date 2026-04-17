import 'package:flutter/foundation.dart';

import '../../../core/localization/demo_task_public_state.dart';

/// In-memory demo snapshot after a full route is finished.
class CompletedTaskDemoSnapshot {
  const CompletedTaskDemoSnapshot({
    required this.state,
    required this.itemHasIssue,
    required this.totalPhotosSubmitted,
    required this.totalAudioClipsSubmitted,
    required this.itemPhotoCounts,
    required this.itemAudioCounts,
  });

  final DemoTaskPublicState state;
  final List<bool> itemHasIssue;
  final int totalPhotosSubmitted;
  final int totalAudioClipsSubmitted;
  /// Last known photo count per route object (same order as [itemHasIssue]).
  final List<int> itemPhotoCounts;
  /// 0 or 1 voice note per object.
  final List<int> itemAudioCounts;

  int get totalObjects => itemHasIssue.length;

  int get issueObjectCount => itemHasIssue.where((x) => x).length;

  int get completedOkCount => totalObjects - issueObjectCount;
}

/// Minimal shared demo state: route started + completed round results.
class DemoTaskCompletionStore extends ChangeNotifier {
  DemoTaskCompletionStore._();
  static final DemoTaskCompletionStore instance = DemoTaskCompletionStore._();

  final Map<String, CompletedTaskDemoSnapshot> _completed = {};
  final Set<String> _routeStarted = {};

  CompletedTaskDemoSnapshot? completedSnapshot(String storeKey) =>
      _completed[storeKey];

  DemoTaskPublicState effectiveState({
    required String storeKey,
    required DemoTaskPublicState baseline,
  }) {
    final done = _completed[storeKey];
    if (done != null) return done.state;
    if (_routeStarted.contains(storeKey)) return DemoTaskPublicState.inProgress;
    return baseline;
  }

  void markRouteStarted(String storeKey) {
    if (_completed.containsKey(storeKey)) return;
    if (_routeStarted.contains(storeKey)) return;
    _routeStarted.add(storeKey);
    notifyListeners();
  }

  void recordRouteFinished({
    required String storeKey,
    required List<bool> itemHasIssue,
    required int totalPhotosSubmitted,
    required int totalAudioClipsSubmitted,
    required List<int> itemPhotoCounts,
    required List<int> itemAudioCounts,
  }) {
    final issueCount = itemHasIssue.where((x) => x).length;
    _completed[storeKey] = CompletedTaskDemoSnapshot(
      state: issueCount > 0
          ? DemoTaskPublicState.completedWithIssues
          : DemoTaskPublicState.completed,
      itemHasIssue: List<bool>.from(itemHasIssue),
      totalPhotosSubmitted: totalPhotosSubmitted,
      totalAudioClipsSubmitted: totalAudioClipsSubmitted,
      itemPhotoCounts: List<int>.from(itemPhotoCounts),
      itemAudioCounts: List<int>.from(itemAudioCounts),
    );
    _routeStarted.remove(storeKey);
    notifyListeners();
  }

  /// Updates per-object issue/media totals after a resubmit from the result screen.
  void applyObjectResubmit({
    required String storeKey,
    required int routeItemIndex,
    required bool hadDefect,
    required int photoCount,
    required int audioCount,
  }) {
    final snap = _completed[storeKey];
    if (snap == null) return;
    final n = snap.itemHasIssue.length;
    if (routeItemIndex < 0 || routeItemIndex >= n) return;

    final issues = List<bool>.from(snap.itemHasIssue);
    issues[routeItemIndex] = hadDefect;

    final photos = snap.itemPhotoCounts.length == n
        ? List<int>.from(snap.itemPhotoCounts)
        : List<int>.filled(n, 0);
    final audio = snap.itemAudioCounts.length == n
        ? List<int>.from(snap.itemAudioCounts)
        : List<int>.filled(n, 0);
    photos[routeItemIndex] = photoCount.clamp(0, 999);
    audio[routeItemIndex] = audioCount.clamp(0, 1);

    final totalPhotos = photos.fold<int>(0, (a, b) => a + b);
    final totalAudio = audio.fold<int>(0, (a, b) => a + b);
    final issueObjectCount = issues.where((x) => x).length;

    _completed[storeKey] = CompletedTaskDemoSnapshot(
      state: issueObjectCount > 0
          ? DemoTaskPublicState.completedWithIssues
          : DemoTaskPublicState.completed,
      itemHasIssue: issues,
      totalPhotosSubmitted: totalPhotos,
      totalAudioClipsSubmitted: totalAudio,
      itemPhotoCounts: photos,
      itemAudioCounts: audio,
    );
    notifyListeners();
  }
}
