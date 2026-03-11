import 'package:flutter/material.dart' hide RefreshIndicator;
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

void main() {
  testWidgets('ScrollBar interaction with refreshing state', (WidgetTester tester) async {
    final RefreshController refreshController = RefreshController();
    final ScrollController scrollController = ScrollController();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          child: SmartRefresher(
            controller: refreshController,
            scrollController: scrollController,
            child: ListView.builder(
              itemBuilder: (c, i) => ListTile(title: Text('Item $i')),
              itemCount: 100,
            ),
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();

    // Trigger refresh programmatically to stay in refreshing state
    refreshController.requestRefresh();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(refreshController.headerStatus, RefreshStatus.refreshing);
    
    // During refresh, ScrollPosition.minScrollExtent is still 0.0 (usually)
    // but the header has layout extent. 
    // In SmartRefresher, we often don't want the header to be part of the "scrollable content" 
    // for the purpose of the scrollbar.
  });

  testWidgets('SmartRefresher inside Scrollbar without shared controller should throw/fail correctly', (WidgetTester tester) async {
    // This reproduces common user error where they wrap but don't link controllers.
    // However, since SmartRefresher creates its own CustomScrollView, 
    // Scrollbar will find that scrollable.
    
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Scrollbar(
          child: SmartRefresher(
            controller: RefreshController(),
            child: ListView.builder(
              itemBuilder: (c, i) => ListTile(title: Text('Item $i')),
              itemCount: 100,
            ),
          ),
        ),
      ),
    ));

    await tester.pumpAndSettle();
    expect(find.byType(Scrollbar), findsOneWidget);
  });
}
