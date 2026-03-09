/*
 *   Author: Jpeng
 *   Email: peng8350@gmail.com
 *   createTime:2018-05-14 5:39 PM
 */

import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import '../smart_refresher.dart';
import '../internals/enums.dart';
import '../internals/indicator_wrap.dart';
import '../internals/refresh_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// The direction that the icon should be placed relative to the text.
enum IconPosition {
  /// Place the icon to the left of the text.
  left,

  /// Place the icon to the right of the text.
  right,

  /// Place the icon above the text.
  top,

  /// Place the icon below the text.
  bottom
}

/// A builder that wraps the indicator's child, typically used for adding background colors or padding.
typedef OuterBuilder = Widget Function(Widget child);

/// The most common refresh header, combining text and an icon.
///
/// See also:
///
/// [ClassicFooter], the footer version of this indicator.
class ClassicHeader extends RefreshIndicator {
  /// A builder for re-wrapping the child. Use this to change background, padding, etc.
  ///
  /// Example:
  /// ```dart
  /// outerBuilder: (child) {
  ///    return Container(
  ///       color: Colors.red,
  ///       child: child,
  ///    );
  /// }
  /// ```
  final OuterBuilder? outerBuilder;

  /// Custom text for different refresh states.
  final String? releaseText,
      idleText,
      refreshingText,
      completeText,
      failedText,
      canTwoLevelText;

  /// Custom icons for different refresh states.
  final Widget? releaseIcon,
      idleIcon,
      refreshingIcon,
      completeIcon,
      failedIcon,
      canTwoLevelIcon,
      twoLevelView;

  /// The margin between the icon and the text.
  final double spacing;

  /// The position of the icon relative to the text.
  final IconPosition iconPos;

  /// The style of the text in the indicator.
  final TextStyle textStyle;

  /// Creates a [ClassicHeader].
  const ClassicHeader({
    super.key,
    RefreshStyle super.refreshStyle,
    super.height,
    super.completeDuration = const Duration(milliseconds: 600),
    this.outerBuilder,
    this.textStyle = const TextStyle(color: Colors.grey),
    this.releaseText,
    this.refreshingText,
    this.canTwoLevelIcon,
    this.twoLevelView,
    this.canTwoLevelText,
    this.completeText,
    this.failedText,
    this.idleText,
    this.iconPos = IconPosition.left,
    this.spacing = 15.0,
    this.refreshingIcon,
    this.failedIcon = const Icon(Icons.error, color: Colors.grey),
    this.completeIcon = const Icon(Icons.done, color: Colors.grey),
    this.idleIcon = const Icon(Icons.arrow_downward, color: Colors.grey),
    this.releaseIcon = const Icon(Icons.refresh, color: Colors.grey),
  });

  @override
  State createState() {
    return _ClassicHeaderState();
  }
}

class _ClassicHeaderState extends RefreshIndicatorState<ClassicHeader> {
  Widget _buildText(RefreshStatus? mode) {
    final RefreshString strings =
        RefreshLocalizations.of(context)?.currentLocalization ??
            EnRefreshString();
    return Text(
        mode == RefreshStatus.canRefresh
            ? widget.releaseText ?? strings.canRefreshText!
            : mode == RefreshStatus.completed
                ? widget.completeText ?? strings.refreshCompleteText!
                : mode == RefreshStatus.failed
                    ? widget.failedText ?? strings.refreshFailedText!
                    : mode == RefreshStatus.refreshing
                        ? widget.refreshingText ?? strings.refreshingText!
                        : mode == RefreshStatus.idle
                            ? widget.idleText ?? strings.idleRefreshText!
                            : mode == RefreshStatus.canTwoLevel
                                ? widget.canTwoLevelText ??
                                    strings.canTwoLevelText!
                                : '',
        style: widget.textStyle);
  }

  Widget _buildIcon(RefreshStatus? mode) {
    final Widget? icon = mode == RefreshStatus.canRefresh
        ? widget.releaseIcon
        : mode == RefreshStatus.idle
            ? widget.idleIcon
            : mode == RefreshStatus.completed
                ? widget.completeIcon
                : mode == RefreshStatus.failed
                    ? widget.failedIcon
                    : mode == RefreshStatus.canTwoLevel
                        ? widget.canTwoLevelIcon
                        : mode == RefreshStatus.canTwoLevel
                            ? widget.canTwoLevelIcon
                            : mode == RefreshStatus.refreshing
                                ? widget.refreshingIcon ??
                                    SizedBox(
                                      width: 25.0,
                                      height: 25.0,
                                      child: defaultTargetPlatform ==
                                              TargetPlatform.iOS
                                          ? const CupertinoActivityIndicator()
                                          : const CircularProgressIndicator(
                                              strokeWidth: 2.0),
                                    )
                                : widget.twoLevelView;
    return icon ?? Container();
  }

  @override
  bool needReverseAll() {
    return false;
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    final Widget textWidget = _buildText(mode);
    final Widget iconWidget = _buildIcon(mode);
    final List<Widget> children = <Widget>[iconWidget, textWidget];
    final Widget container = Wrap(
      spacing: widget.spacing,
      textDirection: widget.iconPos == IconPosition.left
          ? TextDirection.ltr
          : TextDirection.rtl,
      direction: widget.iconPos == IconPosition.bottom ||
              widget.iconPos == IconPosition.top
          ? Axis.vertical
          : Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.center,
      verticalDirection: widget.iconPos == IconPosition.bottom
          ? VerticalDirection.up
          : VerticalDirection.down,
      alignment: WrapAlignment.center,
      children: children,
    );
    return widget.outerBuilder != null
        ? widget.outerBuilder!(container)
        : SizedBox(
            height: widget.height,
            child: Center(child: container),
          );
  }
}

/// The most common loading footer, combining text and an icon.
///
/// See also:
///
/// [ClassicHeader], the header version of this indicator.
class ClassicFooter extends LoadIndicator {
  /// Custom text for different loading states.
  final String? idleText, loadingText, noDataText, failedText, canLoadingText;

  /// A builder for re-wrapping the child. Use this to change background, padding, etc.
  ///
  /// Example:
  /// ```dart
  /// outerBuilder: (child) {
  ///    return Container(
  ///       color: Colors.red,
  ///       child: child,
  ///    );
  /// }
  /// ```
  final OuterBuilder? outerBuilder;

  /// Custom icons for different loading states.
  final Widget? idleIcon, loadingIcon, noMoreIcon, failedIcon, canLoadingIcon;

  /// The margin between the icon and the text.
  final double spacing;

  /// The position of the icon relative to the text.
  final IconPosition iconPos;

  /// The style of the text in the indicator.
  final TextStyle textStyle;

  /// The duration the "complete" state is displayed. Only works for [LoadStyle.ShowWhenLoading].
  final Duration completeDuration;

  /// Creates a [ClassicFooter].
  const ClassicFooter({
    super.key,
    super.onClick,
    super.loadStyle,
    super.height,
    this.outerBuilder,
    this.textStyle = const TextStyle(color: Colors.grey),
    this.loadingText,
    this.noDataText,
    this.noMoreIcon,
    this.idleText,
    this.failedText,
    this.canLoadingText,
    this.failedIcon = const Icon(Icons.error, color: Colors.grey),
    this.iconPos = IconPosition.left,
    this.spacing = 15.0,
    this.completeDuration = const Duration(milliseconds: 300),
    this.loadingIcon,
    this.canLoadingIcon = const Icon(Icons.autorenew, color: Colors.grey),
    this.idleIcon = const Icon(Icons.arrow_upward, color: Colors.grey),
  });

  @override
  State<StatefulWidget> createState() {
    return _ClassicFooterState();
  }
}

class _ClassicFooterState extends LoadIndicatorState<ClassicFooter> {
  Widget _buildText(LoadStatus? mode) {
    final RefreshString strings =
        RefreshLocalizations.of(context)?.currentLocalization ??
            EnRefreshString();
    return Text(
        mode == LoadStatus.loading
            ? widget.loadingText ?? strings.loadingText!
            : LoadStatus.noMore == mode
                ? widget.noDataText ?? strings.noMoreText!
                : LoadStatus.failed == mode
                    ? widget.failedText ?? strings.loadFailedText!
                    : LoadStatus.canLoading == mode
                        ? widget.canLoadingText ?? strings.canLoadingText!
                        : widget.idleText ?? strings.idleLoadingText!,
        style: widget.textStyle);
  }

  Widget _buildIcon(LoadStatus? mode) {
    final Widget? icon = mode == LoadStatus.loading
        ? widget.loadingIcon ??
            SizedBox(
              width: 25.0,
              height: 25.0,
              child: defaultTargetPlatform == TargetPlatform.iOS
                  ? const CupertinoActivityIndicator()
                  : const CircularProgressIndicator(strokeWidth: 2.0),
            )
        : mode == LoadStatus.noMore
            ? widget.noMoreIcon
            : mode == LoadStatus.failed
                ? widget.failedIcon
                : mode == LoadStatus.canLoading
                    ? widget.canLoadingIcon
                    : widget.idleIcon;
    return icon ?? Container();
  }

  @override
  Future<void> endLoading() {
    return Future.delayed(widget.completeDuration);
  }

  @override
  Widget buildContent(BuildContext context, LoadStatus? mode) {
    final Widget textWidget = _buildText(mode);
    final Widget iconWidget = _buildIcon(mode);
    final List<Widget> children = <Widget>[iconWidget, textWidget];
    final Widget container = Wrap(
      spacing: widget.spacing,
      textDirection: widget.iconPos == IconPosition.left
          ? TextDirection.ltr
          : TextDirection.rtl,
      direction: widget.iconPos == IconPosition.bottom ||
              widget.iconPos == IconPosition.top
          ? Axis.vertical
          : Axis.horizontal,
      crossAxisAlignment: WrapCrossAlignment.center,
      verticalDirection: widget.iconPos == IconPosition.bottom
          ? VerticalDirection.up
          : VerticalDirection.down,
      alignment: WrapAlignment.center,
      children: children,
    );
    return widget.outerBuilder != null
        ? widget.outerBuilder!(container)
        : SizedBox(
            height: widget.height,
            child: Center(
              child: container,
            ),
          );
  }
}
