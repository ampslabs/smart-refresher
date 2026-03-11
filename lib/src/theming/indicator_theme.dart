import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'smart_refresher_theme.dart';

/// Fully resolved visual values consumed by indicator widgets.
@immutable
class IndicatorThemeData with Diagnosticable {
  /// Creates resolved indicator colors and styles.
  const IndicatorThemeData({
    required this.primaryColor,
    required this.accentColor,
    required this.trackColor,
    required this.textStyle,
    required this.arrowColor,
    required this.iconColor,
    required this.material3BackgroundColor,
    required this.material3Elevation,
    required this.iosTickColor,
    required this.skeletonBoneColor,
    required this.skeletonShimmerBaseColor,
    required this.skeletonShimmerHighlightColor,
  });

  /// Active color for spinners and default icons.
  final Color primaryColor;

  /// Secondary accent color.
  final Color accentColor;

  /// Track or ring color.
  final Color trackColor;

  /// Resolved text style for labels.
  final TextStyle textStyle;

  /// Color for directional arrows.
  final Color arrowColor;

  /// Color for state icons such as success and failure.
  final Color iconColor;

  /// Background color for material-style indicator surfaces.
  final Color material3BackgroundColor;

  /// Elevation for material-style indicator surfaces.
  final double material3Elevation;

  /// Tick color for Cupertino-style indicators.
  final Color iosTickColor;

  /// Bone color for skeleton indicators.
  final Color skeletonBoneColor;

  /// Base shimmer color for skeleton indicators.
  final Color skeletonShimmerBaseColor;

  /// Highlight shimmer color for skeleton indicators.
  final Color skeletonShimmerHighlightColor;

  /// Resolves indicator visuals from explicit props, ambient themes, and
  /// framework defaults.
  factory IndicatorThemeData.resolve(
    BuildContext context, {
    Color? widgetPrimaryColor,
    Color? widgetAccentColor,
    Color? widgetTrackColor,
    Color? widgetTextColor,
    TextStyle? widgetTextStyle,
    Color? widgetArrowColor,
    Color? widgetIconColor,
    Color? widgetMaterial3BackgroundColor,
    double? widgetMaterial3Elevation,
    Color? widgetIosTickColor,
    Color? widgetSkeletonBoneColor,
    Color? widgetSkeletonShimmerBaseColor,
    Color? widgetSkeletonShimmerHighlightColor,
  }) {
    const Color hardcodedFallback = Color(0xFF2196F3);
    final SmartRefresherThemeData refresherTheme = SmartRefresherTheme.of(
      context,
    );
    final ThemeData? theme = _maybeThemeOf(context);
    final ColorScheme? colorScheme = theme?.colorScheme;
    final Brightness brightness = theme?.brightness ?? Brightness.light;
    final bool isDark = brightness == Brightness.dark;

    final Color primary = widgetPrimaryColor ??
        refresherTheme.primaryColor ??
        colorScheme?.primary ??
        hardcodedFallback;
    final Color accent = widgetAccentColor ??
        refresherTheme.accentColor ??
        colorScheme?.secondary ??
        primary;
    final Color track = widgetTrackColor ??
        refresherTheme.trackColor ??
        (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0));
    final Color resolvedTextColor = widgetTextColor ??
        refresherTheme.textColor ??
        colorScheme?.onSurface ??
        (isDark ? Colors.white : Colors.black87);
    final TextStyle textStyle = widgetTextStyle ??
        refresherTheme.textStyle ??
        TextStyle(color: resolvedTextColor, fontSize: 13.0);
    final Color arrow =
        widgetArrowColor ?? refresherTheme.arrowColor ?? primary;
    final Color icon = widgetIconColor ?? refresherTheme.iconColor ?? primary;
    final Color material3Background = widgetMaterial3BackgroundColor ??
        refresherTheme.material3BackgroundColor ??
        colorScheme?.surface ??
        (isDark ? const Color(0xFF1E1E1E) : Colors.white);
    final double material3Elevation =
        widgetMaterial3Elevation ?? refresherTheme.material3Elevation ?? 6.0;
    final Color iosTick = widgetIosTickColor ??
        refresherTheme.iosTickColor ??
        (isDark ? const Color(0xFFAAAAAA) : const Color(0xFF8E8E93));
    final Color skeletonBone = widgetSkeletonBoneColor ??
        refresherTheme.skeletonBoneColor ??
        (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0));
    final Color skeletonShimmerBase = widgetSkeletonShimmerBaseColor ??
        refresherTheme.skeletonShimmerBaseColor ??
        (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEBEBF4));
    final Color skeletonShimmerHighlight =
        widgetSkeletonShimmerHighlightColor ??
            refresherTheme.skeletonShimmerHighlightColor ??
            (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFF4F4F4));

    return IndicatorThemeData(
      primaryColor: primary,
      accentColor: accent,
      trackColor: track,
      textStyle: textStyle,
      arrowColor: arrow,
      iconColor: icon,
      material3BackgroundColor: material3Background,
      material3Elevation: material3Elevation,
      iosTickColor: iosTick,
      skeletonBoneColor: skeletonBone,
      skeletonShimmerBaseColor: skeletonShimmerBase,
      skeletonShimmerHighlightColor: skeletonShimmerHighlight,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('primaryColor', primaryColor));
    properties.add(ColorProperty('accentColor', accentColor));
    properties.add(ColorProperty('trackColor', trackColor));
    properties.add(DiagnosticsProperty<TextStyle>('textStyle', textStyle));
    properties.add(ColorProperty('arrowColor', arrowColor));
    properties.add(ColorProperty('iconColor', iconColor));
    properties.add(
      ColorProperty('material3BackgroundColor', material3BackgroundColor),
    );
    properties.add(DoubleProperty('material3Elevation', material3Elevation));
    properties.add(ColorProperty('iosTickColor', iosTickColor));
    properties.add(ColorProperty('skeletonBoneColor', skeletonBoneColor));
    properties.add(
      ColorProperty('skeletonShimmerBaseColor', skeletonShimmerBaseColor),
    );
    properties.add(
      ColorProperty(
        'skeletonShimmerHighlightColor',
        skeletonShimmerHighlightColor,
      ),
    );
  }
}

ThemeData? _maybeThemeOf(BuildContext context) {
  if (context.findAncestorWidgetOfExactType<MaterialApp>() == null) {
    return null;
  }
  try {
    return Theme.of(context);
  } catch (_) {
    return null;
  }
}
