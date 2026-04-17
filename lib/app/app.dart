import 'dart:async';

import 'package:flutter/material.dart';

import '../core/localization/language_controller.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/subtle_snowfall_background.dart';
import '../features/inspection/data/remote_send_availability.dart';
import 'session_gate.dart';

class FieldInspectorApp extends StatefulWidget {
  const FieldInspectorApp({super.key});

  @override
  State<FieldInspectorApp> createState() => _FieldInspectorAppState();
}

class _FieldInspectorAppState extends State<FieldInspectorApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    scheduleMicrotask(() => unawaited(flushPendingInspectionSubmissions()));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(flushPendingInspectionSubmissions());
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageController = LanguageScope.of(context);
    return ListenableBuilder(
      listenable: languageController,
      builder: (context, _) {
        final s = context.strings;
        return MaterialApp(
          title: s.appMaterialTitle,
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          builder: (context, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                const Positioned.fill(
                  child: SubtleSnowfallBackground(
                    flakeCount: 88,
                    intensity: 1.0,
                  ),
                ),
                ?child,
              ],
            );
          },
          home: const SessionGate(),
        );
      },
    );
  }
}
