import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

void main() {
  testWidgets('Reproduction #645: requestLoading works with short list',
      (WidgetTester tester) async {
    final RefreshController refreshController = RefreshController();
    bool loadingTriggered = false;

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SmartRefresher(
          controller: refreshController,
          enablePullUp: true,
          onLoading: () {
            loadingTriggered = true;
          },
          child: ListView(
            children: const [
              SizedBox(height: 100, child: Text('Small content')),
            ],
          ),
        ),
      ),
    ));

    refreshController.requestLoading();
    // Pump enough frames to trigger the loading
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(loadingTriggered, true,
        reason: 'requestLoading should trigger onLoading even with short list');
  });

  testWidgets('Reproduction #645: requestRefresh works with short list',
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
            children: const [
              SizedBox(height: 100, child: Text('Small content')),
            ],
          ),
        ),
      ),
    ));

    refreshController.requestRefresh();
    // Pump enough frames to trigger the refresh
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(refreshTriggered, true,
        reason: 'requestRefresh should trigger onRefresh even with short list');
  });
}
