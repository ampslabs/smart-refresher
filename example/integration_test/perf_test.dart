import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Scrolling and refreshing performance test', (tester) async {
    final RefreshController controller = RefreshController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SmartRefresher(
            controller: controller,
            enablePullDown: true,
            enablePullUp: true,
            onRefresh: () async {
              await Future<void>.delayed(const Duration(milliseconds: 500));
              controller.refreshCompleted();
            },
            onLoading: () async {
              await Future<void>.delayed(const Duration(milliseconds: 500));
              controller.loadComplete();
            },
            child: ListView.builder(
              itemCount: 1000,
              itemBuilder: (context, index) => ListTile(
                title: Text('Item $index'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Record timeline for scrolling and refreshing
    await binding.traceAction(
      () async {
        // Scroll down
        await tester.fling(
            find.byType(Scrollable), const Offset(0, -1000), 10000);
        await tester.pumpAndSettle();

        // Scroll back up
        await tester.fling(
            find.byType(Scrollable), const Offset(0, 1000), 10000);
        await tester.pumpAndSettle();

        // Pull to refresh
        await tester.fling(find.byType(Scrollable), const Offset(0, 500), 2000);
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      },
      reportKey: 'refresh_scroll_timeline',
    );
  });
}
