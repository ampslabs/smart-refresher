import 'package:example/main.dart';
import 'package:example/screens/home_screen.dart';
import 'package:example/widgets/indicator_chip_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home screen renders all indicator cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmartRefresherDemoApp());
    await tester.pumpAndSettle();

    expect(find.text('ClassicHeader'), findsOneWidget);
    expect(find.text('Material3Header'), findsOneWidget);
    expect(find.text('iOS17Header'), findsOneWidget);
    expect(find.text('SkeletonFooter'), findsOneWidget);
  });

  testWidgets('Navigate to ClassicHeader screen', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartRefresherDemoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ClassicHeader'));
    await tester.pumpAndSettle();

    expect(find.text('ClassicHeader'), findsWidgets);
    expect(find.text('Options'), findsOneWidget);
  });

  testWidgets('Navigate to Header Comparison screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmartRefresherDemoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compare All Headers →'));
    await tester.pumpAndSettle();

    expect(find.text('Header Comparison'), findsOneWidget);
    expect(
        find.byWidgetPredicate(
            (Widget widget) => widget is IndicatorChipSelector),
        findsOneWidget);
  });

  testWidgets('Dark mode toggle changes ThemeMode',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmartRefresherDemoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();

    final DemoAppStateScope scope =
        DemoAppStateScope.of(tester.element(find.byType(HomeScreen)));
    expect(scope.themeMode, ThemeMode.dark);
  });

  testWidgets('Header comparison chip switches indicator',
      (WidgetTester tester) async {
    await tester.pumpWidget(const SmartRefresherDemoApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Compare All Headers →'));
    await tester.pumpAndSettle();

    FilterChip classicChip =
        tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Classic'));
    expect(classicChip.selected, isTrue);

    await tester.tap(find.text('Material 3'));
    await tester.pumpAndSettle();

    final FilterChip materialChip = tester
        .widget<FilterChip>(find.widgetWithText(FilterChip, 'Material 3'));
    classicChip =
        tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Classic'));
    expect(materialChip.selected, isTrue);
    expect(classicChip.selected, isFalse);
  });
}
