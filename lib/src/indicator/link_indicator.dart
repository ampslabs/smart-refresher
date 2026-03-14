/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-06-26 1:17 PM
*/
import 'package:smart_refresher/smart_refresher.dart';
import 'package:flutter/widgets.dart';

/// A header that links to another header placed outside the viewport.
///
/// This is useful when you want to trigger refresh behavior from a different part of the UI.
class LinkHeader extends RefreshIndicator {
  /// The key of the linked header widget located outside the viewport.
  final Key linkKey;

  /// Creates a [LinkHeader].
  const LinkHeader(
      {super.key,
      required this.linkKey,
      super.height = 0.0,
      super.refreshStyle,
      super.completeDuration = const Duration(milliseconds: 200)});

  @override
  State<StatefulWidget> createState() {
    return _LinkHeaderState();
  }
}

class _LinkHeaderState extends RefreshIndicatorState<LinkHeader> {
  @override
  void resetValue() {
    ((widget.linkKey as GlobalKey).currentState! as RefreshProcessor)
        .resetValue();
  }

  @override
  Future<void> endRefresh() {
    return ((widget.linkKey as GlobalKey).currentState! as RefreshProcessor)
        .endRefresh();
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    ((widget.linkKey as GlobalKey).currentState! as RefreshProcessor)
        .onModeChange(mode);
  }

  @override
  void onOffsetChange(double offset) {
    ((widget.linkKey as GlobalKey).currentState! as RefreshProcessor)
        .onOffsetChange(offset);
  }

  @override
  Future<void> readyToRefresh() {
    return ((widget.linkKey as GlobalKey).currentState! as RefreshProcessor)
        .readyToRefresh();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    return Container();
  }
}

/// A footer that links to another footer placed outside the viewport.
///
/// This is useful when you want to trigger loading behavior from a different part of the UI.
class LinkFooter extends LoadIndicator {
  /// The key of the linked footer widget located outside the viewport.
  final Key linkKey;

  /// Creates a [LinkFooter].
  const LinkFooter(
      {super.key,
      required this.linkKey,
      super.height = 0.0,
      super.loadStyle = LoadStyle.showAlways});

  @override
  State<StatefulWidget> createState() {
    return _LinkFooterState();
  }
}

class _LinkFooterState extends LoadIndicatorState<LinkFooter> {
  @override
  void onModeChange(LoadStatus? mode) {
    ((widget.linkKey as GlobalKey).currentState! as LoadingProcessor)
        .onModeChange(mode);
  }

  @override
  void onOffsetChange(double offset) {
    ((widget.linkKey as GlobalKey).currentState! as LoadingProcessor)
        .onOffsetChange(offset);
  }

  @override
  Widget buildContent(BuildContext context, LoadStatus? mode) {
    return Container();
  }
}
