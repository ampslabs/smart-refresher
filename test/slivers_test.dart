import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

void main() {
  testWidgets('SmartRefresher.slivers should build and show header on pull',
      (WidgetTester tester) async {
    final RefreshController refreshController = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SmartRefresher.slivers(
          controller: refreshController,
          onRefresh: refreshController.refreshCompleted,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (c, i) => ListTile(title: Text('Item $i')),
                childCount: 20,
              ),
            ),
          ],
        ),
      ),
    ));

    await tester.pump();

    // Initial state should be idle
    expect(refreshController.headerStatus, RefreshStatus.idle);

    // Drag far enough (150px > default ~80px trigger) to reach canRefresh
    final TestGesture gesture = await tester
        .startGesture(tester.getCenter(find.byType(CustomScrollView)));
    await gesture.moveBy(const Offset(0, 150));
    await tester.pump();

    // Header should react — canRefresh or refreshing
    expect(
      refreshController.headerStatus,
      anyOf(RefreshStatus.canRefresh, RefreshStatus.refreshing),
    );

    // Release and clean up
    await gesture.cancel();
    await tester.pump();
  });
}
