/*
    Author: JPeng
    Email: peng8350@gmail.com
    createTime:2018-05-14 3:39 PM
 */

// ignore_for_file: INVALID_USE_OF_PROTECTED_MEMBER
// ignore_for_file: INVALID_USE_OF_VISIBLE_FOR_TESTING_MEMBER
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:math' as math;
import '../smart_refresher.dart';
import 'slivers.dart';

/// A callback that returns a [Future] with no value.
typedef VoidFutureCallBack = Future<void> Function();

/// A callback that provides the current scroll offset.
typedef OffsetCallBack = void Function(double offset);

/// A callback that provides the current mode change.
typedef ModeChangeCallBack<T> = void Function(T? mode);

/// An abstract widget that implements the pull-to-refresh effect.
///
/// This provides the base for various refresh header styles.
abstract class RefreshIndicator extends StatefulWidget {
  /// The display style of the refresh header.
  final RefreshStyle? refreshStyle;

  /// The height of the indicator's visual extent.
  final double height;

  /// The layout offset of the indicator.
  final double offset;

  /// The duration the indicator remains visible after the refresh is complete or fails.
  final Duration completeDuration;

  /// Creates a [RefreshIndicator].
  const RefreshIndicator(
      {super.key,
      this.height = 60.0,
      this.offset = 0.0,
      this.completeDuration = const Duration(milliseconds: 500),
      this.refreshStyle = RefreshStyle.Follow});
}

/// An abstract widget that implements the pull-up loading effect.
///
/// This provides the base for various loading footer styles.
abstract class LoadIndicator extends StatefulWidget {
  /// The display style of the loading footer.
  final LoadStyle loadStyle;

  /// The height of the indicator's visual extent.
  final double height;

  /// A callback triggered when the user clicks the footer.
  final VoidCallback? onClick;

  /// Creates a [LoadIndicator].
  const LoadIndicator(
      {super.key,
      this.onClick,
      this.loadStyle = LoadStyle.ShowAlways,
      this.height = 60.0});
}

/// The state for a [RefreshIndicator].
///
/// Extend this class to implement custom header indicators with complex animations.
abstract class RefreshIndicatorState<T extends RefreshIndicator>
    extends State<T>
    with IndicatorStateMixin<T, RefreshStatus>, RefreshProcessor {
  bool _inVisual() {
    return _position!.pixels < 0.0;
  }

  @override
  double _calculateScrollOffset() {
    return (floating
            ? (mode == RefreshStatus.twoLeveling ||
                    mode == RefreshStatus.twoLevelOpening ||
                    mode == RefreshStatus.twoLevelClosing
                ? refresherState!.viewportExtent
                : widget.height)
            : 0.0) -
        (_position!.pixels as num);
  }

  @override
  void _handleOffsetChange() {
    super._handleOffsetChange();
    final double overscrollPast = _calculateScrollOffset();
    onOffsetChange(overscrollPast);
  }

  @override
  void _dispatchModeByOffset(double offset) {
    if (mode == RefreshStatus.twoLeveling) {
      if (_position!.pixels > configuration!.closeTwoLevelDistance &&
          activity is BallisticScrollActivity) {
        refresher!.controller.twoLevelComplete();
        return;
      }
    }
    if (RefreshStatus.twoLevelOpening == mode ||
        mode == RefreshStatus.twoLevelClosing) {
      return;
    }
    if (floating) return;
    if (offset == 0.0) {
      mode = RefreshStatus.idle;
    }

    if (_position!.extentBefore == 0.0 &&
        widget.refreshStyle == RefreshStyle.Front) {
      _position!.context.setIgnorePointer(false);
    }
    if ((configuration!.enableBallisticRefresh && activity!.velocity < 0.0) ||
        activity is DragScrollActivity ||
        activity is DrivenScrollActivity) {
      if (refresher!.enablePullDown &&
          offset >= configuration!.headerTriggerDistance) {
        if (!configuration!.skipCanRefresh) {
          mode = RefreshStatus.canRefresh;
        } else {
          floating = true;
          update();
          readyToRefresh().then((_) {
            if (!mounted) return;
            mode = RefreshStatus.refreshing;
          });
        }
      } else if (refresher!.enablePullDown) {
        mode = RefreshStatus.idle;
      }
      if (refresher!.enableTwoLevel &&
          offset >= configuration!.twiceTriggerDistance) {
        mode = RefreshStatus.canTwoLevel;
      } else if (refresher!.enableTwoLevel && !refresher!.enablePullDown) {
        mode = RefreshStatus.idle;
      }
    } else if (activity is BallisticScrollActivity) {
      if (RefreshStatus.canRefresh == mode) {
        floating = true;
        update();
        readyToRefresh().then((_) {
          if (!mounted) return;
          mode = RefreshStatus.refreshing;
        });
      }
      if (mode == RefreshStatus.canTwoLevel) {
        floating = true;
        update();
        if (!mounted) return;

        mode = RefreshStatus.twoLevelOpening;
      }
    }
  }

  @override
  void _handleModeChange() {
    if (!mounted) {
      return;
    }
    update();
    if (mode == RefreshStatus.idle || mode == RefreshStatus.canRefresh) {
      floating = false;

      resetValue();

      if (mode == RefreshStatus.idle) refresherState!.setCanDrag(true);
    }
    if (mode == RefreshStatus.completed || mode == RefreshStatus.failed) {
      endRefresh().then((_) {
        if (!mounted) return;
        floating = false;
        if (mode == RefreshStatus.completed || mode == RefreshStatus.failed) {
          refresherState!
              .setCanDrag(configuration!.enableScrollWhenRefreshCompleted);
        }
        update();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }
          if (widget.refreshStyle == RefreshStyle.Front) {
            if (_inVisual()) {
              _position!.jumpTo(0.0);
            }
            mode = RefreshStatus.idle;
          } else {
            if (!_inVisual()) {
              mode = RefreshStatus.idle;
            } else {
              activity!.delegate.goBallistic(0.0);
            }
          }
        });
      });
    } else if (mode == RefreshStatus.refreshing) {
      if (!floating) {
        floating = true;
        readyToRefresh();
      }
      if (configuration!.enableRefreshVibrate) {
        HapticFeedback.vibrate();
      }
      if (refresher!.onRefresh != null) refresher!.onRefresh!();
    } else if (mode == RefreshStatus.twoLevelOpening) {
      floating = true;
      refresherState!.setCanDrag(false);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        activity!.resetActivity();
        if (_position!.pixels == 0.0) {
          mode = RefreshStatus.twoLeveling;
        } else {
          _position!
              .animateTo(0.0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linear)
              .whenComplete(() {
            mode = RefreshStatus.twoLeveling;
          });
        }
        if (refresher!.onTwoLevel != null) refresher!.onTwoLevel!(true);
      });
    } else if (mode == RefreshStatus.twoLevelClosing) {
      floating = false;
      refresherState!.setCanDrag(false);
      update();
      if (refresher!.onTwoLevel != null) refresher!.onTwoLevel!(false);
    } else if (mode == RefreshStatus.twoLeveling) {
      refresherState!.setCanDrag(configuration!.enableScrollWhenTwoLevel);
    }
    onModeChange(mode);
  }

  @override
  Future<void> readyToRefresh() {
    return Future.value();
  }

  @override
  Future<void> endRefresh() {
    return Future.delayed(widget.completeDuration);
  }

  /// Whether the indicator needs to be reversed based on scroll direction.
  bool needReverseAll() {
    return true;
  }

  @override
  void resetValue() {}

  @override
  Widget build(BuildContext context) {
    return SliverRefresh(
        paintOffsetY: widget.offset,
        floating: floating,
        refreshIndicatorLayoutExtent: mode == RefreshStatus.twoLeveling ||
                mode == RefreshStatus.twoLevelOpening ||
                mode == RefreshStatus.twoLevelClosing
            ? refresherState!.viewportExtent
            : widget.height,
        refreshStyle: widget.refreshStyle,
        child: RotatedBox(
          quarterTurns: needReverseAll() &&
                  Scrollable.of(context).axisDirection == AxisDirection.up
              ? 10
              : 0,
          child: buildContent(context, mode!),
        ));
  }
}

/// The state for a [LoadIndicator].
///
/// Extend this class to implement custom footer indicators.
abstract class LoadIndicatorState<T extends LoadIndicator> extends State<T>
    with IndicatorStateMixin<T, LoadStatus>, LoadingProcessor {
  bool _isHide = false;
  bool _enableLoading = false;
  LoadStatus? _lastMode = LoadStatus.idle;

  @override
  double _calculateScrollOffset() {
    final double overScrollPastEnd =
        math.max(_position!.pixels - _position!.maxScrollExtent, 0.0);
    return overScrollPastEnd;
  }

  /// Triggers the loading state.
  void enterLoading() {
    setState(() {
      floating = true;
    });
    _enableLoading = false;
    readyToLoad().then((_) {
      if (!mounted) {
        return;
      }
      mode = LoadStatus.loading;
    });
  }

  @override
  Future<void> endLoading() {
    return Future.delayed(const Duration());
  }

  /// Resets the loading state after completion.
  void finishLoading() {
    if (!floating) {
      return;
    }
    endLoading().then((_) {
      if (!mounted) {
        return;
      }

      if (mounted) Scrollable.of(context).position.correctBy(0.00001);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _position?.outOfRange == true) {
          activity!.delegate.goBallistic(0);
        }
      });
      setState(() {
        floating = false;
      });
    });
  }

  bool _checkIfCanLoading() {
    if (_position!.maxScrollExtent - _position!.pixels <=
            configuration!.footerTriggerDistance &&
        _position!.extentBefore > 2.0 &&
        _enableLoading) {
      if (!configuration!.enableLoadingWhenFailed &&
          mode == LoadStatus.failed) {
        return false;
      }
      if (!configuration!.enableLoadingWhenNoData &&
          mode == LoadStatus.noMore) {
        return false;
      }
      if (mode != LoadStatus.canLoading &&
          _position!.userScrollDirection == ScrollDirection.forward) {
        return false;
      }
      return true;
    }
    return false;
  }

  @override
  void _handleModeChange() {
    if (!mounted || _isHide) {
      return;
    }

    update();
    if (mode == LoadStatus.idle ||
        mode == LoadStatus.failed ||
        mode == LoadStatus.noMore) {
      if (_position!.activity!.velocity < 0 &&
          _lastMode == LoadStatus.loading &&
          !_position!.outOfRange &&
          _position is ScrollActivityDelegate) {
        _position!.beginActivity(
            IdleScrollActivity(_position! as ScrollActivityDelegate));
      }

      finishLoading();
    }
    if (mode == LoadStatus.loading) {
      if (!floating) {
        enterLoading();
      }
      if (configuration!.enableLoadMoreVibrate) {
        HapticFeedback.vibrate();
      }
      if (refresher!.onLoading != null) {
        refresher!.onLoading!();
      }
      if (widget.loadStyle == LoadStyle.ShowWhenLoading) {
        floating = true;
      }
    } else {
      if (activity is! DragScrollActivity) _enableLoading = false;
    }
    _lastMode = mode;
    onModeChange(mode);
  }

  @override
  void _dispatchModeByOffset(double offset) {
    if (!mounted || _isHide || LoadStatus.loading == mode || floating) {
      return;
    }
    if (activity is DragScrollActivity) {
      if (_checkIfCanLoading()) {
        mode = LoadStatus.canLoading;
      } else {
        mode = _lastMode;
      }
    }
    if (activity is BallisticScrollActivity) {
      if (configuration!.enableBallisticLoad) {
        if (_checkIfCanLoading()) enterLoading();
      } else if (mode == LoadStatus.canLoading) {
        enterLoading();
      }
    }
  }

  @override
  void _handleOffsetChange() {
    if (_isHide) {
      return;
    }
    super._handleOffsetChange();
    final double overscrollPast = _calculateScrollOffset();
    onOffsetChange(overscrollPast);
  }

  void _listenScrollEnd() {
    if (!_position!.isScrollingNotifier.value) {
      if (_isHide || mode == LoadStatus.loading || mode == LoadStatus.noMore) {
        return;
      }

      if (_checkIfCanLoading()) {
        if (activity is IdleScrollActivity) {
          if ((configuration!.enableBallisticLoad) ||
              ((!configuration!.enableBallisticLoad) &&
                  mode == LoadStatus.canLoading)) {
            enterLoading();
          }
        }
      }
    } else {
      if (activity is DragScrollActivity || activity is DrivenScrollActivity) {
        _enableLoading = true;
      }
    }
  }

  @override
  void _onPositionUpdated(ScrollPosition newPosition) {
    _position?.isScrollingNotifier.removeListener(_listenScrollEnd);
    newPosition.isScrollingNotifier.addListener(_listenScrollEnd);
    super._onPositionUpdated(newPosition);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lastMode = mode;
  }

  @override
  void dispose() {
    _position?.isScrollingNotifier.removeListener(_listenScrollEnd);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverLoading(
        hideWhenNotFull: configuration!.hideFooterWhenNotFull,
        floating: widget.loadStyle == LoadStyle.ShowAlways
            ? true
            : widget.loadStyle == LoadStyle.HideAlways
                ? false
                : floating,
        shouldFollowContent:
            configuration!.shouldFooterFollowWhenNotFull != null
                ? configuration!.shouldFooterFollowWhenNotFull!(mode)
                : mode == LoadStatus.noMore,
        layoutExtent: widget.height,
        mode: mode,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints cons) {
            _isHide = cons.biggest.height == 0.0;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (widget.onClick != null) {
                  widget.onClick!();
                }
              },
              child: buildContent(context, mode!),
            );
          },
        ));
  }
}

/// A mixin that manages the scroll position and refresh mode for header and footer indicators.
mixin IndicatorStateMixin<T extends StatefulWidget, V> on State<T> {
  /// The [SmartRefresher] that contains this indicator.
  SmartRefresher? refresher;

  /// The refresh configuration inherited from ancestors.
  RefreshConfiguration? configuration;

  /// The state of the [SmartRefresher] that contains this indicator.
  SmartRefresherState? refresherState;

  bool _floating = false;

  /// Whether the indicator is currently in a floating state.
  set floating(bool floating) => _floating = floating;

  /// Whether the indicator is currently in a floating state.
  bool get floating => _floating;

  /// Sets the current mode of the indicator.
  set mode(V? mode) {
    if (_mode != null && mode != null) {
      _mode!.value = mode;
    }
  }

  /// The current mode of the indicator.
  V? get mode => _mode?.value;

  RefreshNotifier<V>? _mode;

  /// The current scroll activity.
  ScrollActivity? get activity => _position!.activity;

  ScrollPosition? _position;

  /// Triggers a UI update.
  void update() {
    if (mounted) setState(() {});
  }

  void _handleOffsetChange() {
    if (!mounted) {
      return;
    }
    final double overscrollPast = _calculateScrollOffset();
    if (overscrollPast < 0.0) {
      return;
    }
    _dispatchModeByOffset(overscrollPast);
  }

  /// Disposes of the listeners attached to the mode and scroll position.
  void disposeListener() {
    _mode?.removeListener(_handleModeChange);
    _position?.removeListener(_handleOffsetChange);
    _position = null;
    _mode = null;
  }

  void _updateListener() {
    configuration = RefreshConfiguration.of(context);
    refresher = SmartRefresher.of(context);
    refresherState = SmartRefresher.ofState(context);
    final RefreshNotifier<V>? newMode = V == RefreshStatus
        ? refresher!.controller.headerMode as RefreshNotifier<V>?
        : refresher!.controller.footerMode as RefreshNotifier<V>?;
    final ScrollPosition newPosition = Scrollable.of(context).position;
    if (newMode != _mode) {
      _mode?.removeListener(_handleModeChange);
      _mode = newMode;
      _mode?.addListener(_handleModeChange);
    }
    if (newPosition != _position) {
      _position?.removeListener(_handleOffsetChange);
      _onPositionUpdated(newPosition);
      _position = newPosition;
      _position?.addListener(_handleOffsetChange);
    }
  }

  @override
  void initState() {
    if (V == RefreshStatus) {
      SmartRefresher.of(context)?.controller.headerMode?.value =
          RefreshStatus.idle;
    }
    super.initState();
  }

  @override
  void dispose() {
    disposeListener();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    _updateListener();
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    _updateListener();
    super.didUpdateWidget(oldWidget);
  }

  void _onPositionUpdated(ScrollPosition newPosition) {
    refresher!.controller.onPositionUpdated(newPosition);
  }

  void _handleModeChange();

  double _calculateScrollOffset();

  void _dispatchModeByOffset(double offset);

  /// Builds the content of the indicator.
  Widget buildContent(BuildContext context, V mode);
}

/// A mixin that provides the exposure interface for refresh header indicators.
mixin RefreshProcessor {
  /// Callback when the scroll offset changes.
  void onOffsetChange(double offset) {}

  /// Callback when the refresh mode changes.
  void onModeChange(RefreshStatus? mode) {}

  /// Triggered when the indicator is ready to enter the refresh state.
  Future<void> readyToRefresh() {
    return Future.value();
  }

  /// Triggered when the indicator is ready to dismiss its layout.
  Future<void> endRefresh() {
    return Future.value();
  }

  /// Resets the indicator's internal values.
  void resetValue() {}
}

/// A mixin that provides the exposure interface for loading footer indicators.
mixin LoadingProcessor {
  /// Callback when the scroll offset changes.
  void onOffsetChange(double offset) {}

  /// Callback when the loading mode changes.
  void onModeChange(LoadStatus? mode) {}

  /// Triggered when the indicator is ready to enter the loading state.
  Future<void> readyToLoad() {
    return Future.value();
  }

  /// Triggered when the indicator is ready to dismiss its layout.
  Future<void> endLoading() {
    return Future.value();
  }

  /// Resets the indicator's internal values.
  void resetValue() {}
}
