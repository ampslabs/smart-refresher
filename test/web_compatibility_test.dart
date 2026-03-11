import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

void main() {
  testWidgets('Web: mouse drag should trigger refresh',
      (WidgetTester tester) async {
    final RefreshController refreshController = RefreshController();
    bool refreshTriggered = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SmartRefresher(
          controller: refreshController,
          onRefresh: () {
            refreshTriggered = true;
          },
          child: ListView(
            children:
                List.generate(20, (i) => ListTile(title: Text('Item $i'))),
          ),
        ),
      ),
    ));

    // Simulate mouse drag
    final TestGesture gesture = await tester.startGesture(
      tester.getCenter(find.byType(Scrollable)),
      kind: PointerDeviceKind.mouse,
    );
    await gesture.moveBy(const Offset(0, 300));
    await tester.pump();

    expect(refreshController.headerStatus,
        anyOf(RefreshStatus.canRefresh, RefreshStatus.refreshing));

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 100));

    expect(refreshTriggered, true);
  });
}
