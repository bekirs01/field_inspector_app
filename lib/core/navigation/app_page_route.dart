import 'package:flutter/material.dart';

/// No slide/zoom: avoids overlapping transparent routes with the global
/// animated background during navigation.
class InstantPageTransitionsBuilder extends PageTransitionsBuilder {
  const InstantPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

/// Use with [InstantPageTransitionsBuilder] in [ThemeData.pageTransitionsTheme].
PageTransitionsTheme buildInstantPageTransitionsTheme() {
  const builder = InstantPageTransitionsBuilder();
  return const PageTransitionsTheme(
    builders: <TargetPlatform, PageTransitionsBuilder>{
      TargetPlatform.android: builder,
      TargetPlatform.iOS: builder,
      TargetPlatform.macOS: builder,
      TargetPlatform.linux: builder,
      TargetPlatform.windows: builder,
      TargetPlatform.fuchsia: builder,
    },
  );
}

/// [MaterialPageRoute] with zero-length transitions (snap to next screen).
class AppPageRoute<T> extends MaterialPageRoute<T> {
  AppPageRoute({
    required super.builder,
    super.settings,
    super.fullscreenDialog,
    super.allowSnapshotting,
    super.maintainState,
  });

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Duration get reverseTransitionDuration => Duration.zero;
}
