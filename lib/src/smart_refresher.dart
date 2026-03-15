/*
    Author: Jpeng
    Email: peng8350@gmail.com
    createTime:2018-05-01 11:39 AM
*/

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'internals/indicator_wrap.dart';
import 'internals/refresh_physics.dart';
import 'internals/mixins.dart';

// ignore_for_file: INVALID_USE_OF_PROTECTED_MEMBER
// ignore_for_file: INVALID_USE_OF_VISIBLE_FOR_TESTING_MEMBER
// ignore_for_file: DEPRECATED_MEMBER_USE

import 'internals/enums.dart';

export 'internals/enums.dart';

/// Callback triggered when the two-level mode is opened or closed.
typedef OnTwoLevel = void Function(bool isOpen);

/// Determines whether the footer should follow the content when the viewport is not full.
typedef ShouldFollowContent = bool Function(LoadStatus? status);

/// A builder for global default indicators.
typedef IndicatorBuilder = Widget Function();

/// A builder for attaching refresh functionality with custom physics.
typedef RefresherBuilder = Widget Function(
    BuildContext context, RefreshPhysics physics);

/// The primary widget providing pull-to-refresh and pull-up loading functionality.
///
/// Requires a [RefreshController] to manage the state of the indicators.
///
/// See also:
/// * [RefreshConfiguration], for global configuration.
/// * [RefreshController], for managing header and footer states.
class SmartRefresher extends StatefulWidget {
  /// The scrollable content to be refreshed.
  final Widget? child;

  /// The header indicator displayed at the top (or bottom, if reversed).
  final Widget? header;

  /// The footer indicator displayed at the bottom (or top, if reversed).
  final Widget? footer;

  /// Whether to enable pull-up loading.
  final bool enablePullUp;

  /// Whether to enable the two-level refresh feature.
  final bool enableTwoLevel;

  /// Whether to enable pull-down refresh.
  final bool enablePullDown;

  /// Callback triggered when a pull-down refresh is initiated.
  final VoidCallback? onRefresh;

  /// Callback triggered when a pull-up loading is initiated.
  final VoidCallback? onLoading;

  /// Callback triggered when a pull-down refresh fails.
  final void Function(Object error, StackTrace? stackTrace)? onRefreshFailed;

  /// Callback triggered when a pull-up loading fails.
  final void Function(Object error, StackTrace? stackTrace)? onLoadingFailed;

  /// Callback triggered when the two-level mode is ready.
  final OnTwoLevel? onTwoLevel;

  /// Manages the internal state of the indicators.
  final RefreshController controller;

  /// A custom builder for the refresher content.
  final RefresherBuilder? builder;

  /// The axis along which the scroll view scrolls.
  final Axis? scrollDirection;

  /// Whether the scroll view scrolls in the reading direction.
  final bool? reverse;

  /// An object that can be used to control the position to which this scroll view is scrolled.
  final ScrollController? scrollController;

  /// Whether this is the primary scroll view associated with the parent [PrimaryScrollController].
  final bool? primary;

  /// How the scroll view should respond to user input.
  final ScrollPhysics? physics;

  /// The extent of the area that is cached for visible items.
  final double? cacheExtent;

  /// The number of children that will provide semantic information.
  final int? semanticChildCount;

  /// Determines the way that drag start behavior is handled.
  final DragStartBehavior? dragStartBehavior;

  /// A list of slivers to use as the body.
  final List<Widget>? slivers;

  /// The first sliver in the "forward" direction.
  ///
  /// See [CustomScrollView.center].
  final Key? center;

  /// The widget to show when the content is empty.
  final Widget? empty;

  /// The widget to show when there is an error.
  final Widget? error;

  /// The widget to show while the initial content is loading.
  final Widget? loading;

  /// Creates a [SmartRefresher].
  const SmartRefresher(
      {super.key,
      required this.controller,
      this.child,
      this.header,
      this.footer,
      this.enablePullDown = true,
      this.enablePullUp = false,
      this.enableTwoLevel = false,
      this.onRefresh,
      this.onLoading,
      this.onRefreshFailed,
      this.onLoadingFailed,
      this.onTwoLevel,
      this.dragStartBehavior,
      this.primary,
      this.cacheExtent,
      this.semanticChildCount,
      this.reverse,
      this.physics,
      this.scrollDirection,
      this.scrollController,
      this.center,
      this.empty,
      this.error,
      this.loading})
      : builder = null,
        slivers = null;

  /// Creates a [SmartRefresher] using a custom builder.
  ///
  /// This constructor allows you to build the content based on the current
  /// [ContentStatus] (idle, loading, empty, error). You can provide specific
  /// widgets for the [loading], [empty], and [error] states.
  const SmartRefresher.builder({
    super.key,
    required this.controller,
    required this.builder,
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.enableTwoLevel = false,
    this.onRefresh,
    this.onLoading,
    this.onRefreshFailed,
    this.onLoadingFailed,
    this.onTwoLevel,
    this.empty,
    this.error,
    this.loading,
  })  : header = null,
        footer = null,
        child = null,
        scrollController = null,
        scrollDirection = null,
        physics = null,
        reverse = null,
        semanticChildCount = null,
        dragStartBehavior = null,
        cacheExtent = null,
        primary = null,
        slivers = null,
        center = null;

  /// Creates a [SmartRefresher] with a list of slivers.
  ///
  /// This constructor is useful when you want to use [SmartRefresher] with
  /// complex sliver-based layouts where you already have a list of slivers.
  const SmartRefresher.slivers({
    super.key,
    required this.controller,
    required this.slivers,
    this.header,
    this.footer,
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.enableTwoLevel = false,
    this.onRefresh,
    this.onLoading,
    this.onRefreshFailed,
    this.onLoadingFailed,
    this.onTwoLevel,
    this.dragStartBehavior,
    this.primary,
    this.cacheExtent,
    this.semanticChildCount,
    this.reverse,
    this.physics,
    this.scrollDirection,
    this.scrollController,
    this.center,
    this.empty,
    this.error,
    this.loading,
  })  : child = null,
        builder = null;

  /// Returns the [SmartRefresher] from the given [context].
  static SmartRefresher? of(BuildContext? context) {
    return context!.findAncestorWidgetOfExactType<SmartRefresher>();
  }

  /// Returns the [SmartRefresherState] from the given [context].
  static SmartRefresherState? ofState(BuildContext? context) {
    return context!.findAncestorStateOfType<SmartRefresherState>();
  }

  @override
  State<StatefulWidget> createState() {
    return SmartRefresherState();
  }
}

/// The state for a [SmartRefresher].
class SmartRefresherState extends State<SmartRefresher>
    with RefresherSliverComposer, RefresherPhysicsMixin, RefresherDragHandler {
  /// The current viewport extent.
  double viewportExtent = 0;

  @override
  void didUpdateWidget(SmartRefresher oldWidget) {
    if (widget.controller != oldWidget.controller) {
      widget.controller.headerMode!.value =
          oldWidget.controller.headerMode!.value;
      widget.controller.footerMode!.value =
          oldWidget.controller.footerMode!.value;
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (checkIfNeedUpdatePhysics(context)) {
      toggleUpdatePhysics();
    }
  }

  @override
  void initState() {
    if (widget.controller.initialRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.controller.requestRefresh();
      });
    }
    widget.controller._bindState(this);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller._detachPosition();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RefreshConfiguration? configuration =
        RefreshConfiguration.of(context);
    Widget? body;
    if (widget.builder != null) {
      body = ValueListenableBuilder<ContentStatus>(
        valueListenable: widget.controller.contentStatus,
        builder: (context, status, child) {
          if (status == ContentStatus.empty && widget.empty != null) {
            return widget.empty!;
          }
          if (status == ContentStatus.error && widget.error != null) {
            return widget.error!;
          }
          if (status == ContentStatus.loading && widget.loading != null) {
            return widget.loading!;
          }
          return widget.builder!(
              context,
              getRefresherPhysics(
                      configuration, const AlwaysScrollableScrollPhysics(), canDrag)
                  as RefreshPhysics);
        },
      );
    } else {
      final List<Widget>? slivers =
          buildSliversByChild(context, widget.child, configuration);
      body = buildBodyBySlivers(widget.child, slivers, configuration,
          (conf, physics) => getRefresherPhysics(conf, physics, canDrag));
    }
    if (configuration == null) {
      body = RefreshConfiguration(child: body!);
    }
    final Widget footerFollowBody = LayoutBuilder(
      builder: (c2, cons) {
        viewportExtent = cons.biggest.height;
        return body!;
      },
    );

    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.stylus,
          PointerDeviceKind.invertedStylus,
          PointerDeviceKind.unknown,
        },
      ),
      child: footerFollowBody,
    );
  }
}

/// Status of the content (used by SmartRefresher.builder slots).
enum ContentStatus {
  /// Content is in its normal state.
  idle,

  /// Content is empty.
  empty,

  /// An error occurred while loading content.
  error,

  /// Content is initially loading.
  loading
}

/// A controller that manages the state of the header and footer indicators.
class RefreshController {
  SmartRefresherState? _refresherState;

  /// Manages the header's refresh status.
  RefreshNotifier<RefreshStatus>? headerMode;

  /// Manages the footer's loading status.
  RefreshNotifier<LoadStatus>? footerMode;

  /// Manages the overall content state (empty, error, loading).
  late final ValueNotifier<ContentStatus> contentStatus;

  StreamController<RefreshStatus>? _headerStreamController;
  StreamController<LoadStatus>? _footerStreamController;

  /// The scroll position of the refresher's inner scrollable.
  ScrollPosition? position;

  /// The current status of the header.
  RefreshStatus? get headerStatus => headerMode?.value;

  /// The current status of the footer.
  LoadStatus? get footerStatus => footerMode?.value;

  /// Whether the header is currently in the refreshing state.
  bool get isRefresh => headerMode?.value == RefreshStatus.refreshing;

  /// Whether the refresher is currently in two-level mode.
  bool get isTwoLevel =>
      headerMode?.value == RefreshStatus.twoLeveling ||
      headerMode?.value == RefreshStatus.twoLevelOpening ||
      headerMode?.value == RefreshStatus.twoLevelClosing;

  /// Whether the footer is currently in the loading state.
  bool get isLoading => footerMode?.value == LoadStatus.loading;

  /// Whether to initiate a refresh when the widget is first initialized.
  final bool initialRefresh;

  /// A stream of the header's refresh status.
  Stream<RefreshStatus> get headerStream {
    _headerStreamController ??= StreamController<RefreshStatus>.broadcast();
    return _headerStreamController!.stream;
  }

  /// Exposes the refresh state as a stream for reactive consumers.
  /// Alias for [headerStream].
  Stream<RefreshStatus> get stream => headerStream;

  /// A stream of the footer's loading status.
  Stream<LoadStatus> get footerStream {
    _footerStreamController ??= StreamController<LoadStatus>.broadcast();
    return _footerStreamController!.stream;
  }

  /// Creates a [RefreshController].
  RefreshController(
      {this.initialRefresh = false,
      RefreshStatus? initialRefreshStatus,
      LoadStatus? initialLoadStatus,
      ContentStatus initialContentStatus = ContentStatus.idle}) {
    headerMode = RefreshNotifier(initialRefreshStatus ?? RefreshStatus.idle);
    footerMode = RefreshNotifier(initialLoadStatus ?? LoadStatus.idle);
    contentStatus = ValueNotifier<ContentStatus>(initialContentStatus);
    headerMode!.addListener(_headerListener);
    footerMode!.addListener(_footerListener);
  }

  void _headerListener() {
    _headerStreamController?.add(headerMode!.value);
  }

  void _footerListener() {
    _footerStreamController?.add(footerMode!.value);
  }

  /// Disposes of the controller and its associated resources.
  void dispose() {
    headerMode!.removeListener(_headerListener);
    footerMode!.removeListener(_footerListener);
    _headerStreamController?.close();
    _footerStreamController?.close();
    headerMode!.dispose();
    footerMode!.dispose();
    headerMode = null;
    footerMode = null;
  }

  void _bindState(SmartRefresherState state) {
    if (_refresherState != null && _refresherState != state) {
      _detachPosition();
    }
    _refresherState = state;
  }

  /// Updates the controller with the new scroll position.
  void onPositionUpdated(ScrollPosition newPosition) {
    position?.isScrollingNotifier.removeListener(_listenScrollEnd);
    position = newPosition;
    position!.isScrollingNotifier.addListener(_listenScrollEnd);
  }

  void _detachPosition() {
    _refresherState = null;
    position?.isScrollingNotifier.removeListener(_listenScrollEnd);
  }

  StatefulElement? _findIndicator(BuildContext context, Type elementType) {
    StatefulElement? result;
    context.visitChildElements((Element element) {
      if (elementType == RefreshIndicator) {
        if (element.widget is RefreshIndicator) {
          result = element as StatefulElement?;
        }
      } else {
        if (element.widget is LoadIndicator) {
          result = element as StatefulElement?;
        }
      }

      result ??= _findIndicator(element, elementType);
    });
    return result;
  }

  void _listenScrollEnd() {
    if (position != null && position!.outOfRange) {
      position?.activity?.applyNewDimensions();
    }
  }

  /// Triggers a pull-down refresh programmatically.
  Future<void>? requestRefresh(
      {bool needMove = true,
      bool needCallback = true,
      Duration duration = SmartRefresherConstants.defaultAnimationDuration,
      Curve curve = Curves.linear}) {
    assert(position != null,
        'Try not to call requestRefresh() before build, please call after the ui was rendered');
    if (isRefresh) return Future<void>.value();
    if (_refresherState == null || !_refresherState!.mounted) return null;

    final StatefulElement? indicatorElement =
        _findIndicator(position!.context.storageContext, RefreshIndicator);

    if (indicatorElement == null) return null;
    (indicatorElement.state as RefreshIndicatorState).floating = true;

    if (needMove && _refresherState!.mounted) {
      _refresherState!.setCanDrag(false);
    }
    if (needMove) {
      return Future<void>.delayed(SmartRefresherConstants.defaultSettleDuration)
          .then((_) async {
        await position
            ?.animateTo(
                position!.minScrollExtent -
                    SmartRefresherConstants.minScrollSettlingOffset,
                duration: duration,
                curve: curve)
            .then((_) {
          if (_refresherState != null && _refresherState!.mounted) {
            _refresherState!.setCanDrag(true);
            if (needCallback) {
              headerMode!.value = RefreshStatus.refreshing;
            } else {
              headerMode!.setValueWithNoNotify(RefreshStatus.refreshing);
              if (indicatorElement.state.mounted) {
                (indicatorElement.state as RefreshIndicatorState)
                    .setState(() {});
              }
            }
          }
        });
      });
    } else {
      Future<void>.value().then((_) {
        headerMode!.value = RefreshStatus.refreshing;
      });
    }
    return null;
  }

  /// Triggers the two-level mode programmatically.
  Future<void> requestTwoLevel(
      {Duration duration = SmartRefresherConstants.defaultAnimationDuration,
      Curve curve = Curves.linear}) {
    assert(position != null,
        'Try not to call requestRefresh() before build, please call after the ui was rendered');
    headerMode!.value = RefreshStatus.twoLevelOpening;
    return Future<void>.delayed(SmartRefresherConstants.defaultSettleDuration)
        .then((_) async {
      await position?.animateTo(position!.minScrollExtent,
          duration: duration, curve: curve);
    });
  }

  /// Triggers a pull-up load programmatically.
  Future<void>? requestLoading(
      {bool needMove = true,
      bool needCallback = true,
      Duration duration = SmartRefresherConstants.defaultAnimationDuration,
      Curve curve = Curves.linear}) {
    assert(position != null,
        'Try not to call requestLoading() before build, please call after the ui was rendered');
    if (isLoading) return Future<void>.value();
    if (_refresherState == null || !_refresherState!.mounted) return null;

    final StatefulElement? indicatorElement =
        _findIndicator(position!.context.storageContext, LoadIndicator);

    if (indicatorElement == null) return null;
    (indicatorElement.state as LoadIndicatorState).floating = true;
    if (needMove && _refresherState!.mounted) {
      _refresherState!.setCanDrag(false);
    }
    if (needMove) {
      return Future<void>.delayed(SmartRefresherConstants.defaultSettleDuration)
          .then((_) async {
        await position
            ?.animateTo(position!.maxScrollExtent,
                duration: duration, curve: curve)
            .then((_) {
          if (_refresherState != null && _refresherState!.mounted) {
            _refresherState!.setCanDrag(true);
            if (needCallback) {
              footerMode!.value = LoadStatus.loading;
            } else {
              footerMode!.setValueWithNoNotify(LoadStatus.loading);
              if (indicatorElement.state.mounted) {
                (indicatorElement.state as LoadIndicatorState).setState(() {});
              }
            }
          }
        });
      });
    } else {
      return Future<void>.value().then((_) {
        footerMode!.value = LoadStatus.loading;
      });
    }
  }

  /// Notifies the controller that the refresh process is complete.
  void refreshCompleted({bool resetFooterState = false}) {
    headerMode?.value = RefreshStatus.completed;
    if (resetFooterState) {
      resetNoData();
    }
  }

  /// Completes the two-level mode and returns to the normal state.
  Future<void>? twoLevelComplete(
      {Duration duration = const Duration(milliseconds: 500),
      Curve curve = Curves.linear}) {
    headerMode?.value = RefreshStatus.twoLevelClosing;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      position!
          .animateTo(0.0, duration: duration, curve: curve)
          .whenComplete(() {
        headerMode!.value = RefreshStatus.idle;
      });
    });
    return null;
  }

  /// Notifies the controller that the refresh process failed.
  void refreshFailed({Object? error, StackTrace? stackTrace}) {
    headerMode?.setError(error, stackTrace);
    headerMode?.value = RefreshStatus.failed;
  }

  /// Resets the header state to idle.
  void refreshToIdle() {
    headerMode?.value = RefreshStatus.idle;
  }

  /// Notifies the controller that the loading process is complete.
  void loadComplete() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      footerMode?.value = LoadStatus.idle;
    });
  }

  /// Notifies the controller that the loading process failed.
  void loadFailed({Object? error, StackTrace? stackTrace}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      footerMode?.setError(error, stackTrace);
      footerMode?.value = LoadStatus.failed;
    });
  }

  /// Notifies the controller that there is no more data to load.
  void loadNoData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      footerMode?.value = LoadStatus.noMore;
    });
  }

  /// Resets the footer from the no-more-data state to idle.
  void resetNoData() {
    if (footerMode?.value == LoadStatus.noMore) {
      footerMode!.value = LoadStatus.idle;
    }
  }
}

/// A global configuration widget for [SmartRefresher] widgets in its subtree.
class RefreshConfiguration extends InheritedWidget {
  /// Global default header builder.
  final IndicatorBuilder? headerBuilder;

  /// Global default footer builder.
  final IndicatorBuilder? footerBuilder;

  /// Custom spring animation description.
  final SpringDescription springDescription;

  /// Whether to skip the "canRefresh" state and enter "refreshing" immediately.
  final bool skipCanRefresh;

  /// Determines whether the footer should follow the content.
  final ShouldFollowContent? shouldFooterFollowWhenNotFull;

  /// Whether to hide the footer when the content doesn't fill the viewport.
  final bool hideFooterWhenNotFull;

  /// Whether scrolling is enabled during two-level mode.
  final bool enableScrollWhenTwoLevel;

  /// Whether scrolling is enabled after refresh completion.
  final bool enableScrollWhenRefreshCompleted;

  /// Whether to enable ballistic refresh.
  final bool enableBallisticRefresh;

  /// Whether to enable ballistic loading.
  final bool enableBallisticLoad;

  /// Whether pull-up triggers loading when in a failed state.
  final bool enableLoadingWhenFailed;

  /// Whether pull-up triggers loading when in a no-more-data state.
  final bool enableLoadingWhenNoData;

  /// The distance needed to trigger a pull-down refresh.
  final double headerTriggerDistance;

  /// The distance needed to trigger two-level mode.
  final double twiceTriggerDistance;

  /// The distance needed to close the two-level mode from the bottom.
  final double closeTwoLevelDistance;

  /// The distance needed to trigger pull-up loading.
  final double footerTriggerDistance;

  /// The ratio applied to the drag speed during overscroll.
  final double dragSpeedRatio;

  /// The maximum extent for overscrolling.
  final double? maxOverScrollExtent;

  /// The maximum extent for underscrolling.
  final double? maxUnderScrollExtent;

  /// The boundary at the top where inertia stops.
  final double? topHitBoundary;

  /// The boundary at the bottom where inertia stops.
  final double? bottomHitBoundary;

  /// Whether to enable vibration feedback during refresh.
  final bool enableRefreshVibrate;

  /// Whether to enable vibration feedback during loading.
  final bool enableLoadMoreVibrate;

  /// Whether to enable haptic feedback when the refresh threshold is reached.
  final bool enableThresholdHaptic;

  /// Creates a [RefreshConfiguration].
  const RefreshConfiguration(
      {super.key,
      required super.child,
      this.headerBuilder,
      this.footerBuilder,
      this.dragSpeedRatio = 1.0,
      this.shouldFooterFollowWhenNotFull,
      this.enableScrollWhenTwoLevel = true,
      this.enableLoadingWhenNoData = false,
      this.enableBallisticRefresh = false,
      this.springDescription = const SpringDescription(
        mass: SmartRefresherConstants.defaultSpringMass,
        stiffness: SmartRefresherConstants.defaultSpringStiffness,
        damping: SmartRefresherConstants.defaultSpringDamping,
      ),
      this.enableScrollWhenRefreshCompleted = false,
      this.enableLoadingWhenFailed = true,
      this.twiceTriggerDistance = SmartRefresherConstants.defaultTwiceTriggerDistance,
      this.closeTwoLevelDistance = SmartRefresherConstants.defaultCloseTwoLevelDistance,
      this.skipCanRefresh = false,
      this.maxOverScrollExtent,
      this.enableBallisticLoad = true,
      this.maxUnderScrollExtent,
      this.headerTriggerDistance = SmartRefresherConstants.defaultHeaderTriggerDistance,
      this.footerTriggerDistance = SmartRefresherConstants.defaultFooterTriggerDistance,
      this.hideFooterWhenNotFull = false,
      this.enableRefreshVibrate = false,
      this.enableLoadMoreVibrate = false,
      this.enableThresholdHaptic = false,
      this.topHitBoundary,
      this.bottomHitBoundary})
      : assert(headerTriggerDistance > 0),
        assert(twiceTriggerDistance > 0),
        assert(closeTwoLevelDistance > 0),
        assert(dragSpeedRatio > 0);

  /// Creates a [RefreshConfiguration] that copies attributes from its ancestor.
  RefreshConfiguration.copyAncestor({
    super.key,
    required BuildContext context,
    required super.child,
    IndicatorBuilder? headerBuilder,
    IndicatorBuilder? footerBuilder,
    double? dragSpeedRatio,
    ShouldFollowContent? shouldFooterFollowWhenNotFull,
    bool? enableScrollWhenTwoLevel,
    bool? enableBallisticRefresh,
    bool? enableBallisticLoad,
    bool? enableLoadingWhenNoData,
    SpringDescription? springDescription,
    bool? enableScrollWhenRefreshCompleted,
    bool? enableLoadingWhenFailed,
    double? twiceTriggerDistance,
    double? closeTwoLevelDistance,
    bool? skipCanRefresh,
    double? maxOverScrollExtent,
    double? maxUnderScrollExtent,
    double? topHitBoundary,
    double? bottomHitBoundary,
    double? headerTriggerDistance,
    double? footerTriggerDistance,
    bool? enableRefreshVibrate,
    bool? enableLoadMoreVibrate,
    bool? hideFooterWhenNotFull,
    bool? enableThresholdHaptic,
  })  : assert(RefreshConfiguration.of(context) != null,
            'RefreshConfiguration ancestor not found'),
        headerBuilder =
            headerBuilder ?? RefreshConfiguration.of(context)!.headerBuilder,
        footerBuilder =
            footerBuilder ?? RefreshConfiguration.of(context)!.footerBuilder,
        dragSpeedRatio =
            dragSpeedRatio ?? RefreshConfiguration.of(context)!.dragSpeedRatio,
        twiceTriggerDistance = twiceTriggerDistance ??
            RefreshConfiguration.of(context)!.twiceTriggerDistance,
        headerTriggerDistance = headerTriggerDistance ??
            RefreshConfiguration.of(context)!.headerTriggerDistance,
        footerTriggerDistance = footerTriggerDistance ??
            RefreshConfiguration.of(context)!.footerTriggerDistance,
        springDescription = springDescription ??
            RefreshConfiguration.of(context)!.springDescription,
        hideFooterWhenNotFull = hideFooterWhenNotFull ??
            RefreshConfiguration.of(context)!.hideFooterWhenNotFull,
        maxOverScrollExtent = maxOverScrollExtent ??
            RefreshConfiguration.of(context)!.maxOverScrollExtent,
        maxUnderScrollExtent = maxUnderScrollExtent ??
            RefreshConfiguration.of(context)!.maxUnderScrollExtent,
        topHitBoundary =
            topHitBoundary ?? RefreshConfiguration.of(context)!.topHitBoundary,
        bottomHitBoundary = bottomHitBoundary ??
            RefreshConfiguration.of(context)!.bottomHitBoundary,
        skipCanRefresh =
            skipCanRefresh ?? RefreshConfiguration.of(context)!.skipCanRefresh,
        enableScrollWhenRefreshCompleted = enableScrollWhenRefreshCompleted ??
            RefreshConfiguration.of(context)!.enableScrollWhenRefreshCompleted,
        enableScrollWhenTwoLevel = enableScrollWhenTwoLevel ??
            RefreshConfiguration.of(context)!.enableScrollWhenTwoLevel,
        enableBallisticRefresh = enableBallisticRefresh ??
            RefreshConfiguration.of(context)!.enableBallisticRefresh,
        enableBallisticLoad = enableBallisticLoad ??
            RefreshConfiguration.of(context)!.enableBallisticLoad,
        enableLoadingWhenNoData = enableLoadingWhenNoData ??
            RefreshConfiguration.of(context)!.enableLoadingWhenNoData,
        enableLoadingWhenFailed = enableLoadingWhenFailed ??
            RefreshConfiguration.of(context)!.enableLoadingWhenFailed,
        closeTwoLevelDistance = closeTwoLevelDistance ??
            RefreshConfiguration.of(context)!.closeTwoLevelDistance,
        enableRefreshVibrate = enableRefreshVibrate ??
            RefreshConfiguration.of(context)!.enableRefreshVibrate,
        enableLoadMoreVibrate = enableLoadMoreVibrate ??
            RefreshConfiguration.of(context)!.enableLoadMoreVibrate,
        enableThresholdHaptic = enableThresholdHaptic ??
            RefreshConfiguration.of(context)!.enableThresholdHaptic,
        shouldFooterFollowWhenNotFull = shouldFooterFollowWhenNotFull ??
            RefreshConfiguration.of(context)!.shouldFooterFollowWhenNotFull;

  /// Returns the [RefreshConfiguration] from the given [context].
  static RefreshConfiguration? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<RefreshConfiguration>();
  }

  @override
  bool updateShouldNotify(RefreshConfiguration oldWidget) {
    return skipCanRefresh != oldWidget.skipCanRefresh ||
        hideFooterWhenNotFull != oldWidget.hideFooterWhenNotFull ||
        dragSpeedRatio != oldWidget.dragSpeedRatio ||
        enableScrollWhenRefreshCompleted !=
            oldWidget.enableScrollWhenRefreshCompleted ||
        enableBallisticRefresh != oldWidget.enableBallisticRefresh ||
        enableScrollWhenTwoLevel != oldWidget.enableScrollWhenTwoLevel ||
        closeTwoLevelDistance != oldWidget.closeTwoLevelDistance ||
        footerTriggerDistance != oldWidget.footerTriggerDistance ||
        headerTriggerDistance != oldWidget.headerTriggerDistance ||
        twiceTriggerDistance != oldWidget.twiceTriggerDistance ||
        maxUnderScrollExtent != oldWidget.maxUnderScrollExtent ||
        oldWidget.maxOverScrollExtent != maxOverScrollExtent ||
        enableBallisticRefresh != oldWidget.enableBallisticRefresh ||
        enableLoadingWhenFailed != oldWidget.enableLoadingWhenFailed ||
        topHitBoundary != oldWidget.topHitBoundary ||
        enableRefreshVibrate != oldWidget.enableRefreshVibrate ||
        enableLoadMoreVibrate != oldWidget.enableLoadMoreVibrate ||
        enableThresholdHaptic != oldWidget.enableThresholdHaptic ||
        bottomHitBoundary != oldWidget.bottomHitBoundary;
  }
}

/// A value notifier that manages refresh states.
class RefreshNotifier<T> extends ChangeNotifier implements ValueListenable<T> {
  /// Creates a [RefreshNotifier] with an initial value.
  RefreshNotifier(this._value);
  T _value;

  /// The error that occurred during the refresh/load process.
  Object? error;

  /// The stack trace associated with the error.
  StackTrace? stackTrace;

  /// The current value of the notifier.
  @override
  T get value => _value;

  /// Sets a new value and notifies listeners.
  ///
  /// If the new value is not [RefreshStatus.failed] or [LoadStatus.failed],
  /// the [error] and [stackTrace] are automatically cleared.
  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    if (newValue != RefreshStatus.failed && newValue != LoadStatus.failed) {
      error = null;
      stackTrace = null;
    }
    notifyListeners();
  }

  /// Sets the value without notifying listeners.
  void setValueWithNoNotify(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    if (newValue != RefreshStatus.failed && newValue != LoadStatus.failed) {
      error = null;
      stackTrace = null;
    }
  }

  /// Sets the error and stack trace and notifies listeners.
  void setError(Object? err, StackTrace? st) {
    error = err;
    stackTrace = st;
    notifyListeners();
  }

  @override
  String toString() => '${describeIdentity(this)}($value)';
}
