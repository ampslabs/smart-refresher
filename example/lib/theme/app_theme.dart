import 'package:flutter/material.dart';
import 'package:smart_refresher/smart_refresher.dart';

class ResolvedIndicatorTheme {
  const ResolvedIndicatorTheme({
    required this.primaryColor,
    required this.trackColor,
    required this.containerColor,
    required this.textStyle,
  });

  final Color primaryColor;
  final Color trackColor;
  final Color containerColor;
  final TextStyle textStyle;
}



abstract final class AppTheme {
  static ThemeData light(Color seedColor) =>
      _buildTheme(seedColor, Brightness.light);

  static ThemeData dark(Color seedColor) =>
      _buildTheme(seedColor, Brightness.dark);

  static ThemeData _buildTheme(Color seedColor, Brightness brightness) {
    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    final bool isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark
          ? colorScheme.surface
          : colorScheme.surfaceContainerLowest,
      cardTheme: CardThemeData(
        elevation: 1.5,
        color: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      extensions: <ThemeExtension<dynamic>>[
        SmartRefresherThemeData(
          textStyle: const TextStyle(fontSize: 13),
          primaryColor: colorScheme.primary,
          trackColor: colorScheme.surfaceContainerHighest,
          material3BackgroundColor: colorScheme.surfaceContainerLow,
          iosTickColor: colorScheme.primary,
          skeletonBoneColor: colorScheme.surfaceContainerHighest,
          skeletonShimmerBaseColor: colorScheme.surfaceContainerHighest,
          skeletonShimmerHighlightColor: colorScheme.surface,
        ),
      ],
    );
  }
}
