/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-20 22:15
 */

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';
import 'package:flutter/material.dart';
import 'data_source.dart';
import 'test_indicator.dart';

void main() {
  testWidgets('test child attribute ', (tester) async {
    final RefreshController refreshController = RefreshController();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SmartRefresher(
        header: const TestHeader(),
        footer: const TestFooter(),
        enablePullUp: true,
        controller: refreshController,
      ),
    ));
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SmartRefresher(
        header: const TestHeader(),
        footer: const TestFooter(),
        enablePullUp: true,
        controller: refreshController,
        child: ListView.builder(
          itemBuilder: (c, i) => const Card(),
          itemExtent: 100.0,
          itemCount: 20,
        ),
      ),
    ));
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SmartRefresher(
        header: const TestHeader(),
        footer: const TestFooter(),
        enablePullUp: true,
        controller: refreshController,
        child: const CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Text('asd'),
            ),
            SliverToBoxAdapter(
              child: Text('asd'),
            ),
            SliverToBoxAdapter(
              child: Text('asd'),
            ),
            SliverToBoxAdapter(
              child: Text('asd'),
            )
          ],
        ),
      ),
    ));

    //test scrollController
    final List<String> log = [];
    final ScrollController scrollController = ScrollController()
      ..addListener(() {
        log.add('');
      });
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SmartRefresher(
        header: const TestHeader(),
        footer: const TestFooter(),
        enablePullUp: true,
        controller: refreshController,
        child: ListView.builder(
          itemBuilder: (c, i) => const Card(),
          itemExtent: 100.0,
          itemCount: 20,
          controller: scrollController,
        ),
      ),
    ));
    await tester.drag(find.byType(Scrollable), const Offset(0.0, -100.0));
    await tester.pumpAndSettle();
    expect(log.length, greaterThanOrEqualTo(1));
  });

  testWidgets('test smartRefresher builder constructor ', (tester) async {
    final RefreshController refreshController = RefreshController();
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SmartRefresher.builder(
        enablePullUp: true,
        builder: (BuildContext context, RefreshPhysics physics) {
          return CustomScrollView(
            slivers: <Widget>[
              const TestHeader(),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                    (c, i) => const SizedBox(
                          height: 100.0,
                          child: Card(),
                        ),
                    childCount: 20),
              ),
              const TestFooter(),
            ],
          );
        },
        controller: refreshController,
      ),
    ));
  });

  testWidgets('param check ', (tester) async {
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
    RenderViewport viewport = tester.renderObject(find.byType(Viewport));
    expect(viewport.childCount, 3);

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SmartRefresher(
        header: const TestHeader(),
        footer: const TestFooter(),
        enablePullUp: true,
        enablePullDown: false,
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
    viewport = tester.renderObject(find.byType(Viewport));
    expect(viewport.childCount, 2);
    expect(viewport.firstChild.runtimeType, RenderSliverFixedExtentList);
    final List<dynamic> logs = [];
    // check enablePullDown,enablePullUp
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SmartRefresher(
        header: const TestHeader(),
        footer: const TestFooter(),
        enablePullUp: true,
        onRefresh: () {
          logs.add('refresh');
        },
        onLoading: () {
          logs.add('loading');
        },
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

    // check onRefresh,onLoading
    await tester.drag(find.byType(Scrollable), const Offset(0, 100.0),
        touchSlopY: 0.0);
    await tester.pump(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 20));
    expect(logs.length, 1);
    expect(logs[0], 'refresh');
    logs.clear();
    refreshController.refreshCompleted();
    await tester.pumpAndSettle(const Duration(milliseconds: 600));

    await tester.drag(find.byType(Scrollable), const Offset(0, -4000.0),
        touchSlopY: 0.0);
    await tester.pump(const Duration(milliseconds: 20)); //canRefresh
    await tester.pump(const Duration(milliseconds: 20)); //refreshing
    expect(logs.length, 1);
    expect(logs[0], 'loading');
    logs.clear();
    refreshController.loadComplete();

    double count = 1;
    while (count < 11) {
      await tester.drag(find.byType(Scrollable), const Offset(0, 20),
          touchSlopY: 0.0);
      count++;
      await tester.pump(const Duration(milliseconds: 20));
    }
  });

  testWidgets(' verity smartRefresher and NestedScrollView', (tester) async {
    final RefreshController refreshController = RefreshController();
    int time = 0;
    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: const TestHeader(),
        footer: const TestFooter(),
        enablePullUp: true,
        onRefresh: () async {
          time++;
        },
        onLoading: () async {
          time++;
        },
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

    // test pull down
    await tester.drag(find.byType(Scrollable), const Offset(0, 120));
    await tester.pump();
    expect(refreshController.headerStatus, RefreshStatus.canRefresh);
    await tester.pumpAndSettle();
    expect(refreshController.headerStatus, RefreshStatus.refreshing);
    refreshController.refreshCompleted();
    await tester.pumpAndSettle(const Duration(milliseconds: 800));

    // test flip up
    await tester.fling(find.byType(Scrollable), const Offset(0, -1000), 3000);
    await tester.pumpAndSettle();
    expect(refreshController.footerStatus, LoadStatus.loading);
    refreshController.footerMode!.value = LoadStatus.idle;
    await tester.pumpAndSettle();
    // test drag up
    refreshController.position!
        .jumpTo(refreshController.position!.maxScrollExtent);
    await tester.drag(find.byType(Scrollable), const Offset(0, -100));
    await tester.pumpAndSettle();
    expect(refreshController.position!.extentAfter, 0.0);
    refreshController.loadComplete();
    expect(time, 3);
  });

  testWidgets('fronStyle can hittest content when springback', (tester) async {
    final RefreshController refreshController = RefreshController();
    int time = 0;
    await tester.pumpWidget(MaterialApp(
      home: SmartRefresher(
        header: CustomHeader(
          builder: (c, m) => Container(),
        ),
        footer: const TestFooter(),
        enablePullUp: true,
        onRefresh: () async {
          time++;
        },
        onLoading: () async {
          time++;
        },
        controller: refreshController,
        child: GestureDetector(
          child: Container(
            height: 60.0,
            width: 60.0,
            color: Colors.transparent,
          ),
          onTap: () {
            time++;
          },
        ),
      ),
    ));

    // test pull down
    await tester.drag(find.byType(Scrollable), const Offset(0, 120));
    await tester.pump();
    expect(refreshController.headerStatus, RefreshStatus.canRefresh);
    await tester.pump(const Duration(milliseconds: 2));
    expect(refreshController.headerStatus, RefreshStatus.refreshing);
    expect(refreshController.position!.pixels, lessThan(0.0));
    await tester.tapAt(const Offset(30, 30));
    expect(time, 1);
  });

  testWidgets('test RefreshConfiguration new Constructor valid',
      (tester) async {
    final RefreshController refreshController = RefreshController();

    late BuildContext context2;
    await tester.pumpWidget(RefreshConfiguration(
      hideFooterWhenNotFull: true,
      dragSpeedRatio: 0.8,
      closeTwoLevelDistance: 100,
      footerTriggerDistance: 150,
      enableScrollWhenRefreshCompleted: true,
      child: Builder(
        builder: (c1) {
          return MaterialApp(
            home: RefreshConfiguration.copyAncestor(
              context: c1,
              enableScrollWhenRefreshCompleted: false,
              hideFooterWhenNotFull: true,
              maxUnderScrollExtent: 100,
              dragSpeedRatio: 0.7,
              child: Builder(
                builder: (c2) {
                  context2 = c2;
                  return SmartRefresher(
                    header: CustomHeader(
                      builder: (c, m) => Container(),
                    ),
                    footer: const TestFooter(),
                    enablePullUp: true,
                    onRefresh: () async {},
                    onLoading: () async {},
                    controller: refreshController,
                    child: GestureDetector(
                      child: Container(
                        height: 60.0,
                        width: 60.0,
                        color: Colors.transparent,
                      ),
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    ));
    expect(RefreshConfiguration.of(context2)!.maxUnderScrollExtent, 100);
    expect(RefreshConfiguration.of(context2)!.dragSpeedRatio, 0.7);
    expect(RefreshConfiguration.of(context2)!.hideFooterWhenNotFull, true);
    expect(RefreshConfiguration.of(context2)!.closeTwoLevelDistance, 100);
    expect(RefreshConfiguration.of(context2)!.footerTriggerDistance, 150);
    expect(RefreshConfiguration.of(context2)!.enableScrollWhenTwoLevel, true);
    expect(RefreshConfiguration.of(context2)!.enableBallisticRefresh, false);
  });
}
