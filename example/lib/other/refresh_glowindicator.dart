/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-09-08 14:44
 */

import 'package:flutter/material.dart';

// By default, without customization, a glow appears when you drag to the top and cannot drag any further.
// If you only want to see the glow when hitting the top:
// The following example can solve this problem.

// Android platform custom refresh glow effect
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
