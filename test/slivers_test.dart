/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime: 2019-07-21 16:59
 */

import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_refresher/smart_refresher.dart';
import 'package:flutter/material.dart';
import 'package:smart_refresher/src/internals/slivers.dart';
import 'data_source.dart';
import 'test_indicator.dart';

Future<void>? buildNotFullList(tester, bool reverse, Axis direction,
    {dynamic footer = const TestFooter(),
    dynamic header = const TestHeader(),
    bool initload = false}) {
  final RefreshController refreshController = RefreshController(
      initialLoadStatus: initload ? LoadStatus.loading : LoadStatus.idle);
  return tester.pumpWidget(MaterialApp(
    home: SizedBox(
      height: 600,
      width: 800,
      child: SmartRefresher(
        header: header,
        footer: footer,
        enablePullUp: true,
        controller: refreshController,
        child: ListView.builder(
          reverse: reverse,
          scrollDirection: direction,
          itemBuilder: (c, i) => Center(
            child: Text(data[i]),
          ),
          itemCount: 1,
          itemExtent: 100,
        ),
      ),
    ),
  ));
}

void main() {
  /// this need to be fixed later
  // #126 may still exist render error with footer not full
  testWidgets(
      'footer rendering in four direction with different styles(unfollow content)',
      (tester) async {
    final List<CustomFooter> footerData = [
      CustomFooter(
        builder: (_, c) => const SizedBox(
          height: 60.0,
          width: 60.0,
        ),
      ),
      CustomFooter(
        builder: (_, c) => const SizedBox(
          height: 60.0,
          width: 60.0,
        ),
        loadStyle: LoadStyle.ShowWhenLoading,
      ),
      CustomFooter(
        builder: (_, c) => const SizedBox(
          height: 60.0,
          width: 60.0,
        ),
        loadStyle: LoadStyle.HideAlways,
      ),
    ];
    for (final CustomFooter footer in footerData) {
      // down
      await buildNotFullList(tester, false, Axis.vertical, footer: footer);

      RenderSliverSingleBoxAdapter sliver =
          tester.renderObject(find.byType(SliverLoading));
      // behind the bottom ,if else ,it is render error
      expect(sliver.child!.localToGlobal(const Offset(0.0, 0.0)),
          const Offset(0, 600));

      // up
      await buildNotFullList(tester, true, Axis.vertical, footer: footer);

      sliver = tester.renderObject(find.byType(SliverLoading));
      expect(sliver.child!.localToGlobal(const Offset(0.0, 0.0)),
          const Offset(0, -60.0));

      // left
      await buildNotFullList(tester, true, Axis.horizontal, footer: footer);

      sliver = tester.renderObject(find.byType(SliverLoading));
      // behind the bottom ,if else ,it is render error
      expect(sliver.child!.localToGlobal(const Offset(0.0, 0.0)),
          const Offset(-60.0, 0));

      // right
      await buildNotFullList(tester, false, Axis.horizontal, footer: footer);

      sliver = tester.renderObject(find.byType(SliverLoading));
      // behind the bottom ,if else ,it is render error
      expect(sliver.child!.localToGlobal(const Offset(0.0, 0.0)),
          const Offset(800.0, 0));
    }
  });

  testWidgets(
      'footer rendering in four direction with different styles(unfollow content),loadingstate',
      (tester) async {
    final List<CustomFooter> footerData = [
      CustomFooter(
        builder: (_, c) => const SizedBox(
          height: 60.0,
          width: 60.0,
        ),
      ),
      CustomFooter(
        builder: (_, c) => const SizedBox(
          height: 60.0,
          width: 60.0,
        ),
        loadStyle: LoadStyle.ShowWhenLoading,
      ),
      CustomFooter(
        builder: (_, c) => const SizedBox(
          height: 60.0,
          width: 60.0,
        ),
        loadStyle: LoadStyle.HideAlways,
      ),
    ];
    for (final CustomFooter footer in footerData) {
      // down
      await buildNotFullList(tester, false, Axis.vertical,
          footer: footer, initload: true);

      RenderSliverSingleBoxAdapter sliver =
          tester.renderObject(find.byType(SliverLoading));
      // behind the bottom ,if else ,it is render error
      expect(sliver.child!.localToGlobal(const Offset(0.0, 0.0)),
          const Offset(0, 600));

//      // up
//      await buildNotFullList(tester, true, Axis.vertical,
//          footer: footer, initload: true);
//
//      sliver = tester.renderObject(find.byType(SliverLoading));
//
//      /// build failed in this ,may be I do some errors in this direction ,why -48.0?
//      expect(
//          sliver.child.localToGlobal(Offset(0.0, 0.0)), const Offset(0, -60.0));

      // left
//      await buildNotFullList(tester, true, Axis.horizontal,
//          footer: footer, initload: true);
//
//      sliver = tester.renderObject(find.byType(SliverLoading));
//      // behind the bottom ,if else ,it is render error
//      expect(
//          sliver.child.localToGlobal(Offset(0.0, 0.0)), const Offset(-60.0, 0));

      // right
      await buildNotFullList(tester, false, Axis.horizontal,
          footer: footer, initload: true);

      sliver = tester.renderObject(find.byType(SliverLoading));
      // behind the bottom ,if else ,it is render error

      expect(sliver.child!.localToGlobal(const Offset(0.0, 0.0)),
          const Offset(800.0, 0));
    }
  });

  testWidgets('header or footer hittest test,make sure onClick can callback',
      (tester) async {
    int time = 0;
    RefreshController refreshController = RefreshController();
    await tester.pumpWidget(RefreshConfiguration(
      child: MaterialApp(
        home: SizedBox(
          height: 600,
          width: 800,
          child: SmartRefresher(
            header: const ClassicHeader(),
            footer: ClassicFooter(
              onClick: () {
                time++;
              },
            ),
            enablePullUp: true,
            controller: refreshController,
            child: ListView.builder(
              itemBuilder: (c, i) => Center(
                child: Text(data[i]),
              ),
              itemCount: 1,
              itemExtent: 100,
            ),
          ),
        ),
      ),
      shouldFooterFollowWhenNotFull: (a) {
        return true;
      },
    ));

    await tester.tapAt(const Offset(0.0, 100.0));
    expect(time, 1);
    await tester.tapAt(const Offset(0.0, 150.0));
    expect(time, 2);
    await tester.tapAt(const Offset(799.0, 150.0));
    expect(time, 3);
    await tester.tapAt(const Offset(799.0, 100.0));
    expect(time, 4);
    await tester.tapAt(const Offset(400.0, 100.0));
    expect(time, 5);
    await tester.tapAt(const Offset(400.0, 150.0));
    expect(time, 6);
    await tester.tapAt(const Offset(0.0, -99.0));
    expect(time, 6);
    await tester.tapAt(const Offset(0.0, 160.0));
    expect(time, 6);

    time = 0;
    refreshController = RefreshController();
    await tester.pumpWidget(RefreshConfiguration(
      child: MaterialApp(
        home: SizedBox(
          height: 600,
          width: 800,
          child: SmartRefresher(
            header: const ClassicHeader(),
            footer: CustomFooter(
              builder: (c, m) {
                return Container(
                  // If color not setting, onClick cannot work ,this question only can ask flutter why
                  height: 60.0,
                );
              },
              onClick: () {
                time++;
              },
            ),
            enablePullUp: true,
            controller: refreshController,
            child: ListView.builder(
              itemBuilder: (c, i) => Center(
                child: Text(data[i]),
              ),
              itemCount: 1,
              itemExtent: 100,
            ),
          ),
        ),
      ),
      shouldFooterFollowWhenNotFull: (a) {
        return true;
      },
    ));

    await tester.tapAt(const Offset(0.0, 100.0));
    expect(time, 1);
    await tester.tapAt(const Offset(0.0, 150.0));
    expect(time, 2);
    await tester.tapAt(const Offset(799.0, 150.0));
    expect(time, 3);
    await tester.tapAt(const Offset(799.0, 100.0));
    expect(time, 4);
    await tester.tapAt(const Offset(400.0, 100.0));
    expect(time, 5);
    await tester.tapAt(const Offset(400.0, 150.0));
    expect(time, 6);
    await tester.tapAt(const Offset(0.0, -99.0));
    expect(time, 6);
    await tester.tapAt(const Offset(0.0, 160.0));
    expect(time, 6);
  });
}
