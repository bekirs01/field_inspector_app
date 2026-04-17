import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Stable dark canvas — no top-to-bottom blue gradients; same family as cards.
const Color kAppCanvas = Color(0xFF0B0E14);
const Color kAppSurface = Color(0xFF161B22);
const Color kAppSurfaceHigh = Color(0xFF21262D);
const Color kAppAccentBlue = Color(0xFF007AFF);

ThemeData buildAppTheme() {
  var scheme = ColorScheme.dark(
    brightness: Brightness.dark,
    primary: kAppAccentBlue,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFF1F3A5F),
    onPrimaryContainer: const Color(0xFFC8E0FF),
    secondary: const Color(0xFF58A6FF),
    onSecondary: kAppCanvas,
    tertiary: const Color(0xFF79C0FF),
    onTertiary: kAppCanvas,
    error: const Color(0xFFF85149),
    onError: Colors.white,
    surface: kAppSurface,
    onSurface: const Color(0xFFF6F8FA),
    onSurfaceVariant: const Color(0xFF8B949E),
    outline: const Color(0x22FFFFFF),
    outlineVariant: const Color(0x14FFFFFF),
  );

  scheme = scheme.copyWith(
    surfaceContainerLowest: kAppCanvas,
    surfaceContainerLow: kAppSurface,
    surfaceContainer: kAppSurface,
    surfaceContainerHigh: kAppSurfaceHigh,
    surfaceContainerHighest: kAppSurfaceHigh,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: kAppCanvas,
    splashColor: scheme.primary.withValues(alpha: 0.08),
    highlightColor: scheme.primary.withValues(alpha: 0.06),
    cardTheme: CardThemeData(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      color: kAppSurfaceHigh,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        elevation: 0,
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.primary,
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.45)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      backgroundColor: kAppCanvas,
      foregroundColor: scheme.onSurface,
      surfaceTintColor: Colors.transparent,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: IconThemeData(color: scheme.onSurface.withValues(alpha: 0.95)),
      titleTextStyle: TextStyle(
        color: scheme.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outlineVariant,
      thickness: 1,
    ),
    iconTheme: IconThemeData(color: scheme.onSurface.withValues(alpha: 0.92)),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: kAppSurfaceHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: TextStyle(
        color: scheme.onSurfaceVariant.withValues(alpha: 0.75),
      ),
      labelStyle: TextStyle(color: scheme.onSurfaceVariant),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: scheme.primary.withValues(alpha: 0.65),
          width: 1.5,
        ),
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        height: 1.35,
      ),
      bodyMedium: TextStyle(
        height: 1.35,
      ),
    ),
  );
}
