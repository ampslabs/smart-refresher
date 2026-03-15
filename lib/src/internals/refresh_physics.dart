/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-02 2:39 PM
 */
// ignore_for_file: INVALID_USE_OF_PROTECTED_MEMBER
// ignore_for_file: INVALID_USE_OF_VISIBLE_FOR_TESTING_MEMBER
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;

import 'package:smart_refresher/smart_refresher.dart';
import 'package:smart_refresher/src/internals/slivers.dart';

/// A [ScrollPhysics] that enables refresh effects by allowing the viewport to overscroll.
///
/// Unlike [ClampingScrollPhysics], [RefreshPhysics] permits overscrolling even when it's not the default behavior.
/// It also manages scrolling behavior during refresh states and two-level mode transitions.
/// Custom spring animations can be configured using [SpringDescription].
///
/// See also:
///
/// * [RefreshConfiguration], which provides settings for [RefreshPhysics].
// ignore: MUST_BE_IMMUTABLE
class RefreshPhysics extends ScrollPhysics {
  /// The maximum extent to which the viewport can be overscrolled at the top.
  final double? maxOverScrollExtent;

  /// The maximum extent to which the viewport can be overscrolled at the bottom.
  final double? maxUnderScrollExtent;

  /// The boundary at the top where the scroll will hit and stop.
  final double? topHitBoundary;

  /// The boundary at the bottom where the scroll will hit and stop.
  final double? bottomHitBoundary;

  /// The description of the spring animation used for snapping back.
  final SpringDescription? springDescription;

  /// The ratio applied to the drag speed.
  final double? dragSpeedRatio;

  /// Whether scrolling is enabled during two-level mode.
  final bool? enableScrollWhenTwoLevel;

  /// Whether scrolling is enabled once the refresh is completed.
  final bool? enableScrollWhenRefreshCompleted;

  /// The controller used to manage refresh state.
  final RefreshController? controller;

  /// A flag used to force a physics update.
  final int? updateFlag;

  /// Whether pull-down refresh is enabled (authoritative from widget).
  final bool enablePullDown;

  /// Whether pull-up loading is enabled (authoritative from widget).
  final bool enablePullUp;

  /// The cached [RenderViewport] used for computing layout extents.
  RenderViewport? viewportRender;

  /// Creates a [RefreshPhysics].
  RefreshPhysics(
      {super.parent,
      this.updateFlag,
      this.maxUnderScrollExtent,
      this.springDescription,
      this.controller,
      this.dragSpeedRatio,
      this.topHitBoundary,
      this.bottomHitBoundary,
      this.enableScrollWhenRefreshCompleted,
      this.enableScrollWhenTwoLevel,
      this.enablePullDown = true,
      this.enablePullUp = false,
      this.maxOverScrollExtent});

  @override
  RefreshPhysics applyTo(ScrollPhysics? ancestor) {
    return RefreshPhysics(
        parent: buildParent(ancestor),
        updateFlag: updateFlag,
        springDescription: springDescription,
        dragSpeedRatio: dragSpeedRatio,
        enableScrollWhenTwoLevel: enableScrollWhenTwoLevel,
        topHitBoundary: topHitBoundary,
        bottomHitBoundary: bottomHitBoundary,
        controller: controller,
        enableScrollWhenRefreshCompleted: enableScrollWhenRefreshCompleted,
        enablePullDown: enablePullDown,
        enablePullUp: enablePullUp,
        maxUnderScrollExtent: maxUnderScrollExtent,
        maxOverScrollExtent: maxOverScrollExtent);
  }

  /// Finds the [RenderViewport] in the given [context].
  RenderViewport? findViewport(BuildContext? context) {
    if (context == null) {
      return null;
    }
    RenderViewport? result;
    context.visitChildElements((Element element) {
      final RenderObject? renderObject = element.findRenderObject();
      if (renderObject is RenderViewport) {
        assert(result == null);
        result = renderObject;
      } else {
        result = findViewport(element);
      }
    });
    return result;
  }

  @override
  bool shouldAcceptUserOffset(ScrollMetrics position) {
    if (parent is NeverScrollableScrollPhysics) {
      return false;
    }
    return true;
  }

  @override
  Type get runtimeType {
    if (updateFlag == 0) {
      return RefreshPhysics;
    } else {
      return BouncingScrollPhysics;
    }
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    final ScrollPosition scrollPosition = position as ScrollPosition;
    try {
      viewportRender ??= findViewport(scrollPosition.context.storageContext);
    } catch (_) {
      // context may be unmounted
    }
    final bool hasPullDown = viewportRender == null
        ? enablePullDown
        : viewportRender!.firstChild is RenderSliverRefresh;
    final bool hasPullUp = viewportRender == null
        ? enablePullUp
        : viewportRender!.lastChild is RenderSliverLoading;
    if (controller!.headerMode!.value == RefreshStatus.twoLeveling) {
      if (offset > 0.0) {
        return parent!.applyPhysicsToUserOffset(position, offset);
      }
    } else {
      if ((offset > 0.0 && !hasPullDown) || (offset < 0 && !hasPullUp)) {
        return parent!.applyPhysicsToUserOffset(position, offset);
      }
    }
    if (position.outOfRange ||
        controller!.headerMode!.value == RefreshStatus.twoLeveling) {
      final double overscrollPastStart =
          math.max(position.minScrollExtent - position.pixels, 0.0);
      final double overscrollPastEnd = math.max(
          position.pixels -
              (controller!.headerMode!.value == RefreshStatus.twoLeveling
                  ? position.minScrollExtent
                  : position.maxScrollExtent),
          0.0);
      final double overscrollPast =
          math.max(overscrollPastStart, overscrollPastEnd);
      final bool easing = (overscrollPastStart > 0.0 && offset < 0.0) ||
          (overscrollPastEnd > 0.0 && offset > 0.0);

      final double friction = easing
          // Apply less resistance when easing the overscroll vs tensioning.
          ? frictionFactor(
              (overscrollPast - offset.abs()) / position.viewportDimension)
          : frictionFactor(overscrollPast / position.viewportDimension);
      final double direction = offset.sign;
      return direction *
          _applyFriction(overscrollPast, offset.abs(), friction) *
          (dragSpeedRatio ?? 1.0);
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }

  static double _applyFriction(
      double extentOutside, double absDelta, double gamma) {
    assert(absDelta > 0);
    double total = 0.0;
    if (extentOutside > 0) {
      final double deltaToLimit = extentOutside / gamma;
      if (absDelta < deltaToLimit) return absDelta * gamma;
      total += extentOutside;
      absDelta -= deltaToLimit;
    }
    return total + absDelta;
  }

  /// Calculates the friction factor for overscrolling.
  double frictionFactor(double overscrollFraction) =>
      0.52 * math.pow(1 - overscrollFraction, 2);

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    final ScrollPosition scrollPosition = position as ScrollPosition;
    try {
      viewportRender ??= findViewport(scrollPosition.context.storageContext);
    } catch (_) {
      // context may be unmounted
    }
    final bool notFull = position.minScrollExtent == position.maxScrollExtent;
    final bool resolvedEnablePullDown = viewportRender == null
        ? enablePullDown
        : viewportRender!.firstChild is RenderSliverRefresh;
    final bool resolvedEnablePullUp = viewportRender == null
        ? enablePullUp
        : viewportRender!.lastChild is RenderSliverLoading;
    if (controller!.headerMode!.value == RefreshStatus.twoLeveling) {
      if (position.pixels - value > 0.0) {
        return parent!.applyBoundaryConditions(position, value);
      }
    } else {
      if ((position.pixels - value > 0.0 && !resolvedEnablePullDown) ||
          (position.pixels - value < 0 && !resolvedEnablePullUp)) {
        return parent!.applyBoundaryConditions(position, value);
      }
    }
    double topExtra = 0.0;
    double bottomExtra = 0.0;
    if (resolvedEnablePullDown) {
      final RenderSliverRefresh sliverHeader =
          viewportRender!.firstChild! as RenderSliverRefresh;
      topExtra = sliverHeader.hasLayoutExtent
          ? 0.0
          : sliverHeader.refreshIndicatorLayoutExtent;
    }
    if (resolvedEnablePullUp) {
      final RenderSliverLoading? sliverFooter =
          viewportRender!.lastChild as RenderSliverLoading?;
      bottomExtra = (!notFull && sliverFooter!.geometry!.scrollExtent != 0) ||
              (notFull &&
                  controller!.footerStatus == LoadStatus.noMore &&
                  !RefreshConfiguration.of(
                          controller!.position!.context.storageContext)!
                      .enableLoadingWhenNoData) ||
              (notFull &&
                  (RefreshConfiguration.of(
                              controller!.position!.context.storageContext)
                          ?.hideFooterWhenNotFull ??
                      false))
          ? 0.0
          : sliverFooter!.layoutExtent!;
    }
    final double topBoundary =
        position.minScrollExtent - maxOverScrollExtent! - topExtra;
    final double bottomBoundary =
        position.maxScrollExtent + maxUnderScrollExtent! + bottomExtra;

    if (scrollPosition.activity is BallisticScrollActivity) {
      if (topHitBoundary != double.infinity) {
        if (value < -topHitBoundary! && -topHitBoundary! <= position.pixels) {
          // hit top edge
          return value + topHitBoundary!;
        }
      }
      if (bottomHitBoundary != double.infinity) {
        if (position.pixels < bottomHitBoundary! + position.maxScrollExtent &&
            bottomHitBoundary! + position.maxScrollExtent < value) {
          // hit bottom edge
          return value - bottomHitBoundary! - position.maxScrollExtent;
        }
      }
    }
    if (maxOverScrollExtent != double.infinity &&
        value < topBoundary &&
        topBoundary < position.pixels) {
      // hit top edge
      return value - topBoundary;
    }
    if (maxUnderScrollExtent != double.infinity &&
        position.pixels < bottomBoundary &&
        bottomBoundary < value) {
      // hit bottom edge
      return value - bottomBoundary;
    }

    if (scrollPosition.activity is DragScrollActivity) {
      if (maxOverScrollExtent != double.infinity &&
          value < position.pixels &&
          position.pixels <= topBoundary) {
        // underscroll
        return value - position.pixels;
      }
      if (maxUnderScrollExtent != double.infinity &&
          bottomBoundary <= position.pixels &&
          position.pixels < value) {
        // overscroll
        return value - position.pixels;
      }
    }
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    /// any issue come with context, do nothing
    try {
      final ScrollPosition scrollPosition = position as ScrollPosition;
      viewportRender ??= findViewport(scrollPosition.context.storageContext);

      final bool resolvedEnablePullDown = viewportRender == null
          ? enablePullDown
          : viewportRender!.firstChild is RenderSliverRefresh;
      final bool resolvedEnablePullUp = viewportRender == null
          ? enablePullUp
          : viewportRender!.lastChild is RenderSliverLoading;
      if (controller!.headerMode!.value == RefreshStatus.twoLeveling) {
        if (velocity < 0.0) {
          return parent!.createBallisticSimulation(position, velocity);
        }
      } else if (!position.outOfRange) {
        if ((velocity < 0.0 && !resolvedEnablePullDown) ||
            (velocity > 0 && !resolvedEnablePullUp)) {
          return parent!.createBallisticSimulation(position, velocity);
        }
      }
      if ((position.pixels > position.minScrollExtent &&
              controller!.headerMode!.value == RefreshStatus.twoLeveling) ||
          position.outOfRange) {
        return BouncingScrollSimulation(
          spring: springDescription ?? spring,
          position: position.pixels,
          velocity: velocity,
          leadingExtent: position.minScrollExtent,
          trailingExtent:
              controller!.headerMode!.value == RefreshStatus.twoLeveling
                  ? position.minScrollExtent
                  : position.maxScrollExtent,
          tolerance: toleranceFor(position),
        );
      }
      return super.createBallisticSimulation(position, velocity);
    } catch (e) {
      return null;
    }
  }
}
