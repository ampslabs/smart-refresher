/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/4 9:49 PM
 */

import 'package:flutter/widgets.dart';
import '../internals/indicator_wrap.dart';
import '../smart_refresher.dart';

/// Custom header builder. The second parameter provides the current header state.
typedef HeaderBuilder = Widget Function(
    BuildContext context, RefreshStatus? mode);

/// Custom footer builder. The second parameter provides the current footer state.
typedef FooterBuilder = Widget Function(BuildContext context, LoadStatus? mode);

/// A custom refresh header indicator.
///
/// Simple usage:
/// ```dart
/// CustomHeader(
///   builder: (context, mode) {
///     Widget body;
///     if (mode == RefreshStatus.idle) {
///       body = Text("pull down refresh");
///     } else if (mode == RefreshStatus.refreshing) {
///       body = CupertinoActivityIndicator();
///     } else if (mode == RefreshStatus.canRefresh) {
///       body = Text("release to refresh");
///     } else if (mode == RefreshStatus.completed) {
///       body = Text("refreshCompleted!");
///     }
///     return Container(
///       height: 60.0,
///       child: Center(
///         child: body,
///       ),
///     );
///   },
/// )
/// ```
///
/// Use SmartRefresher.onOffsetChange to listen to overscroll events for animations.
/// For complex or frequently updating animations, consider extending [RefreshIndicator] directly.
///
/// See also:
///
/// [CustomFooter], a custom loading footer indicator.
class CustomHeader extends RefreshIndicator {
  /// The builder function for the header content.
  final HeaderBuilder builder;

  /// Callback when the header is ready to start refreshing.
  final VoidFutureCallBack? readyToRefresh;

  /// Callback when the refresh process ends.
  final VoidFutureCallBack? endRefresh;

  /// Callback when the scroll offset changes.
  final OffsetCallBack? onOffsetChange;

  /// Callback when the refresh status changes.
  final ModeChangeCallBack<RefreshStatus>? onModeChange;

  /// Callback when the header values are reset.
  final VoidCallback? onResetValue;

  /// Creates a [CustomHeader].
  const CustomHeader({
    super.key,
    required this.builder,
    this.readyToRefresh,
    this.endRefresh,
    this.onOffsetChange,
    this.onModeChange,
    this.onResetValue,
    super.height,
    super.completeDuration = const Duration(milliseconds: 600),
    RefreshStyle super.refreshStyle,
  });

  @override
  State<StatefulWidget> createState() {
    return _CustomHeaderState();
  }
}

class _CustomHeaderState extends RefreshIndicatorState<CustomHeader> {
  @override
  void onOffsetChange(double offset) {
    if (widget.onOffsetChange != null) {
      widget.onOffsetChange!(offset);
    }
    super.onOffsetChange(offset);
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    if (widget.onModeChange != null) {
      widget.onModeChange!(mode);
    }
    super.onModeChange(mode);
  }

  @override
  Future<void> readyToRefresh() {
    if (widget.readyToRefresh != null) {
      return widget.readyToRefresh!();
    }
    return super.readyToRefresh();
  }

  @override
  Future<void> endRefresh() {
    if (widget.endRefresh != null) {
      return widget.endRefresh!();
    }
    return super.endRefresh();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    return widget.builder(context, mode);
  }
}

/// A custom loading footer indicator. Usage is similar to [CustomHeader].
///
/// See also:
///
/// [CustomHeader], a custom refresh header indicator.
class CustomFooter extends LoadIndicator {
  /// The builder function for the footer content.
  final FooterBuilder builder;

  /// Callback when the scroll offset changes.
  final OffsetCallBack? onOffsetChange;

  /// Callback when the loading status changes.
  final ModeChangeCallBack<LoadStatus>? onModeChange;

  /// Callback when the footer is ready to start loading.
  final VoidFutureCallBack? readyLoading;

  /// Callback when the loading process ends.
  final VoidFutureCallBack? endLoading;

  /// Creates a [CustomFooter].
  const CustomFooter({
    super.key,
    super.height,
    this.onModeChange,
    this.onOffsetChange,
    this.readyLoading,
    this.endLoading,
    super.loadStyle,
    required this.builder,
    super.onClick,
  });

  @override
  State<StatefulWidget> createState() {
    return _CustomFooterState();
  }
}

class _CustomFooterState extends LoadIndicatorState<CustomFooter> {
  @override
  void onOffsetChange(double offset) {
    if (widget.onOffsetChange != null) {
      widget.onOffsetChange!(offset);
    }
    super.onOffsetChange(offset);
  }

  @override
  void onModeChange(LoadStatus? mode) {
    if (widget.onModeChange != null) {
      widget.onModeChange!(mode);
    }
    super.onModeChange(mode);
  }

  @override
  Future<void> readyToLoad() {
    if (widget.readyLoading != null) {
      return widget.readyLoading!();
    }
    return super.readyToLoad();
  }

  @override
  Future<void> endLoading() {
    if (widget.endLoading != null) {
      return widget.endLoading!();
    }
    return super.endLoading();
  }

  @override
  Widget buildContent(BuildContext context, LoadStatus? mode) {
    return widget.builder(context, mode);
  }
}
