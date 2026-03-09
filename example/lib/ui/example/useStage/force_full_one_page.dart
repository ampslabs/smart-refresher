/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-10-17 8:30 PM
 */

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:smart_refresher/smart_refresher.dart';

/// This example aims to fix issues when the viewport content is less than one page.
/// Relevant issues: #183, #166.

/// A Sliver for expanding empty space.
class SliverFillEmptySpace extends SingleChildRenderObjectWidget {
  /// Creates a sliver that contains a single box widget.
  SliverFillEmptySpace({super.key}) : super(child: Container());

  @override
  RenderSliverFillEmptySpace createRenderObject(BuildContext context) =>
      RenderSliverFillEmptySpace();
}

/// Render object for [SliverFillEmptySpace].
class RenderSliverFillEmptySpace extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliverFillEmptySpace].
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

/// A CustomScrollView that can fill empty space.
class FillEmptyCustomScrollView extends CustomScrollView {
  /// Whether to enable filling empty space.
  final bool enableFillEmpty;

  /// Creates a [FillEmptyCustomScrollView].
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

  @override
  final List<Widget> slivers;

  @override
  List<Widget> buildSlivers(BuildContext context) {
    if (enableFillEmpty) {
      final List<Widget> newSlivers = List.from(slivers);
      newSlivers.add(SliverFillEmptySpace());
      return newSlivers;
    }
    return slivers;
  }
}

/// Example of forcing a full page content.
class ForceFullExample extends StatelessWidget {
  final RefreshController _refreshController = RefreshController();

  /// Creates a [ForceFullExample].
  ForceFullExample({super.key});

  @override
  Widget build(BuildContext context) {
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
      footer: const ClassicFooter(
        loadStyle: LoadStyle.ShowWhenLoading,
      ),
      child: FillEmptyCustomScrollView(
        enableFillEmpty:
            _refreshController.footerMode?.value != LoadStatus.noMore,
        slivers: const <Widget>[
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                  "Often, when content doesn't fill the screen, various issues arise. For example, the bottom indicator might only hide back after being triggered instead of staying visible until loading finishes. We can solve this by filling the remaining Viewport space so the bottom indicator remains visible."),
            ),
          )
        ],
      ),
    );
  }
}
