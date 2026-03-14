/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/2 5:09 PM
 */

import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import '../smart_refresher.dart';

/// A sliver widget that renders the refresh header.
class SliverRefresh extends SingleChildRenderObjectWidget {
  /// Creates a [SliverRefresh] widget.
  const SliverRefresh({
    super.key,
    this.paintOffsetY,
    this.refreshIndicatorLayoutExtent = 0.0,
    this.floating = false,
    super.child,
    this.refreshStyle,
  }) : assert(refreshIndicatorLayoutExtent >= 0.0);

  /// The amount of space the indicator occupies in the sliver while refreshing.
  final double refreshIndicatorLayoutExtent;

  /// Whether the indicator should occupy any layout extent space.
  final bool floating;

  /// The display style of the refresh indicator.
  final RefreshStyle? refreshStyle;

  /// The vertical layout deviation for the head indicator, primarily for [RefreshStyle.front].
  final double? paintOffsetY;

  @override
  RenderSliverRefresh createRenderObject(BuildContext context) {
    return RenderSliverRefresh(
      refreshIndicatorExtent: refreshIndicatorLayoutExtent,
      hasLayoutExtent: floating,
      paintOffsetY: paintOffsetY,
      refreshStyle: refreshStyle,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSliverRefresh renderObject) {
    final RefreshStatus mode =
        SmartRefresher.of(context)!.controller.headerMode!.value;
    renderObject
      ..refreshIndicatorLayoutExtent = refreshIndicatorLayoutExtent
      ..hasLayoutExtent = floating
      ..context = context
      ..refreshStyle = refreshStyle
      ..updateFlag = mode == RefreshStatus.twoLevelOpening ||
          mode == RefreshStatus.twoLeveling ||
          mode == RefreshStatus.idle
      ..paintOffsetY = paintOffsetY;
  }
}

/// The render object for [SliverRefresh].
class RenderSliverRefresh extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliverRefresh] object.
  RenderSliverRefresh(
      {required double refreshIndicatorExtent,
      required bool hasLayoutExtent,
      RenderBox? child,
      this.paintOffsetY,
      this.refreshStyle})
      : assert(refreshIndicatorExtent >= 0.0),
        _refreshIndicatorExtent = refreshIndicatorExtent,
        _hasLayoutExtent = hasLayoutExtent {
    this.child = child;
  }

  /// The display style of the refresh indicator.
  RefreshStyle? refreshStyle;

  /// The build context for this render object.
  late BuildContext context;

  /// The layout space the indicator occupies while refreshing.
  double get refreshIndicatorLayoutExtent => _refreshIndicatorExtent;
  double _refreshIndicatorExtent;

  /// The vertical offset for painting the indicator.
  double? paintOffsetY;

  bool _updateFlag = false;

  set refreshIndicatorLayoutExtent(double value) {
    assert(value >= 0.0);
    if (value == _refreshIndicatorExtent) return;
    _refreshIndicatorExtent = value;
    markNeedsLayout();
  }

  /// Whether the sliver currently has layout extent.
  bool get hasLayoutExtent => _hasLayoutExtent;
  bool _hasLayoutExtent;

  set hasLayoutExtent(bool value) {
    if (value == _hasLayoutExtent) return;
    if (!value) {
      _updateFlag = true;
    }
    _hasLayoutExtent = value;
    markNeedsLayout();
  }

  /// Compensation for layout extent changes to prevent visual jumping.
  double layoutExtentOffsetCompensation = 0.0;

  @override
  double get centerOffsetAdjustment {
    if (refreshStyle == RefreshStyle.front) {
      final RenderViewportBase renderViewport =
          parent! as RenderViewportBase<ContainerParentDataMixin<RenderSliver>>;
      return math.max(0.0, -renderViewport.offset.pixels);
    }
    return 0.0;
  }

  @override
  void layout(Constraints constraints, {bool parentUsesSize = false}) {
    if (refreshStyle == RefreshStyle.front) {
      final RenderViewportBase renderViewport =
          parent! as RenderViewportBase<ContainerParentDataMixin<RenderSliver>>;
      super.layout(
          (constraints as SliverConstraints)
              .copyWith(overlap: math.min(0.0, renderViewport.offset.pixels)),
          parentUsesSize: true);
    } else {
      super.layout(constraints, parentUsesSize: parentUsesSize);
    }
  }

  /// Sets the flag to trigger a dimension update.
  set updateFlag(bool u) {
    _updateFlag = u;
    markNeedsLayout();
  }

  @override
  void debugAssertDoesMeetConstraints() {
    assert(geometry!.debugAssertIsValid(informationCollector: () sync* {
      yield describeForError(
          'The RenderSliver that returned the offending geometry was');
    }));
    assert(() {
      if (geometry!.paintExtent > constraints.remainingPaintExtent) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'SliverGeometry has a paintOffset that exceeds the remainingPaintExtent from the constraints.'),
          describeForError(
              'The render object whose geometry violates the constraints is the following'),
          ErrorDescription(
            'The paintExtent must cause the child sliver to paint within the viewport, and so '
            'cannot exceed the remainingPaintExtent.',
          ),
        ]);
      }
      return true;
    }());
  }

  @override
  void performLayout() {
    if (_updateFlag) {
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      Scrollable.of(context).position.activity!.applyNewDimensions();
      _updateFlag = false;
    }
    final double layoutExtent =
        (_hasLayoutExtent ? 1.0 : 0.0) * _refreshIndicatorExtent;
    if (refreshStyle != RefreshStyle.front) {
      if (layoutExtent != layoutExtentOffsetCompensation) {
        geometry = SliverGeometry(
          scrollOffsetCorrection: layoutExtent - layoutExtentOffsetCompensation,
        );

        layoutExtentOffsetCompensation = layoutExtent;
        return;
      }
    }
    final bool active = (constraints.overlap < 0.0) || layoutExtent > 0.0;
    final double overscrolledExtent =
        -(parent! as RenderViewportBase).offset.pixels;
    if (refreshStyle == RefreshStyle.behind) {
      child!.layout(
        constraints.asBoxConstraints(
            maxExtent: math.max(0, overscrolledExtent + layoutExtent)),
        parentUsesSize: true,
      );
    } else {
      child!.layout(
        constraints.asBoxConstraints(),
        parentUsesSize: true,
      );
    }
    final double boxExtent = (constraints.axisDirection == AxisDirection.up ||
            constraints.axisDirection == AxisDirection.down)
        ? child!.size.height
        : child!.size.width;

    if (active) {
      final double needPaintExtent = math.min(
          math.max(
            math.max(boxExtent, layoutExtent) - constraints.scrollOffset,
            0.0,
          ),
          constraints.remainingPaintExtent);
      final double overlap = constraints.overlap;
      switch (refreshStyle) {
        case RefreshStyle.follow:
          geometry = SliverGeometry(
            scrollExtent: layoutExtent,
            paintOrigin:
                -boxExtent - constraints.scrollOffset + layoutExtent - overlap,
            paintExtent: needPaintExtent,
            hitTestExtent: needPaintExtent,
            hasVisualOverflow: overscrolledExtent < boxExtent,
            maxPaintExtent: needPaintExtent,
            layoutExtent: math.min(needPaintExtent,
                math.max(layoutExtent - constraints.scrollOffset, 0.0)),
          );

          break;
        case RefreshStyle.behind:
          geometry = SliverGeometry(
            scrollExtent: layoutExtent,
            paintOrigin:
                -overscrolledExtent - constraints.scrollOffset - overlap,
            paintExtent: needPaintExtent,
            maxPaintExtent: needPaintExtent,
            layoutExtent:
                math.max(layoutExtent - constraints.scrollOffset, 0.0),
          );
          break;
        case RefreshStyle.unFollow:
          geometry = SliverGeometry(
            scrollExtent: layoutExtent,
            paintOrigin: math.min(
                    -overscrolledExtent - constraints.scrollOffset,
                    -boxExtent - constraints.scrollOffset + layoutExtent) -
                overlap,
            paintExtent: needPaintExtent,
            hasVisualOverflow: overscrolledExtent < boxExtent,
            maxPaintExtent: needPaintExtent,
            layoutExtent: math.min(needPaintExtent,
                math.max(layoutExtent - constraints.scrollOffset, 0.0)),
          );

          break;
        case RefreshStyle.front:
          geometry = SliverGeometry(
            paintOrigin: (constraints.axisDirection == AxisDirection.up ||
                        constraints.crossAxisDirection == AxisDirection.left
                    ? boxExtent
                    : 0.0) -
                overlap,
            visible: true,
            hasVisualOverflow: true,
          );
          break;
        case null:
          break;
      }
      setChildParentData(child!, constraints, geometry!);
    } else {
      geometry = SliverGeometry.zero;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    context.paintChild(child!, Offset(offset.dx, offset.dy + paintOffsetY!));
  }

  @override
  void applyPaintTransform(RenderObject child, Matrix4 transform) {}
}

/// A sliver widget that renders the loading footer.
class SliverLoading extends SingleChildRenderObjectWidget {
  /// Whether the footer should be hidden when the content doesn't fill the viewport.
  final bool? hideWhenNotFull;

  /// Whether the footer is currently in a floating state.
  final bool? floating;

  /// The current loading state.
  final LoadStatus? mode;

  /// The amount of space the footer occupies in the sliver.
  final double? layoutExtent;

  /// Whether the footer should follow the content when the viewport is not full.
  final bool? shouldFollowContent;

  /// Creates a [SliverLoading] widget.
  const SliverLoading({
    super.key,
    this.mode,
    this.floating,
    this.shouldFollowContent,
    this.layoutExtent,
    this.hideWhenNotFull,
    super.child,
  });

  @override
  RenderSliverLoading createRenderObject(BuildContext context) {
    return RenderSliverLoading(
        hideWhenNotFull: hideWhenNotFull,
        mode: mode,
        hasLayoutExtent: floating,
        shouldFollowContent: shouldFollowContent,
        layoutExtent: layoutExtent);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderSliverLoading renderObject) {
    renderObject
      ..mode = mode
      ..hasLayoutExtent = floating!
      ..layoutExtent = layoutExtent
      ..shouldFollowContent = shouldFollowContent
      ..hideWhenNotFull = hideWhenNotFull;
  }
}

/// The render object for [SliverLoading].
class RenderSliverLoading extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliverLoading] object.
  RenderSliverLoading({
    RenderBox? child,
    this.mode,
    double? layoutExtent,
    bool? hasLayoutExtent,
    this.shouldFollowContent,
    this.hideWhenNotFull,
  }) {
    _hasLayoutExtent = hasLayoutExtent;
    this.layoutExtent = layoutExtent;
    this.child = child;
  }

  /// Whether the footer should follow the content when the viewport is not full.
  bool? shouldFollowContent;

  /// Whether the footer should be hidden when the content doesn't fill the viewport.
  bool? hideWhenNotFull;

  /// The current loading state.
  LoadStatus? mode;

  double? _layoutExtent;

  /// The layout space the footer occupies.
  set layoutExtent(double? extent) {
    if (extent == _layoutExtent) return;
    _layoutExtent = extent;
    markNeedsLayout();
  }

  /// The layout space the footer occupies.
  double? get layoutExtent => _layoutExtent;

  /// Whether the sliver currently has layout extent.
  bool get hasLayoutExtent => _hasLayoutExtent!;
  bool? _hasLayoutExtent;

  set hasLayoutExtent(bool value) {
    if (value == _hasLayoutExtent) return;
    _hasLayoutExtent = value;
    markNeedsLayout();
  }

  bool _computeIfFull(SliverConstraints cons) {
    final RenderViewport viewport = parent! as RenderViewport;
    RenderSliver? sliverP = viewport.firstChild;
    double totalScrollExtent = cons.precedingScrollExtent;
    while (sliverP != this && sliverP != null) {
      if (sliverP is RenderSliverRefresh) {
        totalScrollExtent -= sliverP.geometry!.scrollExtent;
      }
      sliverP = viewport.childAfter(sliverP);
    }
    return totalScrollExtent > cons.viewportMainAxisExtent;
  }

  /// Calculates the paint origin for the footer.
  double? computePaintOrigin(double? layoutExtent, bool reverse, bool follow) {
    if (follow) {
      if (reverse) {
        return layoutExtent;
      }
      return 0.0;
    } else {
      if (reverse) {
        return math.max(
                constraints.viewportMainAxisExtent -
                    constraints.precedingScrollExtent,
                0.0) +
            layoutExtent!;
      } else {
        return math.max(
            constraints.viewportMainAxisExtent -
                constraints.precedingScrollExtent,
            0.0);
      }
    }
  }

  @override
  void debugAssertDoesMeetConstraints() {
    assert(geometry!.debugAssertIsValid(informationCollector: () sync* {
      yield describeForError(
          'The RenderSliver that returned the offending geometry was');
    }));
    assert(() {
      if (geometry!.paintExtent > constraints.remainingPaintExtent) {
        throw FlutterError.fromParts(<DiagnosticsNode>[
          ErrorSummary(
              'SliverGeometry has a paintOffset that exceeds the remainingPaintExtent from the constraints.'),
          describeForError(
              'The render object whose geometry violates the constraints is the following'),
          ErrorDescription(
            'The paintExtent must cause the child sliver to paint within the viewport, and so '
            'cannot exceed the remainingPaintExtent.',
          ),
        ]);
      }
      return true;
    }());
  }

  @override
  void performLayout() {
    assert(constraints.growthDirection == GrowthDirection.forward);
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    bool active;
    if (hideWhenNotFull! && mode != LoadStatus.noMore) {
      active = _computeIfFull(constraints);
    } else {
      active = true;
    }
    if (active) {
      child!.layout(constraints.asBoxConstraints(), parentUsesSize: true);
    } else {
      child!.layout(constraints.asBoxConstraints(maxExtent: 0.0),
          parentUsesSize: true);
    }
    final double childExtent = constraints.axis == Axis.vertical
        ? child!.size.height
        : child!.size.width;
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);
    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    if (active) {
      geometry = SliverGeometry(
        scrollExtent: !_hasLayoutExtent! || !_computeIfFull(constraints)
            ? 0.0
            : layoutExtent ?? 0.0,
        paintExtent: paintedChildSize,
        paintOrigin: computePaintOrigin(
            !_hasLayoutExtent! || !_computeIfFull(constraints)
                ? layoutExtent
                : 0.0,
            constraints.axisDirection == AxisDirection.up ||
                constraints.axisDirection == AxisDirection.left,
            _computeIfFull(constraints) || shouldFollowContent!)!,
        cacheExtent: cacheExtent,
        maxPaintExtent: childExtent,
        hitTestExtent: paintedChildSize,
        visible: true,
        hasVisualOverflow: true,
      );
      setChildParentData(child!, constraints, geometry!);
    } else {
      geometry = SliverGeometry.zero;
    }
  }
}

/// A sliver widget that wraps the body of the scroll view.
class SliverRefreshBody extends SingleChildRenderObjectWidget {
  /// Creates a [SliverRefreshBody] widget.
  const SliverRefreshBody({
    super.key,
    super.child,
  });

  @override
  RenderSliverRefreshBody createRenderObject(BuildContext context) =>
      RenderSliverRefreshBody();
}

/// The render object for [SliverRefreshBody].
class RenderSliverRefreshBody extends RenderSliverSingleBoxAdapter {
  /// Creates a [RenderSliverRefreshBody] object.
  RenderSliverRefreshBody({
    super.child,
  });

  @override
  void performLayout() {
    if (child == null) {
      geometry = SliverGeometry.zero;
      return;
    }
    child!.layout(constraints.asBoxConstraints(maxExtent: 1111111),
        parentUsesSize: true);
    double? childExtent;
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    if (childExtent == 1111111) {
      child!.layout(
          constraints.asBoxConstraints(
              maxExtent: constraints.viewportMainAxisExtent),
          parentUsesSize: true);
    }
    switch (constraints.axis) {
      case Axis.horizontal:
        childExtent = child!.size.width;
        break;
      case Axis.vertical:
        childExtent = child!.size.height;
        break;
    }
    final double paintedChildSize =
        calculatePaintOffset(constraints, from: 0.0, to: childExtent);
    final double cacheExtent =
        calculateCacheOffset(constraints, from: 0.0, to: childExtent);

    assert(paintedChildSize.isFinite);
    assert(paintedChildSize >= 0.0);
    geometry = SliverGeometry(
      scrollExtent: childExtent,
      paintExtent: paintedChildSize,
      cacheExtent: cacheExtent,
      maxPaintExtent: childExtent,
      hitTestExtent: paintedChildSize,
      hasVisualOverflow: childExtent > constraints.remainingPaintExtent ||
          constraints.scrollOffset > 0.0,
    );
    setChildParentData(child!, constraints, geometry!);
  }
}
