import 'package:example/main.dart';
import 'package:example/screens/home_screen.dart';
import 'package:example/widgets/indicator_chip_selector.dart';
import 'package:iconify_sdk/iconify_sdk.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildApp() => const IconifyApp(child: SmartRefresherDemoApp());

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(buildApp());
    // IconifyApp mounts its child only after the starter registry's 2s
    // package-path resolution timeout completes, so advance fake time.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  testWidgets('Home screen renders all indicator cards',
      (WidgetTester tester) async {
    await pumpApp(tester);

    expect(find.text('ClassicHeader'), findsOneWidget);
    expect(find.text('Material3Header'), findsOneWidget);
    expect(find.text('Ios17Header'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('SkeletonFooter'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('SkeletonFooter'), findsOneWidget);
  });

  testWidgets('Navigate to ClassicHeader screen', (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('ClassicHeader'));
    await tester.pumpAndSettle();

    expect(find.text('ClassicHeader'), findsWidgets);
    expect(find.text('Options'), findsOneWidget);
  });

  testWidgets('Navigate to Header Comparison screen',
      (WidgetTester tester) async {
    await pumpApp(tester);

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
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pumpAndSettle();

    final DemoAppStateScope scope =
        DemoAppStateScope.of(tester.element(find.byType(HomeScreen)));
    expect(scope.themeMode, ThemeMode.dark);
  });

  testWidgets('Header comparison chip switches indicator',
      (WidgetTester tester) async {
    await pumpApp(tester);

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
