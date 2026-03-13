/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-20 21:03
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';

import 'data_source.dart';
import 'test_indicator.dart';

Widget buildRefresher(RefreshController controller, {int count = 20}) {
  return RefreshConfiguration(
    maxOverScrollExtent: 180,
    closeTwoLevelDistance: 400.0,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: 375.0,
        height: 690.0,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enableTwoLevel: true,
          enablePullUp: true,
          controller: controller,
          child: ListView.builder(
            itemBuilder: (c, i) => Text(data[i]),
            itemCount: count,
            itemExtent: 100,
          ),
        ),
      ),
    ),
  );
}

// consider two situation, the one is Viewport full,second is Viewport not full
void testRequestFun(bool full) {
  testWidgets('requestRefresh(init),requestLoading function,requestTwoLevel',
      (tester) async {
    final RefreshController refreshController =
        RefreshController(initialRefresh: true);

    await tester
        .pumpWidget(buildRefresher(refreshController, count: full ? 20 : 1));
    //init Refresh
    await tester.pumpAndSettle();
    expect(refreshController.headerStatus, RefreshStatus.refreshing);
    refreshController.refreshCompleted();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(refreshController.headerStatus, RefreshStatus.idle);

    refreshController.position!.jumpTo(200.0);
    refreshController.requestRefresh();
    await tester.pumpAndSettle();
    refreshController.refreshCompleted();
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(refreshController.headerStatus, RefreshStatus.idle);

    refreshController.requestLoading();
    await tester.pumpAndSettle();
    expect(refreshController.footerStatus, LoadStatus.loading);
    refreshController.loadComplete();
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle(const Duration(milliseconds: 2000));
    refreshController.position!.jumpTo(0);
    refreshController.requestTwoLevel();
    await tester.pumpAndSettle(const Duration(milliseconds: 200));
    expect(refreshController.headerStatus, RefreshStatus.twoLeveling);
    refreshController.twoLevelComplete();
    await tester.pumpAndSettle();
    expect(refreshController.headerStatus, RefreshStatus.idle);
  });

  testWidgets('requestRefresh needCallBack test', (tester) async {
    final RefreshController refreshController = RefreshController();
    int timerr = 0;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SizedBox(
        width: 375.0,
        height: 690.0,
        child: SmartRefresher(
          header: const TestHeader(),
          footer: const TestFooter(),
          enablePullUp: true,
          onRefresh: () {
            timerr++;
          },
          onLoading: () {
            timerr++;
          },
          controller: refreshController,
          child: ListView.builder(
            itemBuilder: (c, i) => Text(data[i]),
            itemCount: 20,
            itemExtent: 100,
          ),
        ),
      ),
    ));
    refreshController.requestRefresh(needCallback: false);
    await tester.pumpAndSettle();
    expect(timerr, 0);

    refreshController.requestLoading(needCallback: false);
    await tester.pumpAndSettle();
    expect(timerr, 0);
  });
}

void main() {
  test('check RefreshController inital param ', () async {
    final RefreshController refreshController = RefreshController(
        initialRefreshStatus: RefreshStatus.idle,
        initialLoadStatus: LoadStatus.noMore);

    expect(refreshController.headerMode!.value, RefreshStatus.idle);

    expect(refreshController.footerMode!.value, LoadStatus.noMore);
  });

  group('controller lifecycle widget flow', () {
    testWidgets('requestRefresh enters refreshing and calls onRefresh',
        (tester) async {
      final RefreshController refreshController = RefreshController();
      int refreshCalls = 0;

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 375.0,
          height: 690.0,
          child: SmartRefresher(
            header: const TestHeader(),
            footer: const TestFooter(),
            enablePullUp: true,
            onRefresh: () {
              refreshCalls++;
            },
            controller: refreshController,
            child: ListView.builder(
              itemBuilder: (c, i) => Text(data[i]),
              itemCount: 20,
              itemExtent: 100,
            ),
          ),
        ),
      ));

      refreshController.requestRefresh();
      await tester.pumpAndSettle();

      expect(refreshController.headerStatus, RefreshStatus.refreshing);
      expect(refreshCalls, 1);
    });

    testWidgets('requestLoading enters loading and calls onLoading',
        (tester) async {
      final RefreshController refreshController = RefreshController();
      int loadCalls = 0;

      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(
          width: 375.0,
          height: 690.0,
          child: SmartRefresher(
            header: const TestHeader(),
            footer: const TestFooter(),
            enablePullUp: true,
            onLoading: () {
              loadCalls++;
            },
            controller: refreshController,
            child: ListView.builder(
              itemBuilder: (c, i) => Text(data[i]),
              itemCount: 20,
              itemExtent: 100,
            ),
          ),
        ),
      ));

      refreshController.requestLoading();
      await tester.pumpAndSettle();

      expect(refreshController.footerStatus, LoadStatus.loading);
      expect(loadCalls, 1);
    });

    testWidgets('refreshCompleted returns header to idle after requestRefresh',
        (tester) async {
      final RefreshController refreshController = RefreshController();

      await tester.pumpWidget(buildRefresher(refreshController));

      refreshController.requestRefresh();
      await tester.pumpAndSettle();
      expect(refreshController.headerStatus, RefreshStatus.refreshing);

      refreshController.refreshCompleted();
      await tester.pump();

      expect(refreshController.headerStatus, RefreshStatus.completed);

      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      expect(refreshController.headerStatus, RefreshStatus.idle);
    });

    testWidgets('loadComplete returns footer to idle after requestLoading',
        (tester) async {
      final RefreshController refreshController = RefreshController();

      await tester.pumpWidget(buildRefresher(refreshController));

      refreshController.requestLoading();
      await tester.pumpAndSettle();
      expect(refreshController.footerStatus, LoadStatus.loading);

      refreshController.loadComplete();
      refreshController.position!
          .jumpTo(refreshController.position!.maxScrollExtent - 30);
      await tester.pump();
      await tester.pumpAndSettle(const Duration(milliseconds: 600));

      expect(refreshController.footerStatus, LoadStatus.idle);
    });

    testWidgets('dispose detaches widget state and disposes controller',
        (tester) async {
      final RefreshController refreshController = RefreshController();

      await tester.pumpWidget(buildRefresher(refreshController));

      expect(refreshController.position, isNotNull);
      expect(refreshController.headerMode, isNotNull);
      expect(refreshController.footerMode, isNotNull);

      await tester.pumpWidget(const SizedBox.shrink());

      // position survives until explicit dispose
      expect(refreshController.position, isNotNull);
      expect(refreshController.headerStatus, RefreshStatus.idle);

      refreshController.dispose();

      expect(refreshController.headerMode, isNull);
      expect(refreshController.footerMode, isNull);
      expect(refreshController.headerStatus, isNull);
      expect(refreshController.footerStatus, isNull);
    });
  });

  testWidgets(
      'resetNoMoreData only can reset when footer mode is Nomore,if state is loading,may disable change state',
      (tester) async {
    final RefreshController refreshController = RefreshController(
        initialLoadStatus: LoadStatus.loading,
        initialRefreshStatus: RefreshStatus.refreshing);
    refreshController.refreshCompleted(resetFooterState: true);
    expect(refreshController.footerMode!.value, LoadStatus.loading);

    refreshController.headerMode!.value = RefreshStatus.refreshing;
    refreshController.footerMode!.value = LoadStatus.noMore;
    refreshController.refreshCompleted(resetFooterState: true);
    expect(refreshController.footerMode!.value, LoadStatus.idle);

    refreshController.headerMode!.value = RefreshStatus.refreshing;
    refreshController.footerMode!.value = LoadStatus.noMore;
    refreshController.resetNoData();
    expect(refreshController.footerMode!.value, LoadStatus.idle);
  });

  test('RefreshController ValueListenable and Stream tests', () async {
    final controller = RefreshController();
    final List<RefreshStatus> headerStates = [];
    final List<LoadStatus> footerStates = [];

    controller.headerStream.listen((s) => headerStates.add(s));
    controller.footerStream.listen((s) => footerStates.add(s));

    int headerNotifierCount = 0;
    controller.headerMode!.addListener(() {
      headerNotifierCount++;
    });

    controller.headerMode!.value = RefreshStatus.refreshing;
    expect(controller.headerStatus, RefreshStatus.refreshing);
    expect(headerNotifierCount, 1);

    controller.footerMode!.value = LoadStatus.loading;
    expect(controller.footerStatus, LoadStatus.loading);

    // Give streams a microtask to fire
    await Future.delayed(Duration.zero);
    expect(headerStates, [RefreshStatus.refreshing]);
    expect(footerStates, [LoadStatus.loading]);

    controller.refreshFailed(error: 'Test Error');
    expect(controller.headerStatus, RefreshStatus.failed);
    expect(controller.headerMode!.error, 'Test Error');

    controller.dispose();
  });

  testRequestFun(true);

  testRequestFun(false);
}
