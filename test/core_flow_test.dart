import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

import 'data_source.dart';
import 'test_indicator.dart';

Widget _buildRefresher({
  required RefreshController controller,
  VoidCallback? onRefresh,
  VoidCallback? onLoading,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 375,
        height: 690,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: controller,
          onRefresh: onRefresh,
          onLoading: onLoading,
          child: ListView.builder(
            itemBuilder: (context, index) => Text(data[index]),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ),
    ),
  );
}

Future<void> _triggerRefresh(
    WidgetTester tester, RefreshController controller) async {
  await tester.drag(find.byType(Scrollable), const Offset(0, 120),
      touchSlopY: 0);
  await tester.pump();
  expect(controller.headerStatus, RefreshStatus.canRefresh);
  await tester.pumpAndSettle();
  expect(controller.headerStatus, RefreshStatus.refreshing);
}

Future<void> _triggerLoadMore(
    WidgetTester tester, RefreshController controller) async {
  controller.position!.jumpTo(controller.position!.maxScrollExtent);
  await tester.pump();
  await tester.drag(find.byType(Scrollable), const Offset(0, -120),
      touchSlopY: 0);
  await tester.pump();
  expect(
    controller.footerStatus,
    anyOf(LoadStatus.canLoading, LoadStatus.loading),
  );
  await tester.pumpAndSettle();
  expect(controller.footerStatus, LoadStatus.loading);
}

void main() {
  group('core refresh and load flow', () {
    testWidgets('pull-to-refresh trigger enters refreshing state',
        (tester) async {
      final RefreshController controller = RefreshController();
      int refreshCalls = 0;

      await tester.pumpWidget(_buildRefresher(
        controller: controller,
        onRefresh: () {
          refreshCalls++;
        },
      ));

      await _triggerRefresh(tester, controller);

      expect(refreshCalls, 1);
      expect(find.text('refreshing'), findsOneWidget);
    });

    testWidgets('pull-to-refresh completion returns to idle', (tester) async {
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(_buildRefresher(controller: controller));

      await _triggerRefresh(tester, controller);
      controller.refreshCompleted();
      await tester.pump();

      expect(controller.headerStatus, RefreshStatus.completed);
      expect(find.text('completed'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      expect(controller.headerStatus, RefreshStatus.idle);
      expect(find.text('idle'), findsWidgets);
    });

    testWidgets('pull-to-refresh failure shows failed state', (tester) async {
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(_buildRefresher(controller: controller));

      await _triggerRefresh(tester, controller);
      controller.refreshFailed();
      await tester.pump();

      expect(controller.headerStatus, RefreshStatus.failed);
      expect(find.text('failed'), findsOneWidget);

      await tester.pumpAndSettle(const Duration(milliseconds: 600));
    });

    testWidgets('load-more trigger enters loading state', (tester) async {
      final RefreshController controller = RefreshController();
      int loadCalls = 0;

      await tester.pumpWidget(_buildRefresher(
        controller: controller,
        onLoading: () {
          loadCalls++;
        },
      ));

      await _triggerLoadMore(tester, controller);

      expect(loadCalls, 1);
      expect(find.text('loading'), findsOneWidget);
    });

    testWidgets('load-more completion returns footer to idle', (tester) async {
      final RefreshController controller = RefreshController();

      await tester.pumpWidget(_buildRefresher(controller: controller));

      await _triggerLoadMore(tester, controller);
      controller.loadComplete();
      controller.position!.jumpTo(controller.position!.maxScrollExtent - 30);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      expect(controller.footerStatus, LoadStatus.idle);
      expect(find.text('idle'), findsWidgets);
    });
  });
}
