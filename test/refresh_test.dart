/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-21 12:22
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

import 'data_source.dart';
import 'test_indicator.dart';

void main() {
  group('trigger refresh function test', () {
    testWidgets('not enough to tigger refresh ', (tester) async {
      final RefreshController refreshController = RefreshController();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ));

      await tester.drag(find.byType(Scrollable), const Offset(0, 50.0),
          touchSlopY: 0.0);
      await tester.pump();
      expect(refreshController.headerStatus, RefreshStatus.idle);
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
    });

    testWidgets('strick to check triggerDistance,even if 0.00001',
        (tester) async {
      final RefreshController refreshController = RefreshController();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ));

      refreshController.position!.jumpTo(0.0);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.drag(find.byType(Scrollable), const Offset(0, 79.999999999),
          touchSlopY: 0.0);
      await tester.pump();
      expect(refreshController.headerStatus, RefreshStatus.idle);
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
    });
    testWidgets('from 0.0 pull down,reach triggerDistance', (tester) async {
      final RefreshController refreshController = RefreshController();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ));
      await tester.drag(find.byType(Scrollable), const Offset(0, 80.0),
          touchSlopY: 0.0);
      await tester.pump();
      expect(refreshController.headerStatus, RefreshStatus.canRefresh);
      await tester.pumpAndSettle();
      expect(refreshController.headerStatus, RefreshStatus.refreshing);
      refreshController.refreshCompleted();
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
    });
    testWidgets('from 100.0 pull down,reach triggerdistance', (tester) async {
      final RefreshController refreshController = RefreshController();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ));

      refreshController.position!.jumpTo(100.0);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.drag(find.byType(Scrollable), const Offset(0, 180.0),
          touchSlopY: 0.0);
      expect(refreshController.headerStatus, RefreshStatus.canRefresh);
      await tester.pumpAndSettle();
      expect(refreshController.headerStatus, RefreshStatus.refreshing);
      refreshController.refreshCompleted();
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
    });
    testWidgets(
        'when user flip with ballistic,it should not be tigger rrerfresh ',
        (tester) async {
      final RefreshController refreshController = RefreshController();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ));

      refreshController.position!.jumpTo(400.0);
      await tester.fling(
          find.byType(Scrollable), const Offset(0, 100.0), 2000.0);
      while (tester.binding.transientCallbackCount > 0) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(refreshController.headerStatus, RefreshStatus.idle);
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
    });
    testWidgets(
        ' when user flip with ballistic from 0.0,it should not be tigger rrerfresh also',
        (tester) async {
      final RefreshController refreshController = RefreshController();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ));

      refreshController.position!.jumpTo(0.0);
      await tester.fling(
          find.byType(Scrollable), const Offset(0, 100.0), 2000.0);
      while (tester.binding.transientCallbackCount > 0) {
        await tester.pump(const Duration(milliseconds: 20));
      }
      expect(refreshController.headerStatus, RefreshStatus.idle);
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
    });
    testWidgets(
        'consider about another situation,if user trriiger refresh, and then drag down(cannot see the header)',
        (tester) async {
      final RefreshController refreshController = RefreshController();
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ));

      refreshController.position!.jumpTo(0.0);
      await tester.drag(find.byType(Scrollable), const Offset(0, 100.0),
          touchSlopY: 0.0);
      await tester.pump(); // refresh to canRefresh
      expect(refreshController.headerStatus, RefreshStatus.canRefresh);
      await tester.pump(const Duration(milliseconds: 100));
      expect(refreshController.headerStatus, RefreshStatus.refreshing);
      await tester.drag(find.byType(Scrollable), const Offset(0, -90.0));
      await tester.pumpAndSettle();
      final double positionRecord = refreshController.position!.pixels;
      refreshController.refreshCompleted();
      await tester.pumpAndSettle(const Duration(milliseconds: 600));
      expect(refreshController.position!.pixels == positionRecord - 60.0,
          true); //60.0 is indicator  visual extent
      await tester.pump(const Duration(milliseconds: 600));
      expect(refreshController.headerStatus, RefreshStatus.idle);
    });
  });

  testWidgets('verity headerTriggerDistance', (tester) async {
    final RefreshController refreshController = RefreshController();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RefreshConfiguration(
        maxOverScrollExtent: 100.0,
        headerTriggerDistance: 100.0,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ),
    ));

    refreshController.position!.jumpTo(0.0);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.drag(find.byType(Scrollable), const Offset(0, 99.999999999),
        touchSlopY: 0.0);
    await tester.pump();
    expect(refreshController.headerStatus, RefreshStatus.idle);
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    expect(refreshController.headerStatus, RefreshStatus.idle);

    refreshController.position!.jumpTo(0.0);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.drag(find.byType(Scrollable), const Offset(0, 100.999999999),
        touchSlopY: 0.0);
    await tester.pump();
    expect(refreshController.headerStatus, RefreshStatus.canRefresh);
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(refreshController.headerStatus, RefreshStatus.refreshing);
  });

  testWidgets('without refresh function ,only twoLevel', (tester) async {
    final RefreshController refreshController = RefreshController();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: RefreshConfiguration(
        maxOverScrollExtent: 100.0,
        child: SmartRefresher(
          header: const ClassicHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          enablePullDown: false,
          enableTwoLevel: true,
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Center(
              child: Text(data[i]),
            ),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ),
    ));

    await tester.drag(find.byType(Scrollable), const Offset(0, 155.999999999),
        touchSlopY: 0.0);
    await tester.pump();
    expect(refreshController.position!.pixels, -155.999999999);
    expect(refreshController.headerStatus, RefreshStatus.canTwoLevel);
    await tester.pumpAndSettle();
    expect(refreshController.headerStatus, RefreshStatus.twoLeveling);
    refreshController.twoLevelComplete();
    await tester.pumpAndSettle();
    expect(refreshController.headerStatus, RefreshStatus.idle);
    await tester.drag(find.byType(Scrollable), const Offset(0, 100.999999999),
        touchSlopY: 0.0);
    await tester.pumpAndSettle();
    expect(refreshController.headerStatus, RefreshStatus.idle);
    expect(refreshController.position!.pixels, 0.0);
  });
}
