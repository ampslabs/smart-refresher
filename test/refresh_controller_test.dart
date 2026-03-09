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

  testRequestFun(true);

  testRequestFun(false);
}
