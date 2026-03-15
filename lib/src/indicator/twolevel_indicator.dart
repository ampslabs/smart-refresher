/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-08-29 09:41
 */

import 'package:flutter/material.dart';
import 'package:smart_refresher/src/indicator/classic_indicator.dart';
import 'package:smart_refresher/src/smart_refresher.dart';

/// Alignment for displaying content within the two-level header.
enum TwoLevelDisplayAlignment {
  /// Align content from the top.
  fromTop,

  /// Align content from the center.
  fromCenter,

  /// Align content from the bottom.
  fromBottom
}

/// A refresh header that facilitates the implementation of a "two-level" refresh effect.
///
/// This behavior is similar to the "second floor" effect seen in apps like TaoBao or Ctrip.
///
/// Example:
/// ```dart
/// TwoLevelHeader(
///   textStyle: TextStyle(color: Colors.white),
///   displayAlignment: TwoLevelDisplayAlignment.fromTop,
///   decoration: BoxDecoration(
///     image: DecorationImage(
///       image: AssetImage("images/secondfloor.jpg"),
///       fit: BoxFit.cover,
///       // Very important attribute, this will affect the animation effect of opening and closing the second floor
///       alignment: Alignment.topCenter),
///   ),
///   twoLevelWidget: Container(
///     decoration: BoxDecoration(
///       image: DecorationImage(
///         image: AssetImage("images/secondfloor.jpg"),
///         // Very important attribute, this will affect the animation effect of opening and closing the second floor, related to TwoLevelHeader. If the background is consistent, please set it to be the same.
///         alignment: Alignment.topCenter,
///         fit: BoxFit.cover),
///     ),
///     child: Container(
///       height: 60.0,
///       child: GestureDetector(
///         child: Icon(
///           Icons.arrow_back_ios,
///           color: Colors.white,
///         ),
///         onTap: () {
///           SmartRefresher.of(context).controller.twoLevelComplete();
///         },
///       ),
///       alignment: Alignment.bottomLeft,
///     ),
///   ),
/// );
/// ```
class TwoLevelHeader extends StatelessWidget {
  /// The decoration for the header, typically used for background color or image.
  final BoxDecoration? decoration;

  /// The widget to display when the header is in a two-level state (opening, closing, or active).
  final Widget? twoLevelWidget;

  /// The alignment of the header content.
  ///
  /// Use [TwoLevelDisplayAlignment.fromTop] with [RefreshStyle.behind] and
  /// [TwoLevelDisplayAlignment.fromBottom] with [RefreshStyle.follow].
  final TwoLevelDisplayAlignment displayAlignment;

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
      canTwoLevelIcon;

  /// The margin between the icon and the text.
  final double spacing;

  /// The position of the icon relative to the text.
  final IconPosition iconPos;

  /// The style of the text in the indicator.
  final TextStyle textStyle;

  /// The height of the header.
  final double height;

  /// The duration the "complete" state is displayed.
  final Duration completeDuration;

  /// Creates a [TwoLevelHeader].
  const TwoLevelHeader(
      {super.key,
      this.height = 80.0,
      this.decoration,
      this.displayAlignment = TwoLevelDisplayAlignment.fromBottom,
      this.completeDuration = SmartRefresherConstants.defaultCompleteDuration,
      this.textStyle = const TextStyle(color: Color(0xff555555)),
      this.releaseText,
      this.refreshingText,
      this.canTwoLevelIcon,
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
      this.twoLevelWidget});

  @override
  Widget build(BuildContext context) {
    return ClassicHeader(
      refreshStyle: displayAlignment == TwoLevelDisplayAlignment.fromBottom
          ? RefreshStyle.follow
          : RefreshStyle.behind,
      height: height,
      refreshingIcon: refreshingIcon,
      refreshingText: refreshingText,
      releaseIcon: releaseIcon,
      releaseText: releaseText,
      completeDuration: completeDuration,
      canTwoLevelIcon: canTwoLevelIcon,
      canTwoLevelText: canTwoLevelText,
      failedIcon: failedIcon,
      failedText: failedText,
      idleIcon: idleIcon,
      idleText: idleText,
      completeIcon: completeIcon,
      completeText: completeText,
      spacing: spacing,
      textStyle: textStyle,
      iconPos: iconPos,
      outerBuilder: (child) {
        final RefreshStatus? mode =
            SmartRefresher.of(context)!.controller.headerStatus;
        final bool isTwoLevel = mode == RefreshStatus.twoLevelClosing ||
            mode == RefreshStatus.twoLeveling ||
            mode == RefreshStatus.twoLevelOpening;
        if (displayAlignment == TwoLevelDisplayAlignment.fromBottom) {
          return Container(
            decoration: !isTwoLevel
                ? (decoration ?? const BoxDecoration(color: Colors.redAccent))
                : null,
            height: SmartRefresher.ofState(context)!.viewportExtent,
            alignment: isTwoLevel ? null : Alignment.bottomCenter,
            child: isTwoLevel
                ? twoLevelWidget
                : Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: child,
                  ),
          );
        } else {
          return Container(
            child: isTwoLevel
                ? twoLevelWidget
                : Container(
                    decoration: !isTwoLevel
                        ? (decoration ??
                            const BoxDecoration(color: Colors.redAccent))
                        : null,
                    alignment: Alignment.bottomCenter,
                    padding: const EdgeInsets.only(bottom: 15),
                    child: child,
                  ),
          );
        }
      },
    );
  }
}
