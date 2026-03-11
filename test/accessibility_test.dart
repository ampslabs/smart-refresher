import 'package:flutter/material.dart' hide RefreshIndicator, RefreshIndicatorState;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

void main() {
  group('ClassicHeader Semantics', () {
    testWidgets('reports default semantics label', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final RefreshController controller = RefreshController();
      await tester.pumpWidget(_buildTestApp(
        controller: controller,
        header: const ClassicHeader(),
      ));

      // Force it to be visible by dragging
      await tester.drag(find.byType(Scrollable), const Offset(0, 100));
      await tester.pump();

      expect(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Pull down Refresh'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('reports custom semantics label and hint', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final RefreshController controller = RefreshController();
      await tester.pumpWidget(_buildTestApp(
        controller: controller,
        header: const ClassicHeader(
          semanticsLabel: 'Custom Label',
          semanticsHint: 'Custom Hint',
        ),
      ));

      await tester.drag(find.byType(Scrollable), const Offset(0, 100));
      await tester.pump();

      expect(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Custom Label' && w.properties.hint == 'Custom Hint'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('Material3Header Semantics', () {
    testWidgets('reports default semantics label', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final RefreshController controller = RefreshController();
      await tester.pumpWidget(_buildTestApp(
        controller: controller,
        header: const Material3Header(),
      ));

      await tester.drag(find.byType(Scrollable), const Offset(0, 100));
      await tester.pump();

      expect(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Pull down Refresh'),
        findsAtLeastNWidgets(1),
      );
      handle.dispose();
    });
  });

  group('iOS17Header Semantics', () {
    testWidgets('reports default semantics label', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final RefreshController controller = RefreshController();
      await tester.pumpWidget(_buildTestApp(
        controller: controller,
        header: const iOS17Header(),
      ));

      await tester.drag(find.byType(Scrollable), const Offset(0, 100));
      await tester.pump();

      expect(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Pull down Refresh'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('SkeletonFooter Semantics', () {
    testWidgets('reports default semantics label when loading', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final RefreshController controller = RefreshController();
      await tester.pumpWidget(_buildTestApp(
        controller: controller,
        footer: const SkeletonFooter(),
      ));

      controller.requestLoading();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Loading…'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('WaterDropHeader Semantics', () {
    testWidgets('reports default semantics label', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final RefreshController controller = RefreshController();
      await tester.pumpWidget(_buildTestApp(
        controller: controller,
        header: const WaterDropHeader(),
      ));

      await tester.drag(find.byType(Scrollable), const Offset(0, 100));
      await tester.pump();

      expect(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Pull down Refresh'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });

  group('BezierHeader Semantics', () {
    testWidgets('reports default semantics label', (WidgetTester tester) async {
      final SemanticsHandle handle = tester.ensureSemantics();
      final RefreshController controller = RefreshController();
      await tester.pumpWidget(_buildTestApp(
        controller: controller,
        header: const BezierHeader(),
      ));

      await tester.drag(find.byType(Scrollable), const Offset(0, 100));
      await tester.pump();

      expect(
        find.byWidgetPredicate((w) => w is Semantics && w.properties.label == 'Pull down Refresh'),
        findsOneWidget,
      );
      handle.dispose();
    });
  });
}

Widget _buildTestApp({
  RefreshController? controller,
  Widget? header,
  Widget? footer,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SmartRefresher(
        controller: controller ?? RefreshController(),
        header: header,
        footer: footer,
        enablePullUp: footer != null,
        child: ListView.builder(
          itemBuilder: (c, i) => Text('Item $i'),
          itemCount: 20,
        ),
      ),
    ),
  );
}
