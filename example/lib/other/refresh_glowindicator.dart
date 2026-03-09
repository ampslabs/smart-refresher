/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-09-08 14:44
 */

import 'package:flutter/material.dart';

// 在不自定义的默认情况下,当你拖到顶端不能再拖的时候会出现光晕,假如你只想在撞击顶部时看到光晕的情况
// 以下例子就是可以解决这种问题

// Android平台 自定义刷新光晕效果
class RefreshScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    switch (getPlatform(context)) {
      case TargetPlatform.iOS:
        return child;
      case TargetPlatform.macOS:
      case TargetPlatform.android:
        return GlowingOverscrollIndicator(
          showLeading: true,
          showTrailing: true,
          axisDirection: details.direction,
          notificationPredicate: (notification) {
            if (notification.depth == 0) {
              if (notification.metrics.outOfRange) {
                return false;
              }
              return true;
            }
            return false;
          },
          color: Theme.of(context).primaryColor,
          child: child,
        );
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
    }
    return child;
  }
}
