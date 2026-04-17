import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/navigation/app_page_route.dart';
import '../../tasks/data/demo_task_completion_store.dart';
import '../../tasks/data/inspector_task_session.dart';
import '../data/inspection_last_submit_cache.dart';
import 'inspection_object_screen.dart';

/// Opens [InspectionObjectScreen] with cached form state; returns the new result
/// or `null` if the user backed out / no cache.
Future<InspectionObjectResult?> pushInspectionResubmit({
  required BuildContext context,
  required InspectorTaskSession session,
  required int routeItemIndex,
  required AppStrings strings,
}) async {
  final resume =
      InspectionLastSubmitCache.instance.peek(session.storeKey, routeItemIndex);
  if (resume == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.editResultNoCachedState)),
    );
    return null;
  }
  return Navigator.of(context).push<InspectionObjectResult?>(
    AppPageRoute<InspectionObjectResult?>(
      builder: (context) => InspectionObjectScreen(
        session: session,
        routeItemIndex: routeItemIndex,
        initialResume: resume,
      ),
    ),
  );
}

void applyResubmitToCompletionStore({
  required InspectorTaskSession session,
  required InspectionObjectResult result,
}) {
  DemoTaskCompletionStore.instance.applyObjectResubmit(
    storeKey: session.storeKey,
    routeItemIndex: result.routeItemIndex,
    hadDefect: result.hadDefect,
    photoCount: result.photoCount,
    audioCount: result.audioCount,
  );
}
