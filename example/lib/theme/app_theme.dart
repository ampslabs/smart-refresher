import 'package:flutter/material.dart';

class IndicatorThemeData {
  const IndicatorThemeData({
    this.primaryColor,
    this.trackColor,
    this.containerColor,
    this.textStyle,
  });

  final Color? primaryColor;
  final Color? trackColor;
  final Color? containerColor;
  final TextStyle? textStyle;

  IndicatorThemeData copyWith({
    Color? primaryColor,
    Color? trackColor,
    Color? containerColor,
    TextStyle? textStyle,
  }) {
    return IndicatorThemeData(
      primaryColor: primaryColor ?? this.primaryColor,
      trackColor: trackColor ?? this.trackColor,
      containerColor: containerColor ?? this.containerColor,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  IndicatorThemeData lerp(IndicatorThemeData? other, double t) {
    if (other == null) {
      return this;
    }
    return IndicatorThemeData(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t),
      trackColor: Color.lerp(trackColor, other.trackColor, t),
      containerColor: Color.lerp(containerColor, other.containerColor, t),
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
    );
  }
}

class SmartRefresherThemeData extends ThemeExtension<SmartRefresherThemeData> {
  const SmartRefresherThemeData({
    this.textStyle,
    this.classicHeader = const IndicatorThemeData(),
    this.classicFooter = const IndicatorThemeData(),
    this.material3Header = const IndicatorThemeData(),
    this.ios17Header = const IndicatorThemeData(),
    this.skeletonFooter = const IndicatorThemeData(),
  });

  final TextStyle? textStyle;
  final IndicatorThemeData classicHeader;
  final IndicatorThemeData classicFooter;
  final IndicatorThemeData material3Header;
  final IndicatorThemeData ios17Header;
  final IndicatorThemeData skeletonFooter;

  static SmartRefresherThemeData fallback(BuildContext context) {
    return Theme.of(context).extension<SmartRefresherThemeData>() ??
        const SmartRefresherThemeData();
  }

  @override
  SmartRefresherThemeData copyWith({
    TextStyle? textStyle,
    IndicatorThemeData? classicHeader,
    IndicatorThemeData? classicFooter,
    IndicatorThemeData? material3Header,
    IndicatorThemeData? ios17Header,
    IndicatorThemeData? skeletonFooter,
  }) {
    return SmartRefresherThemeData(
      textStyle: textStyle ?? this.textStyle,
      classicHeader: classicHeader ?? this.classicHeader,
      classicFooter: classicFooter ?? this.classicFooter,
      material3Header: material3Header ?? this.material3Header,
      ios17Header: ios17Header ?? this.ios17Header,
      skeletonFooter: skeletonFooter ?? this.skeletonFooter,
    );
  }

  @override
  SmartRefresherThemeData lerp(
    covariant ThemeExtension<SmartRefresherThemeData>? other,
    double t,
  ) {
    if (other is! SmartRefresherThemeData) {
      return this;
    }
    return SmartRefresherThemeData(
      textStyle: TextStyle.lerp(textStyle, other.textStyle, t),
      classicHeader: classicHeader.lerp(other.classicHeader, t),
      classicFooter: classicFooter.lerp(other.classicFooter, t),
      material3Header: material3Header.lerp(other.material3Header, t),
      ios17Header: ios17Header.lerp(other.ios17Header, t),
      skeletonFooter: skeletonFooter.lerp(other.skeletonFooter, t),
    );
  }
}

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

class IndicatorResolution {
  const IndicatorResolution({required this.data, required this.trace});

  final ResolvedIndicatorTheme data;
  final Map<String, String> trace;
}

IndicatorResolution resolveIndicatorTheme(
  BuildContext context, {
  IndicatorThemeData? widgetTheme,
  required IndicatorThemeData themedDefaults,
  required Color schemePrimary,
  required Color schemeTrack,
  required Color schemeContainer,
  String themeLayerLabel = 'SmartRefresherTheme (layer 2)',
}) {
  final ThemeData theme = Theme.of(context);
  final SmartRefresherThemeData refresherTheme =
      SmartRefresherThemeData.fallback(context);
  final TextStyle fallbackTextStyle =
      theme.textTheme.bodySmall ?? const TextStyle(fontSize: 13.0);

  final Map<String, String> trace = <String, String>{};

  Color resolveColor(
    String field,
    Color? widgetValue,
    Color? themeValue,
    Color schemeValue,
  ) {
    if (widgetValue != null) {
      trace[field] = 'widget prop (layer 1)';
      return widgetValue;
    }
    if (themeValue != null) {
      trace[field] = themeLayerLabel;
      return themeValue;
    }
    trace[field] = 'ThemeData.colorScheme (layer 4)';
    return schemeValue;
  }

  TextStyle resolveTextStyle(TextStyle? widgetValue, TextStyle? themeValue) {
    if (widgetValue != null) {
      trace['textStyle'] = 'widget prop (layer 1)';
      return widgetValue;
    }
    if (themeValue != null) {
      trace['textStyle'] = 'SmartRefresherTheme.textStyle (layer 2)';
      return themeValue;
    }
    if (refresherTheme.textStyle != null) {
      trace['textStyle'] = 'SmartRefresherTheme.textStyle (layer 2)';
      return refresherTheme.textStyle!;
    }
    trace['textStyle'] = 'ThemeData.textTheme.bodySmall (layer 4)';
    return fallbackTextStyle;
  }

  return IndicatorResolution(
    data: ResolvedIndicatorTheme(
      primaryColor: resolveColor(
        'primaryColor',
        widgetTheme?.primaryColor,
        themedDefaults.primaryColor,
        schemePrimary,
      ),
      trackColor: resolveColor(
        'trackColor',
        widgetTheme?.trackColor,
        themedDefaults.trackColor,
        schemeTrack,
      ),
      containerColor: resolveColor(
        'containerColor',
        widgetTheme?.containerColor,
        themedDefaults.containerColor,
        schemeContainer,
      ),
      textStyle: resolveTextStyle(
        widgetTheme?.textStyle,
        themedDefaults.textStyle,
      ),
    ),
    trace: trace,
  );
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
          classicHeader: IndicatorThemeData(
            primaryColor: colorScheme.primary,
            trackColor: colorScheme.surfaceContainerHighest,
            containerColor: colorScheme.surface,
          ),
          classicFooter: IndicatorThemeData(
            primaryColor: colorScheme.secondary,
            trackColor: colorScheme.surfaceContainerHighest,
            containerColor: colorScheme.surface,
          ),
          material3Header: IndicatorThemeData(
            primaryColor: colorScheme.primary,
            trackColor: colorScheme.surfaceContainerHighest,
            containerColor: colorScheme.surfaceContainerLow,
          ),
          ios17Header: IndicatorThemeData(
            primaryColor: colorScheme.primary,
            trackColor: colorScheme.surfaceContainerHighest,
            containerColor: colorScheme.surface,
          ),
          skeletonFooter: IndicatorThemeData(
            primaryColor: colorScheme.primary,
            trackColor: colorScheme.surfaceContainerHighest,
            containerColor: colorScheme.surfaceContainer,
          ),
        ),
      ],
    );
  }
}
