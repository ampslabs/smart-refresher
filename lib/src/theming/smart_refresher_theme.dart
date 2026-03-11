import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Theme tokens shared by `smart_refresher` indicators.
///
/// Register this on [ThemeData.extensions] for app-wide defaults, or provide it
/// to [SmartRefresherTheme] for subtree overrides.
@immutable
class SmartRefresherThemeData extends ThemeExtension<SmartRefresherThemeData>
    with Diagnosticable {
  /// Creates theme tokens for `smart_refresher` indicators.
  const SmartRefresherThemeData({
    this.primaryColor,
    this.accentColor,
    this.trackColor,
    this.textColor,
    this.textStyle,
    this.arrowColor,
    this.iconColor,
    this.material3BackgroundColor,
    this.material3Elevation,
    this.iosTickColor,
    this.skeletonBoneColor,
    this.skeletonShimmerBaseColor,
    this.skeletonShimmerHighlightColor,
  });

  /// Color for active elements such as spinners and arrows.
  final Color? primaryColor;

  /// Secondary accent color used by indicators that need a second tone.
  final Color? accentColor;

  /// Color for indicator tracks and rings.
  final Color? trackColor;

  /// Color for status labels when [textStyle] is not provided.
  final Color? textColor;

  /// Full text style override for indicator labels.
  final TextStyle? textStyle;

  /// Color for directional arrow icons.
  final Color? arrowColor;

  /// Color for success and failure icons.
  final Color? iconColor;

  /// Background color for material-style indicator surfaces.
  final Color? material3BackgroundColor;

  /// Elevation for material-style indicator surfaces.
  final double? material3Elevation;

  /// Tick or spoke color for Cupertino-style indicators.
  final Color? iosTickColor;

  /// Base bone color for skeleton indicators.
  final Color? skeletonBoneColor;

  /// Base shimmer color for skeleton indicators.
  final Color? skeletonShimmerBaseColor;

  /// Highlight shimmer color for skeleton indicators.
  final Color? skeletonShimmerHighlightColor;

  /// Returns a copy of this theme with the given fields replaced.
  @override
  SmartRefresherThemeData copyWith({
    Color? primaryColor,
    Color? accentColor,
    Color? trackColor,
    Color? textColor,
    TextStyle? textStyle,
    Color? arrowColor,
    Color? iconColor,
    Color? material3BackgroundColor,
    double? material3Elevation,
    Color? iosTickColor,
    Color? skeletonBoneColor,
    Color? skeletonShimmerBaseColor,
    Color? skeletonShimmerHighlightColor,
  }) {
    return SmartRefresherThemeData(
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      trackColor: trackColor ?? this.trackColor,
      textColor: textColor ?? this.textColor,
      textStyle: textStyle ?? this.textStyle,
      arrowColor: arrowColor ?? this.arrowColor,
      iconColor: iconColor ?? this.iconColor,
      material3BackgroundColor:
          material3BackgroundColor ?? this.material3BackgroundColor,
      material3Elevation: material3Elevation ?? this.material3Elevation,
      iosTickColor: iosTickColor ?? this.iosTickColor,
      skeletonBoneColor: skeletonBoneColor ?? this.skeletonBoneColor,
      skeletonShimmerBaseColor:
          skeletonShimmerBaseColor ?? this.skeletonShimmerBaseColor,
      skeletonShimmerHighlightColor:
          skeletonShimmerHighlightColor ?? this.skeletonShimmerHighlightColor,
    );
  }

  /// Overlays [other] on top of this theme, using non-null values from [other].
  SmartRefresherThemeData merge(SmartRefresherThemeData? other) {
    if (other == null) {
      return this;
    }
    return SmartRefresherThemeData(
      primaryColor: other.primaryColor ?? primaryColor,
      accentColor: other.accentColor ?? accentColor,
      trackColor: other.trackColor ?? trackColor,
      textColor: other.textColor ?? textColor,
      textStyle: other.textStyle ?? textStyle,
      arrowColor: other.arrowColor ?? arrowColor,
      iconColor: other.iconColor ?? iconColor,
      material3BackgroundColor:
          other.material3BackgroundColor ?? material3BackgroundColor,
      material3Elevation: other.material3Elevation ?? material3Elevation,
      iosTickColor: other.iosTickColor ?? iosTickColor,
      skeletonBoneColor: other.skeletonBoneColor ?? skeletonBoneColor,
      skeletonShimmerBaseColor:
          other.skeletonShimmerBaseColor ?? skeletonShimmerBaseColor,
      skeletonShimmerHighlightColor:
          other.skeletonShimmerHighlightColor ?? skeletonShimmerHighlightColor,
    );
  }

  /// Linearly interpolates between two theme extension instances.
  @override
  SmartRefresherThemeData lerp(
    covariant ThemeExtension<SmartRefresherThemeData>? other,
    double t,
  ) {
    if (other is! SmartRefresherThemeData) {
      return this;
    }
    return SmartRefresherThemeData(
      primaryColor: _lerpColor(primaryColor, other.primaryColor, t),
      accentColor: _lerpColor(accentColor, other.accentColor, t),
      trackColor: _lerpColor(trackColor, other.trackColor, t),
      textColor: _lerpColor(textColor, other.textColor, t),
      textStyle: _lerpTextStyle(textStyle, other.textStyle, t),
      arrowColor: _lerpColor(arrowColor, other.arrowColor, t),
      iconColor: _lerpColor(iconColor, other.iconColor, t),
      material3BackgroundColor: _lerpColor(
        material3BackgroundColor,
        other.material3BackgroundColor,
        t,
      ),
      material3Elevation: _lerpNullableDouble(
        material3Elevation,
        other.material3Elevation,
        t,
      ),
      iosTickColor: _lerpColor(iosTickColor, other.iosTickColor, t),
      skeletonBoneColor: _lerpColor(
        skeletonBoneColor,
        other.skeletonBoneColor,
        t,
      ),
      skeletonShimmerBaseColor: _lerpColor(
        skeletonShimmerBaseColor,
        other.skeletonShimmerBaseColor,
        t,
      ),
      skeletonShimmerHighlightColor: _lerpColor(
        skeletonShimmerHighlightColor,
        other.skeletonShimmerHighlightColor,
        t,
      ),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is SmartRefresherThemeData &&
        other.primaryColor == primaryColor &&
        other.accentColor == accentColor &&
        other.trackColor == trackColor &&
        other.textColor == textColor &&
        other.textStyle == textStyle &&
        other.arrowColor == arrowColor &&
        other.iconColor == iconColor &&
        other.material3BackgroundColor == material3BackgroundColor &&
        other.material3Elevation == material3Elevation &&
        other.iosTickColor == iosTickColor &&
        other.skeletonBoneColor == skeletonBoneColor &&
        other.skeletonShimmerBaseColor == skeletonShimmerBaseColor &&
        other.skeletonShimmerHighlightColor == skeletonShimmerHighlightColor;
  }

  @override
  int get hashCode => Object.hashAll(<Object?>[
        primaryColor,
        accentColor,
        trackColor,
        textColor,
        textStyle,
        arrowColor,
        iconColor,
        material3BackgroundColor,
        material3Elevation,
        iosTickColor,
        skeletonBoneColor,
        skeletonShimmerBaseColor,
        skeletonShimmerHighlightColor,
      ]);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      ColorProperty('primaryColor', primaryColor, defaultValue: null),
    );
    properties.add(
      ColorProperty('accentColor', accentColor, defaultValue: null),
    );
    properties.add(ColorProperty('trackColor', trackColor, defaultValue: null));
    properties.add(ColorProperty('textColor', textColor, defaultValue: null));
    properties.add(
      DiagnosticsProperty<TextStyle>(
        'textStyle',
        textStyle,
        defaultValue: null,
      ),
    );
    properties.add(ColorProperty('arrowColor', arrowColor, defaultValue: null));
    properties.add(ColorProperty('iconColor', iconColor, defaultValue: null));
    properties.add(
      ColorProperty(
        'material3BackgroundColor',
        material3BackgroundColor,
        defaultValue: null,
      ),
    );
    properties.add(
      DoubleProperty(
        'material3Elevation',
        material3Elevation,
        defaultValue: null,
      ),
    );
    properties.add(
      ColorProperty('iosTickColor', iosTickColor, defaultValue: null),
    );
    properties.add(
      ColorProperty('skeletonBoneColor', skeletonBoneColor, defaultValue: null),
    );
    properties.add(
      ColorProperty(
        'skeletonShimmerBaseColor',
        skeletonShimmerBaseColor,
        defaultValue: null,
      ),
    );
    properties.add(
      ColorProperty(
        'skeletonShimmerHighlightColor',
        skeletonShimmerHighlightColor,
        defaultValue: null,
      ),
    );
  }
}

/// An inherited theme that provides subtree overrides for `smart_refresher`.
class SmartRefresherTheme extends InheritedTheme {
  /// Creates a subtree theme override for `smart_refresher`.
  const SmartRefresherTheme({
    super.key,
    required this.data,
    required super.child,
  });

  /// The theme tokens to apply to the subtree.
  final SmartRefresherThemeData data;

  /// Returns the nearest resolved [SmartRefresherThemeData].
  ///
  /// Resolution order:
  /// 1. The nearest [SmartRefresherTheme] ancestor.
  /// 2. The nearest [ThemeData] extension.
  /// 3. An empty [SmartRefresherThemeData].
  static SmartRefresherThemeData of(BuildContext context) {
    final SmartRefresherTheme? inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<SmartRefresherTheme>();
    final SmartRefresherThemeData appTheme =
        _maybeThemeOf(context)?.extension<SmartRefresherThemeData>() ??
            const SmartRefresherThemeData();
    return appTheme.merge(inheritedTheme?.data);
  }

  @override
  bool updateShouldNotify(SmartRefresherTheme oldWidget) {
    return data != oldWidget.data;
  }

  @override
  Widget wrap(BuildContext context, Widget child) {
    return SmartRefresherTheme(data: data, child: child);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<SmartRefresherThemeData>('data', data));
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

Color? _lerpColor(Color? a, Color? b, double t) {
  if (a == null && b == null) {
    return null;
  }
  if (a == null || b == null) {
    return t < 0.5 ? a : b;
  }
  return Color.lerp(a, b, t);
}

TextStyle? _lerpTextStyle(TextStyle? a, TextStyle? b, double t) {
  if (a == null && b == null) {
    return null;
  }
  if (a == null || b == null) {
    return t < 0.5 ? a : b;
  }
  return TextStyle.lerp(a, b, t);
}

double? _lerpNullableDouble(double? a, double? b, double t) {
  if (a == null && b == null) {
    return null;
  }
  if (a == null || b == null) {
    return t < 0.5 ? a : b;
  }
  return lerpDouble(a, b, t);
}
