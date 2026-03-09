/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time:  2019-05-26 23:09
 */

import 'package:smart_refresher/smart_refresher.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;

class RunningHeader extends RefreshIndicator {
  const RunningHeader({super.key});

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return RunningHeaderState();
  }
}

class RunningHeaderState extends RefreshIndicatorState<RunningHeader>
    with TickerProviderStateMixin {
  late AnimationController _scaleAnimation;
  late AnimationController _offsetController;
  late Tween<Offset> offsetTween;

  @override
  void initState() {
    // TODO: implement initState
    _scaleAnimation = AnimationController(vsync: this);
    _offsetController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    offsetTween = Tween(end: Offset(0.6, 0.0), begin: Offset(0.0, 0.0));
    super.initState();
  }

  @override
  void onOffsetChange(double offset) {
    // TODO: implement onOffsetChange
    if (!floating) {
      _scaleAnimation.value = offset / 80.0;
    }
    super.onOffsetChange(offset);
  }

  @override
  void resetValue() {
    // TODO: implement handleModeChange
    _scaleAnimation.value = 0.0;
    _offsetController.value = 0.0;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scaleAnimation.dispose();
    _offsetController.dispose();
    super.dispose();
  }

  @override
  Future<void> endRefresh() {
    // TODO: implement endRefresh
    return _offsetController.animateTo(1.0).whenComplete(() {});
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus mode) {
    // TODO: implement buildContent
    return SlideTransition(
      position: offsetTween.animate(_offsetController),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: (mode != RefreshStatus.idle || mode != RefreshStatus.canRefresh)
            ? Image.asset("images/custom_2.gif")
            : Image.asset("images/custom_1.jpg"),
      ),
    );
  }
}
