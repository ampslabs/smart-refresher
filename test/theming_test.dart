import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

void main() {
  group('SmartRefresherThemeData', () {
    const SmartRefresherThemeData data = SmartRefresherThemeData(
      primaryColor: Colors.blue,
      accentColor: Colors.green,
      trackColor: Colors.grey,
      textColor: Colors.black,
      textStyle: TextStyle(fontSize: 14),
      arrowColor: Colors.orange,
      iconColor: Colors.red,
      material3BackgroundColor: Colors.white,
      material3Elevation: 8.0,
      iosTickColor: Colors.purple,
      skeletonBoneColor: Colors.brown,
      skeletonShimmerBaseColor: Colors.cyan,
      skeletonShimmerHighlightColor: Colors.indigo,
    );

    test('copyWith returns correct fields', () {
      final SmartRefresherThemeData result = data.copyWith(
        primaryColor: Colors.red,
      );

      expect(result.primaryColor, Colors.red);
      expect(result.accentColor, data.accentColor);
      expect(result.trackColor, data.trackColor);
    });

    test('copyWith with no args returns equivalent', () {
      expect(data.copyWith(), data);
    });

    test('lerp(other, 0.0) returns self values', () {
      const SmartRefresherThemeData other = SmartRefresherThemeData(
        primaryColor: Colors.red,
      );

      final SmartRefresherThemeData result = data.lerp(other, 0.0);

      expect(result.primaryColor?.toARGB32(), data.primaryColor?.toARGB32());
      expect(result.accentColor, data.accentColor);
      expect(result.material3Elevation, data.material3Elevation);
    });

    test('lerp(other, 1.0) returns other values', () {
      const SmartRefresherThemeData other = SmartRefresherThemeData(
        primaryColor: Colors.red,
        material3Elevation: 2.0,
      );

      final SmartRefresherThemeData result = data.lerp(other, 1.0);

      expect(result.primaryColor, const Color(0xFFF44336));
      expect(result.material3Elevation, other.material3Elevation);
    });

    test('lerp(other, 0.5) interpolates color and double', () {
      const SmartRefresherThemeData other = SmartRefresherThemeData(
        primaryColor: Colors.red,
        material3Elevation: 2.0,
      );

      final SmartRefresherThemeData result = data.lerp(other, 0.5);

      expect(
        result.primaryColor,
        Color.lerp(data.primaryColor, other.primaryColor, 0.5),
      );
      expect(
        result.material3Elevation,
        lerpDouble(data.material3Elevation, other.material3Elevation, 0.5),
      );
    });

    test('lerp(null, t) returns self', () {
      expect(data.lerp(null, 0.5), data);
    });

    test('equality and hashCode use field values', () {
      const SmartRefresherThemeData same = SmartRefresherThemeData(
        primaryColor: Colors.blue,
      );
      const SmartRefresherThemeData sameAgain = SmartRefresherThemeData(
        primaryColor: Colors.blue,
      );
      const SmartRefresherThemeData different = SmartRefresherThemeData(
        primaryColor: Colors.red,
      );

      expect(same, sameAgain);
      expect(same.hashCode, sameAgain.hashCode);
      expect(same == different, isFalse);
    });
  });

  group('SmartRefresherTheme widget', () {
    testWidgets('of finds nearest ancestor and preserves extension fallbacks', (
      WidgetTester tester,
    ) async {
      SmartRefresherThemeData? captured;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              SmartRefresherThemeData(
                primaryColor: Colors.blue,
                accentColor: Colors.orange,
              ),
            ],
          ),
          home: SmartRefresherTheme(
            data: const SmartRefresherThemeData(primaryColor: Colors.green),
            child: Builder(
              builder: (BuildContext context) {
                captured = SmartRefresherTheme.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(captured!.primaryColor, Colors.green);
      expect(captured!.accentColor, Colors.orange);
    });

    testWidgets('of falls back to ThemeData extension', (
      WidgetTester tester,
    ) async {
      SmartRefresherThemeData? captured;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              SmartRefresherThemeData(primaryColor: Colors.blue),
            ],
          ),
          home: Builder(
            builder: (BuildContext context) {
              captured = SmartRefresherTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(captured!.primaryColor, Colors.blue);
    });

    testWidgets('of returns empty data when no ancestor and no extension', (
      WidgetTester tester,
    ) async {
      SmartRefresherThemeData? captured;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (BuildContext context) {
              captured = SmartRefresherTheme.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(captured, const SmartRefresherThemeData());
    });

    test('updateShouldNotify tracks data changes', () {
      const SmartRefresherTheme theme = SmartRefresherTheme(
        data: SmartRefresherThemeData(primaryColor: Colors.blue),
        child: SizedBox(),
      );
      const SmartRefresherTheme sameTheme = SmartRefresherTheme(
        data: SmartRefresherThemeData(primaryColor: Colors.blue),
        child: SizedBox(),
      );
      const SmartRefresherTheme changedTheme = SmartRefresherTheme(
        data: SmartRefresherThemeData(primaryColor: Colors.red),
        child: SizedBox(),
      );

      expect(theme.updateShouldNotify(sameTheme), isFalse);
      expect(theme.updateShouldNotify(changedTheme), isTrue);
    });

    testWidgets('wrap returns SmartRefresherTheme with same data', (
      WidgetTester tester,
    ) async {
      const SmartRefresherTheme theme = SmartRefresherTheme(
        data: SmartRefresherThemeData(primaryColor: Colors.blue),
        child: SizedBox(),
      );
      late Widget wrapped;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (BuildContext context) {
              wrapped = theme.wrap(context, const SizedBox());
              return const SizedBox();
            },
          ),
        ),
      );

      expect(wrapped, isA<SmartRefresherTheme>());
      expect((wrapped as SmartRefresherTheme).data, theme.data);
    });
  });

  group('IndicatorThemeData.resolve', () {
    testWidgets('widget prop wins over subtree theme', (
      WidgetTester tester,
    ) async {
      late IndicatorThemeData theme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              SmartRefresherThemeData(primaryColor: Colors.blue),
            ],
          ),
          home: SmartRefresherTheme(
            data: const SmartRefresherThemeData(primaryColor: Colors.green),
            child: Builder(
              builder: (BuildContext context) {
                theme = IndicatorThemeData.resolve(
                  context,
                  widgetPrimaryColor: Colors.red,
                );
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(theme.primaryColor, Colors.red);
    });

    testWidgets('subtree theme wins over ThemeData extension', (
      WidgetTester tester,
    ) async {
      late IndicatorThemeData theme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            extensions: const <ThemeExtension<dynamic>>[
              SmartRefresherThemeData(primaryColor: Colors.blue),
            ],
          ),
          home: SmartRefresherTheme(
            data: const SmartRefresherThemeData(primaryColor: Colors.green),
            child: Builder(
              builder: (BuildContext context) {
                theme = IndicatorThemeData.resolve(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(theme.primaryColor, Colors.green);
    });

    testWidgets('ThemeData extension wins over colorScheme', (
      WidgetTester tester,
    ) async {
      late IndicatorThemeData theme;
      final ThemeData appTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        extensions: const <ThemeExtension<dynamic>>[
          SmartRefresherThemeData(primaryColor: Colors.blue),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          home: Builder(
            builder: (BuildContext context) {
              theme = IndicatorThemeData.resolve(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(theme.primaryColor, Colors.blue);
    });

    testWidgets('colorScheme.primary is the fallback', (
      WidgetTester tester,
    ) async {
      late IndicatorThemeData theme;
      final ThemeData appTheme = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: appTheme,
          home: Builder(
            builder: (BuildContext context) {
              theme = IndicatorThemeData.resolve(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(theme.primaryColor, appTheme.colorScheme.primary);
    });

    testWidgets(
      'Cupertino fallback does not throw and uses hardcoded default',
      (WidgetTester tester) async {
        late IndicatorThemeData theme;

        await tester.pumpWidget(
          CupertinoApp(
            home: Builder(
              builder: (BuildContext context) {
                theme = IndicatorThemeData.resolve(context);
                return const SizedBox();
              },
            ),
          ),
        );

        expect(theme.primaryColor, const Color(0xFF2196F3));
      },
    );

    testWidgets('dark mode defaults adapt automatically', (
      WidgetTester tester,
    ) async {
      late IndicatorThemeData theme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Builder(
            builder: (BuildContext context) {
              theme = IndicatorThemeData.resolve(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(theme.trackColor, const Color(0xFF3A3A3A));
      expect(theme.iosTickColor, const Color(0xFFAAAAAA));
      expect(theme.skeletonBoneColor, const Color(0xFF3A3A3A));
    });

    testWidgets('light mode track color uses light fallback', (
      WidgetTester tester,
    ) async {
      late IndicatorThemeData theme;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Builder(
            builder: (BuildContext context) {
              theme = IndicatorThemeData.resolve(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(theme.trackColor, const Color(0xFFE0E0E0));
    });
  });
}
