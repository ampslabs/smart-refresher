import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';
import 'data_source.dart';
import 'test_indicator.dart';

void main() {
  group('SmartRefresher edge cases', () {
    testWidgets('gracefully handles missing onRefresh / onLoading callbacks',
        (tester) async {
      final controller = RefreshController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 375,
            height: 690,
            child: SmartRefresher(
              controller: controller,
              enablePullUp: true,
              header: const TestHeader(),
              footer: const TestFooter(),
              // onRefresh and onLoading intentionally omitted
              child: ListView.builder(
                itemBuilder: (context, index) => Text(data[index]),
                itemCount: 20,
                itemExtent: 100,
              ),
            ),
          ),
        ),
      ));

      // Trigger pull-to-refresh
      await tester.drag(find.byType(Scrollable), const Offset(0, 120),
          touchSlopY: 0);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(controller.headerStatus, RefreshStatus.refreshing);

      // Trigger pull-to-load
      controller.position!.jumpTo(controller.position!.maxScrollExtent);
      await tester.pump();
      await tester.drag(find.byType(Scrollable), const Offset(0, -120),
          touchSlopY: 0);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(controller.footerStatus, LoadStatus.loading);
    });

    testWidgets('fast rebuild unmount does not crash on requestRefresh',
        (tester) async {
      final controller = RefreshController();

      // Step 1: Pump Refresher
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SmartRefresher(
            controller: controller,
            child: ListView(),
          ),
        ),
      ));

      // Step 2: Unmount it immediately by replacing the tree
      await tester.pumpWidget(const SizedBox.shrink());

      // Step 3: Call requestRefresh on unmounted controller
      // This should NOT throw an exception
      expect(() => controller.requestRefresh(), returnsNormally);
      expect(() => controller.requestLoading(), returnsNormally);
    });

    testWidgets('tab switching (deactivation) cancels animations cleanly',
        (tester) async {
      final controller = RefreshController();

      await tester.pumpWidget(MaterialApp(
        home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(tabs: [Tab(text: '1'), Tab(text: '2')]),
            ),
            body: TabBarView(
              children: [
                SmartRefresher(
                  controller: controller,
                  child: ListView(),
                ),
                ListView(),
              ],
            ),
          ),
        ),
      ));

      // Start a refresh on tab 1
      controller.requestRefresh();
      await tester.pump(const Duration(milliseconds: 100)); // Start animation
      expect(controller.headerStatus, RefreshStatus.refreshing);

      // Switch to tab 2 to deactivate Tab 1
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();

      // Ensure no animation/ticker crashes occurred during deactivation
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('controller safely ignores identical consecutive attach/detach',
        (tester) async {
      final controller = RefreshController();

      // Test the fix from Phase 1 where sharing a controller threw a null state assertion.
      // E.g. when unmounting one and mounting another, or when reusing.
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SmartRefresher(
            key: const ValueKey(1),
            controller: controller,
            child: ListView(),
          ),
        ),
      ));

      // Replace with another widget using the same controller (e.g. navigation)
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: SmartRefresher(
            key: const ValueKey(2),
            controller: controller,
            child: ListView(),
          ),
        ),
      ));

      expect(controller.headerStatus, RefreshStatus.idle);
      expect(() => controller.requestRefresh(), returnsNormally);
    });
  });
}
