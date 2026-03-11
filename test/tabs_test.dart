import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

void main() {
  testWidgets('Bug #652: TabBarView switching during refreshing',
      (WidgetTester tester) async {
    final RefreshController refreshController1 = RefreshController();
    final RefreshController refreshController2 = RefreshController();

    await tester.pumpWidget(MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              tabs: [Tab(text: 'Tab 1'), Tab(text: 'Tab 2')],
            ),
          ),
          body: TabBarView(
            children: [
              SmartRefresher(
                controller: refreshController1,
                onRefresh: () {},
                child:
                    ListView(children: const [ListTile(title: Text('Item 1'))]),
              ),
              SmartRefresher(
                controller: refreshController2,
                child: const Center(child: Text('Content 2')),
              ),
            ],
          ),
        ),
      ),
    ));

    // Start refresh in Tab 1
    refreshController1.requestRefresh();
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(refreshController1.isRefresh, true);

    // Switch to Tab 2
    await tester.tap(find.text('Tab 2'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Content 2'), findsOneWidget);
  });
}
