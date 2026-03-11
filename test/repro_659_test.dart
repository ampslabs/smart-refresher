import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

void main() {
  testWidgets('Reproduction #659: Physics jitter and refresh trigger',
      (WidgetTester tester) async {
    final RefreshController refreshController = RefreshController();
    bool refreshTriggered = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SmartRefresher(
          controller: refreshController,
          header: const ClassicHeader(),
          onRefresh: () {
            refreshTriggered = true;
          },
          child: ListView.builder(
            itemBuilder: (c, i) => ListTile(title: Text('Item $i')),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ),
    ));

    // Simulate a pull-to-refresh
    await tester.drag(find.byType(Scrollable), const Offset(0, 300.0),
        touchSlopY: 0.0);
    await tester.pump();
    expect(refreshController.headerStatus, RefreshStatus.canRefresh);

    // Pump to start ballistic
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(refreshController.headerStatus, RefreshStatus.refreshing);
    expect(refreshTriggered, true);

    // Complete refresh
    refreshController.refreshCompleted();
    await tester.pumpAndSettle();

    expect(refreshController.isRefresh, false);
  });

  testWidgets(
      'Reproduction #659: Context error handling in Ballistic Simulation',
      (WidgetTester tester) async {
    final RefreshController refreshController = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SmartRefresher(
          controller: refreshController,
          child: ListView(
            children: const [ListTile(title: Text('Item 1'))],
          ),
        ),
      ),
    ));

    // Drag down to create a ballistic simulation later
    final gesture = await tester.startGesture(const Offset(400, 400));
    await gesture.moveBy(const Offset(0, 200));

    // Release gesture to start ballistic simulation
    await gesture.up();

    // While the simulation is running, immediately replace the widget tree.
    // The fix (try-catch) should prevent any unhandled exceptions from crashing the test.
    await tester
        .pumpWidget(const MaterialApp(home: Scaffold(body: Text('Gone'))));

    await tester.pump(const Duration(milliseconds: 10));
    await tester.pump(const Duration(milliseconds: 10));
  });
}
