/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-21 13:20
 */

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

import 'data_source.dart';
import 'test_indicator.dart';

void main() {
  group('in Android ClampingScrollPhysics', () {
    testWidgets(
        "clamping physics,when user flip gesture up ,it shouldn't move out of viewport area",
        (tester) async {
      final RefreshController refreshController0 = RefreshController();
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController0,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
        ),
      ));
      await tester.fling(find.byType(Scrollable), const Offset(0, 100), 5200);
      while (tester.binding.transientCallbackCount > 0) {
        expect(
            refreshController0.position!.pixels, greaterThanOrEqualTo(-250.0));
        await tester.pump(const Duration(milliseconds: 20));
      }

      // from bottom flip up
      refreshController0.position!
          .jumpTo(refreshController0.position!.maxScrollExtent);
      await tester.fling(find.byType(Scrollable), const Offset(0, 1000), 5200);
      while (tester.binding.transientCallbackCount > 0) {
        expect(
            refreshController0.position!.pixels, greaterThanOrEqualTo(-250.0));
        await tester.pump(const Duration(milliseconds: 20));
      }

      await tester.fling(find.byType(Scrollable), const Offset(0, -100), 5200);
      while (tester.binding.transientCallbackCount > 0) {
        expect(
            refreshController0.position!.pixels -
                refreshController0.position!.maxScrollExtent,
            lessThanOrEqualTo(250.0));
        await tester.pump(const Duration(milliseconds: 20));
      }

      // from bottom flip up
      refreshController0.position!
          .jumpTo(refreshController0.position!.maxScrollExtent);
      await tester.fling(
          find.byType(Scrollable), const Offset(0, -43000), 5200);
      while (tester.binding.transientCallbackCount > 0) {
        expect(
            refreshController0.position!.pixels -
                refreshController0.position!.maxScrollExtent,
            lessThanOrEqualTo(250.0));
        await tester.pump(const Duration(milliseconds: 20));
      }
    });

    testWidgets('verity if it will spring back when jumpto', (tester) async {
      final RefreshController refreshController0 = RefreshController();
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController0,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
        ),
      ));

      refreshController0.position!.jumpTo(-100.0);
      expect(refreshController0.position!.pixels, -100.0);
      while (tester.binding.transientCallbackCount > 0) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(refreshController0.position!.pixels, 0.0);
    });

    testWidgets("When clamping,enablePullDown = false,it shouldn't overscroll",
        (tester) async {
      final RefreshController refreshController0 = RefreshController();
      await tester.pumpWidget(MaterialApp(
        theme: ThemeData(platform: TargetPlatform.android),
        home: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          enablePullDown: false,
          controller: refreshController0,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
        ),
      ));

      await tester.fling(find.byType(Scrollable), const Offset(0, 100.0), 1000);
      while (tester.binding.transientCallbackCount > 0) {
        expect(refreshController0.position!.pixels, 0.0);
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(refreshController0.position!.pixels, 0.0);

      // just little middle
      refreshController0.position!.jumpTo(200.0);
      await tester.fling(find.byType(Scrollable), const Offset(0, 100.0), 1000);
      while (tester.binding.transientCallbackCount > 0) {
        expect(refreshController0.position!.pixels, greaterThanOrEqualTo(0.0));
        await tester.pump(const Duration(milliseconds: 20));
      }

      // the most doubt stiuation,from bottomest fliping to top
      refreshController0.position!
          .jumpTo(refreshController0.position!.maxScrollExtent);
      await tester.fling(
          find.byType(Scrollable), const Offset(0, 1000.0), 5000);
      while (tester.binding.transientCallbackCount > 0) {
        expect(refreshController0.position!.pixels, greaterThanOrEqualTo(0.0));
        await tester.pump(const Duration(milliseconds: 20));
      }
    });
  });

  testWidgets('maxOverScrollExtent or maxUnderScrollExtent verity ',
      (tester) async {
    final RefreshController refreshController0 = RefreshController();
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(platform: TargetPlatform.android),
      home: RefreshConfiguration(
        maxOverScrollExtent: 240.0,
        maxUnderScrollExtent: 240.0,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController0,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
        ),
      ),
    ));

    await tester.drag(find.byType(Scrollable), const Offset(0, 300.0));
    while (tester.binding.transientCallbackCount > 0) {
      expect(refreshController0.position!.pixels, greaterThanOrEqualTo(-500.0));
      await tester.pump(const Duration(milliseconds: 20));
    }
    expect(refreshController0.position!.pixels, 0.0);

    refreshController0.position!
        .jumpTo(refreshController0.position!.maxScrollExtent);
    await tester.fling(find.byType(Scrollable), const Offset(0, -1000.0), 5000);
    while (tester.binding.transientCallbackCount > 0) {
      expect(
          refreshController0.position!.pixels -
              refreshController0.position!.maxScrollExtent,
          lessThanOrEqualTo(500.0));
      await tester.pump(const Duration(milliseconds: 20));
    }
  });

  testWidgets('verity if refresh physics updated ', (tester) async {
    final RefreshController refreshController = RefreshController();
    await tester.pumpWidget(MaterialApp(
      home: RefreshConfiguration(
        maxOverScrollExtent: 200.0,
        maxUnderScrollExtent: 300.0,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
        ),
      ),
    ));
    expect(
        (refreshController.position!.physics as RefreshPhysics).updateFlag, 1);
    await tester.pumpWidget(MaterialApp(
      home: RefreshConfiguration(
        maxOverScrollExtent: 150.0,
        maxUnderScrollExtent: 300.0,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
        ),
      ),
    ));
    expect(
        (refreshController.position!.physics as RefreshPhysics).updateFlag, 0);
    expect(
        (refreshController.position!.physics as RefreshPhysics)
            .maxOverScrollExtent,
        150);

    await tester.pumpWidget(MaterialApp(
      home: RefreshConfiguration(
        maxOverScrollExtent: 200.0,
        maxUnderScrollExtent: 300.0,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
        ),
      ),
    ));
    expect(
        (refreshController.position!.physics as RefreshPhysics).updateFlag, 1);
    await tester.pumpWidget(MaterialApp(
      home: RefreshConfiguration(
        maxOverScrollExtent: 200.0,
        maxUnderScrollExtent: 300.0,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 23,
            itemExtent: 100,
          ),
        ),
      ),
    ));
    expect(
        (refreshController.position!.physics as RefreshPhysics).updateFlag, 1);
  });

  testWidgets('when viewport not full, pull up can trigger loading',
      (tester) async {
    final RefreshController refreshController0 = RefreshController();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RefreshConfiguration(
        footerTriggerDistance: -30.0,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: CustomFooter(
            builder: (c, m) => Container(),
          ),
          enablePullUp: true,
          controller: refreshController0,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 1,
            itemExtent: 100,
          ),
        ),
      ),
    ));

    await tester.drag(find.byType(Scrollable), const Offset(0, -70.0));
    await tester.pumpAndSettle(const Duration(milliseconds: 2));
    expect(refreshController0.footerStatus, LoadStatus.loading);
    expect(refreshController0.position!.pixels, greaterThanOrEqualTo(0.0));

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RefreshConfiguration(
        footerTriggerDistance: -30.0,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: CustomFooter(
            loadStyle: LoadStyle.HideAlways,
            builder: (c, m) => Container(),
          ),
          enablePullUp: true,
          controller: refreshController0,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 1,
            itemExtent: 100,
          ),
        ),
      ),
    ));

    await tester.drag(find.byType(Scrollable), const Offset(0, -70.0));
    await tester.pumpAndSettle(const Duration(milliseconds: 2));
    expect(refreshController0.footerStatus, LoadStatus.loading);
    expect(refreshController0.position!.pixels, greaterThanOrEqualTo(0.0));
  });
}
