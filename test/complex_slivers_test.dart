import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';
import 'package:smart_refresher/src/internals/slivers.dart';

void main() {
  testWidgets('SmartRefresher.slivers handles center key and negative minScrollExtent', (WidgetTester tester) async {
    final RefreshController refreshController = RefreshController();
    final Key centerKey = UniqueKey();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SmartRefresher.slivers(
          controller: refreshController,
          center: centerKey,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (c, i) => ListTile(title: Text('Reverse Item $i')),
                childCount: 5,
              ),
            ),
            SliverList(
              key: centerKey,
              delegate: SliverChildBuilderDelegate(
                (c, i) => ListTile(title: Text('Forward Item $i')),
                childCount: 5,
              ),
            ),
          ],
        ),
      ),
    ));

    await tester.pumpAndSettle();

    final CustomScrollView csv = tester.widget(find.byType(CustomScrollView));
    expect(csv.center, centerKey);
    
    final ScrollPosition pos = tester.state<ScrollableState>(find.byType(Scrollable)).position;
    expect(pos.minScrollExtent, lessThan(-200.0));

    await tester.drag(find.byType(Scrollable), Offset(0, -pos.minScrollExtent + 100));
    await tester.pump();

    expect(refreshController.headerStatus, anyOf(RefreshStatus.canRefresh, RefreshStatus.refreshing));
  });

  testWidgets('SmartRefresher avoids duplicate header insertion', (WidgetTester tester) async {
    final RefreshController refreshController = RefreshController();
    const ClassicHeader header = ClassicHeader();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SmartRefresher.slivers(
          controller: refreshController,
          header: header,
          slivers: [
            header,
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (c, i) => ListTile(title: Text('Item $i')),
                childCount: 5,
              ),
            ),
          ],
        ),
      ),
    ));

    await tester.pumpAndSettle();

    final CustomScrollView csv = tester.widget(find.byType(CustomScrollView));
    // Should only have 2 slivers (Header + List), not 3 (AutoHeader + Header + List)
    expect(csv.slivers.length, 2);
    expect(csv.slivers.first, isA<ClassicHeader>());
  });
}
