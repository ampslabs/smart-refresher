/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-10-17 20:30
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart' as prefix0;
import 'package:smart_refresher/smart_refresher.dart';

/// This example aim to fix the viewport not enough one page,there must be exist some problems that you don't hope that.
/// relevant issue:#183,#166*

// A Sliver for  Expanding empty space
class SliverFillEmptySpace extends SingleChildRenderObjectWidget {
  /// Creates a sliver that contains a single box widget.
  SliverFillEmptySpace({super.key}) : super(child: Container());

  @override
  RenderSliverFillEmptySpace createRenderObject(BuildContext context) =>
      RenderSliverFillEmptySpace();
}

class RenderSliverFillEmptySpace extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliver] that wraps a [RenderBox].
  RenderSliverFillEmptySpace({super.child});

  @override
  void performLayout() {
    double emptySpaceExtent =
        constraints.viewportMainAxisExtent - constraints.precedingScrollExtent;

    if (emptySpaceExtent > 0) {
      child!.layout(
          constraints.asBoxConstraints(maxExtent: emptySpaceExtent),
          parentUsesSize: true);
      double childExtent = emptySpaceExtent;
      final double paintedChildSize =
          calculatePaintOffset(constraints, from: 0.0, to: childExtent);
      final double cacheExtent =
          calculateCacheOffset(constraints, from: 0.0, to: childExtent);
      geometry = SliverGeometry(
        scrollExtent: childExtent,
        paintExtent: paintedChildSize,
        cacheExtent: cacheExtent,
        maxPaintExtent: childExtent,
      );
      setChildParentData(child!, constraints, geometry!);
    } else {
      geometry = SliverGeometry.zero;
    }
  }
}

class FillEmptyCustomScrollView extends prefix0.CustomScrollView {
  final bool enableFillEmpty;
  const FillEmptyCustomScrollView({
    super.key,
    required this.enableFillEmpty,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.shrinkWrap,
    super.center,
    super.anchor,
    super.cacheExtent,
    this.slivers = const <Widget>[],
    super.semanticChildCount,
    super.dragStartBehavior,
  });

  /// The slivers to place inside the viewport.
  @override
  final List<Widget> slivers;

  @override
  List<Widget> buildSlivers(BuildContext context) {
    if (enableFillEmpty) slivers.add(SliverFillEmptySpace());
    return slivers;
  }
}

class ForceFullExample extends StatelessWidget {
  final RefreshController _refreshController = RefreshController();

  ForceFullExample({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SmartRefresher(
      controller: _refreshController,
      enablePullUp: true,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        _refreshController.refreshCompleted();
      },
      onLoading: () async {
        await Future.delayed(const Duration(milliseconds: 500));
        _refreshController.loadComplete();
      },
      footer: ClassicFooter(
        loadStyle: LoadStyle.ShowWhenLoading,
      ),
      child: FillEmptyCustomScrollView(
        enableFillEmpty:
            _refreshController.footerMode?.value != LoadStatus.noMore,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Text(
                "有很多时候,不满一屏时,会出现很多问题,比如底部指示器加载触发只能隐藏回去,而不能在底部卡着显示,等加载完毕再隐藏回去,解决这个问题,我们可以通过把Viewport剩余空间给填充满,来达到底部能看到的效果。"),
          )
        ],
      ),
    );
  }
}
