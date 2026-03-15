import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import 'package:smart_refresher/src/smart_refresher.dart';
import 'package:smart_refresher/src/indicator/classic_indicator.dart';
import 'package:smart_refresher/src/indicator/material_indicator.dart';
import 'package:smart_refresher/src/internals/indicator_wrap.dart';
import 'package:smart_refresher/src/internals/refresh_physics.dart';
import 'package:smart_refresher/src/internals/slivers.dart';

/// Mixin for composing slivers in [SmartRefresherState].
mixin RefresherSliverComposer on State<SmartRefresher> {
  /// The default header indicator based on platform.
  final RefreshIndicator defaultHeader =
      defaultTargetPlatform == TargetPlatform.iOS
          ? const ClassicHeader()
          : const MaterialClassicHeader();

  /// The default footer indicator.
  final LoadIndicator defaultFooter = const ClassicFooter();

  /// Builds the list of slivers for the refresher.
  List<Widget>? buildSliversByChild(BuildContext context, Widget? child,
      RefreshConfiguration? configuration) {
    List<Widget>? slivers;
    if (widget.slivers != null) {
      slivers = List<Widget>.from(widget.slivers!);
    } else if (child is ScrollView) {
      if (child is BoxScrollView) {
        // ignore: INVALID_USE_OF_PROTECTED_MEMBER
        final Widget sliver = child.buildChildLayout(context);
        if (child.padding != null) {
          slivers = [SliverPadding(sliver: sliver, padding: child.padding!)];
        } else {
          slivers = [sliver];
        }
      } else {
        // ignore: INVALID_USE_OF_PROTECTED_MEMBER
        slivers = List<Widget>.from(child.buildSlivers(context));
      }
    } else if (child is! Scrollable) {
      slivers = [
        SliverRefreshBody(
          child: child ?? Container(),
        )
      ];
    }
    if (widget.enablePullDown || widget.enableTwoLevel) {
      final Widget header = widget.header ??
          (configuration?.headerBuilder != null
              ? configuration?.headerBuilder!()
              : null) ??
          defaultHeader;
      if (slivers != null && !slivers.contains(header)) {
        slivers.insert(0, header);
      } else {
        slivers ??= [header];
      }
    }
    if (widget.enablePullUp) {
      final Widget footer = widget.footer ??
          (configuration?.footerBuilder != null
              ? configuration?.footerBuilder!()
              : null) ??
          defaultFooter;
      if (slivers != null && !slivers.contains(footer)) {
        slivers.add(footer);
      } else {
        slivers ??= [footer];
      }
    }

    return slivers;
  }

  /// Builds the body of the refresher using slivers.
  Widget? buildBodyBySlivers(
      Widget? childView,
      List<Widget>? slivers,
      RefreshConfiguration? conf,
      ScrollPhysics Function(RefreshConfiguration? conf, ScrollPhysics physics)
          getRefresherPhysics) {
    Widget? body;
    if (childView is! Scrollable) {
      bool? primary = widget.primary;
      Key? key;
      double? cacheExtent = widget.cacheExtent;

      Axis? scrollDirection = widget.scrollDirection;
      int? semanticChildCount = widget.semanticChildCount;
      bool? reverse = widget.reverse;
      ScrollController? scrollController = widget.scrollController;
      DragStartBehavior? dragStartBehavior = widget.dragStartBehavior;
      ScrollPhysics? physics = widget.physics;
      Key? center;
      double? anchor;
      ScrollViewKeyboardDismissBehavior? keyboardDismissBehavior;
      String? restorationId;
      Clip? clipBehavior;

      if (childView is ScrollView) {
        primary = primary ?? childView.primary;
        cacheExtent = cacheExtent ?? childView.cacheExtent;
        key = key ?? childView.key;
        semanticChildCount = semanticChildCount ?? childView.semanticChildCount;
        reverse = reverse ?? childView.reverse;
        dragStartBehavior = dragStartBehavior ?? childView.dragStartBehavior;
        scrollDirection = scrollDirection ?? childView.scrollDirection;
        physics = physics ?? childView.physics;
        center = center ?? childView.center;
        anchor = anchor ?? childView.anchor;
        keyboardDismissBehavior =
            keyboardDismissBehavior ?? childView.keyboardDismissBehavior;
        restorationId = restorationId ?? childView.restorationId;
        clipBehavior = clipBehavior ?? childView.clipBehavior;
        scrollController = scrollController ?? childView.controller;
      }
      body = CustomScrollView(
        controller: scrollController,
        cacheExtent: cacheExtent,
        key: key,
        scrollDirection: scrollDirection ?? Axis.vertical,
        semanticChildCount: semanticChildCount,
        primary: primary,
        clipBehavior: clipBehavior ?? Clip.hardEdge,
        keyboardDismissBehavior:
            keyboardDismissBehavior ?? ScrollViewKeyboardDismissBehavior.manual,
        anchor: anchor ?? 0.0,
        restorationId: restorationId,
        center: widget.center ?? center,
        physics: getRefresherPhysics(
            conf, physics ?? const AlwaysScrollableScrollPhysics()),
        slivers: slivers!,
        dragStartBehavior: dragStartBehavior ?? DragStartBehavior.start,
        reverse: reverse ?? false,
      );
    } else {
      body = Scrollable(
        physics: getRefresherPhysics(
            conf, childView.physics ?? const AlwaysScrollableScrollPhysics()),
        controller: childView.controller,
        axisDirection: childView.axisDirection,
        semanticChildCount: childView.semanticChildCount,
        dragStartBehavior: childView.dragStartBehavior,
        viewportBuilder: (context, offset) {
          final Viewport viewport =
              childView.viewportBuilder(context, offset) as Viewport;
          if (widget.enablePullDown) {
            final Widget header = widget.header ??
                (conf?.headerBuilder != null ? conf?.headerBuilder!() : null) ??
                defaultHeader;
            viewport.children.insert(0, header);
          }
          if (widget.enablePullUp) {
            final Widget footer = widget.footer ??
                (conf?.footerBuilder != null ? conf?.footerBuilder!() : null) ??
                defaultFooter;
            viewport.children.add(footer);
          }
          return viewport;
        },
      );
    }

    return body;
  }
}

/// Mixin for managing [RefreshPhysics] in [SmartRefresherState].
mixin RefresherPhysicsMixin on State<SmartRefresher> {
  RefreshPhysics? _physics;
  bool _updatePhysics = false;

  /// Whether the physics should be updated.
  bool get shouldUpdatePhysics => _updatePhysics;

  /// Toggles the physics update flag.
  void toggleUpdatePhysics() {
    setState(() {
      _updatePhysics = !_updatePhysics;
    });
  }

  /// Checks if the physics need to be updated based on the configuration.
  bool checkIfNeedUpdatePhysics(BuildContext context) {
    final RefreshConfiguration? conf = RefreshConfiguration.of(context);
    if (conf == null || _physics == null) {
      return false;
    }

    if (conf.topHitBoundary != _physics!.topHitBoundary ||
        _physics!.bottomHitBoundary != conf.bottomHitBoundary ||
        conf.maxOverScrollExtent != _physics!.maxOverScrollExtent ||
        _physics!.maxUnderScrollExtent != conf.maxUnderScrollExtent ||
        _physics!.dragSpeedRatio != conf.dragSpeedRatio ||
        _physics!.enableScrollWhenTwoLevel != conf.enableScrollWhenTwoLevel ||
        _physics!.enableScrollWhenRefreshCompleted !=
            conf.enableScrollWhenRefreshCompleted) {
      return true;
    }
    return false;
  }

  /// Gets the [RefreshPhysics] for the refresher.
  ScrollPhysics getRefresherPhysics(
      RefreshConfiguration? conf, ScrollPhysics physics, bool canDrag) {
    final bool isBouncingPhysics = physics is BouncingScrollPhysics ||
        (physics is AlwaysScrollableScrollPhysics &&
            ScrollConfiguration.of(context)
                    .getScrollPhysics(context)
                    .runtimeType ==
                BouncingScrollPhysics);
    return _physics = RefreshPhysics(
            dragSpeedRatio: conf?.dragSpeedRatio ?? 1,
            springDescription: conf?.springDescription ??
                const SpringDescription(
                  mass: 2.2,
                  stiffness: 150,
                  damping: 16,
                ),
            controller: widget.controller,
            enableScrollWhenTwoLevel: conf?.enableScrollWhenTwoLevel ?? true,
            updateFlag: _updatePhysics ? 0 : 1,
            enableScrollWhenRefreshCompleted:
                conf?.enableScrollWhenRefreshCompleted ?? false,
            enablePullDown: widget.enablePullDown || widget.enableTwoLevel,
            enablePullUp: widget.enablePullUp,
            maxUnderScrollExtent: conf?.maxUnderScrollExtent ??
                (isBouncingPhysics ? double.infinity : 100.0),
            maxOverScrollExtent: conf?.maxOverScrollExtent ??
                (isBouncingPhysics ? double.infinity : 100.0),
            topHitBoundary: conf?.topHitBoundary ??
                (isBouncingPhysics ? double.infinity : 0.0),
            bottomHitBoundary: conf?.bottomHitBoundary ??
                (isBouncingPhysics ? double.infinity : 0.0))
        .applyTo(!canDrag ? const NeverScrollableScrollPhysics() : physics);
  }
}

/// Mixin for handling drag state in [SmartRefresherState].
mixin RefresherDragHandler on State<SmartRefresher> {
  bool _canDrag = true;

  /// Whether the user can currently drag the refresher.
  bool get canDrag => _canDrag;

  /// Enables or disables dragging.
  void setCanDrag(bool value) {
    if (_canDrag == value) {
      return;
    }
    setState(() {
      _canDrag = value;
    });
  }
}
