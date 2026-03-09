/*
 * Author: Jpeng
 * Email: peng8350@gmail.com
 * Time: 2019/5/19 9:23 PM
 */

import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;
import '../internals/indicator_wrap.dart';
import '../smart_refresher.dart';

// How much the scroll's drag gesture can overshoot the RefreshIndicator's
// displacement; max displacement = _kDragSizeFactorLimit * displacement.
const double _kDragSizeFactorLimit = 1.5;

/// A refresh header that uses Flutter's material [RefreshProgressIndicator].
class MaterialClassicHeader extends RefreshIndicator {
  /// The semantic label for the refresh indicator.
  ///
  /// See [RefreshProgressIndicator.semanticsLabel].
  final String? semanticsLabel;

  /// The semantic value for the refresh indicator.
  ///
  /// See [RefreshProgressIndicator.semanticsValue].
  final String? semanticsValue;

  /// The progress indicator's color.
  ///
  /// See [RefreshProgressIndicator.valueColor].
  final Color? color;

  /// The distance from the top where the indicator rests while refreshing.
  final double distance;

  /// The background color of the progress indicator.
  ///
  /// See [RefreshProgressIndicator.backgroundColor].
  final Color? backgroundColor;

  /// Creates a [MaterialClassicHeader].
  const MaterialClassicHeader({
    super.key,
    super.height = 80.0,
    this.semanticsLabel,
    this.semanticsValue,
    this.color,
    super.offset,
    this.distance = 50.0,
    this.backgroundColor,
  }) : super(
          refreshStyle: RefreshStyle.Front,
        );

  @override
  State<StatefulWidget> createState() {
    return _MaterialClassicHeaderState();
  }
}

class _MaterialClassicHeaderState
    extends RefreshIndicatorState<MaterialClassicHeader>
    with TickerProviderStateMixin {
  ScrollPosition? _position;
  Animation<Offset>? _positionFactor;
  Animation<Color?>? _valueColor;
  late AnimationController _scaleFactor;
  late AnimationController _positionController;
  late AnimationController _valueAni;

  @override
  void initState() {
    _valueAni = AnimationController(
        vsync: this,
        value: 0.0,
        duration: const Duration(milliseconds: 500));
    _valueAni.addListener(() {
      // frequently setState will decline the performance
      if (mounted && _position!.pixels <= 0) setState(() {});
    });
    _positionController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _scaleFactor = AnimationController(
        vsync: this,
        value: 1.0,
        duration: const Duration(milliseconds: 300));
    _positionFactor = _positionController.drive(Tween<Offset>(
        begin: const Offset(0.0, -1.0), end: Offset(0.0, widget.height / 44.0)));
    super.initState();
  }

  @override
  void didUpdateWidget(covariant MaterialClassicHeader oldWidget) {
    _position = Scrollable.of(context).position;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    return _buildIndicator(widget.backgroundColor ?? Colors.white);
  }

  Widget _buildIndicator(Color outerColor) {
    return SlideTransition(
      position: _positionFactor!,
      child: ScaleTransition(
        scale: _scaleFactor,
        child: Align(
          alignment: Alignment.topCenter,
          child: RefreshProgressIndicator(
            semanticsLabel: widget.semanticsLabel ??
                MaterialLocalizations.of(context)
                    .refreshIndicatorSemanticLabel,
            semanticsValue: widget.semanticsValue,
            value: floating ? null : _valueAni.value,
            valueColor: _valueColor,
            backgroundColor: outerColor,
          ),
        ),
      ),
    );
  }

  @override
  void onOffsetChange(double offset) {
    if (!floating) {
      _valueAni.value = offset / configuration!.headerTriggerDistance;
      _positionController.value = offset / configuration!.headerTriggerDistance;
    }
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    if (mode == RefreshStatus.refreshing) {
      _positionController.value = widget.distance / widget.height;
      _scaleFactor.value = 1;
    }
    super.onModeChange(mode);
  }

  @override
  void resetValue() {
    _scaleFactor.value = 1.0;
    _positionController.value = 0.0;
    _valueAni.value = 0.0;
    super.resetValue();
  }

  @override
  void didChangeDependencies() {
    final ThemeData theme = Theme.of(context);
    _position = Scrollable.of(context).position;
    _valueColor = _positionController.drive(
      ColorTween(
        begin: (widget.color ?? theme.primaryColor).withAlpha(0),
        end: (widget.color ?? theme.primaryColor).withAlpha(255),
      ).chain(
          CurveTween(curve: const Interval(0.0, 1.0 / _kDragSizeFactorLimit))),
    );
    super.didChangeDependencies();
  }

  @override
  Future<void> readyToRefresh() {
    return _positionController.animateTo(widget.distance / widget.height);
  }

  @override
  Future<void> endRefresh() {
    return _scaleFactor.animateTo(0.0);
  }

  @override
  void dispose() {
    _valueAni.dispose();
    _scaleFactor.dispose();
    _positionController.dispose();
    super.dispose();
  }
}

/// A refresh header that adds a waterdrop effect to [MaterialClassicHeader].
class WaterDropMaterialHeader extends MaterialClassicHeader {
  /// Creates a [WaterDropMaterialHeader].
  const WaterDropMaterialHeader({
    super.key,
    super.semanticsLabel,
    super.distance = 60.0,
    super.offset,
    super.semanticsValue,
    Color super.color = Colors.white,
    super.backgroundColor,
  }) : super(
            height: 80.0);

  @override
  State<StatefulWidget> createState() {
    return _WaterDropMaterialHeaderState();
  }
}

class _WaterDropMaterialHeaderState extends _MaterialClassicHeaderState {
  AnimationController? _bezierController;
  bool _showWater = false;

  @override
  void initState() {
    super.initState();
    _bezierController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
        upperBound: 1.5,
        value: 0.0);
    _positionController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 300),
        value: 0.0);
    _positionFactor = _positionController
        .drive(Tween<Offset>(begin: const Offset(0.0, -0.5), end: const Offset(0.0, 1.5)));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final ThemeData theme = Theme.of(context);
    _valueColor = _positionController.drive(
      ColorTween(
        begin: (widget.color ?? theme.primaryColor).withAlpha(0),
        end: (widget.color ?? theme.primaryColor).withAlpha(255),
      ).chain(
          CurveTween(curve: const Interval(0.0, 1.0 / _kDragSizeFactorLimit))),
    );
  }

  @override
  Future<void> readyToRefresh() {
    _bezierController!.value = 1.01;
    _showWater = true;
    _bezierController!.animateTo(1.5,
        curve: Curves.bounceOut, duration: const Duration(milliseconds: 550));
    return _positionController
        .animateTo(widget.distance / widget.height,
            curve: Curves.bounceOut, duration: const Duration(milliseconds: 550))
        .then((_) {
      _showWater = false;
    });
  }

  @override
  Future<void> endRefresh() {
    _showWater = false;
    return super.endRefresh();
  }

  @override
  void resetValue() {
    _bezierController!.reset();
    super.resetValue();
  }

  @override
  void dispose() {
    _bezierController!.dispose();
    super.dispose();
  }

  @override
  void onOffsetChange(double offset) {
    offset = offset > 80.0 ? 80.0 : offset;

    if (!floating) {
      _bezierController!.value =
          offset / configuration!.headerTriggerDistance;
      _valueAni.value = _bezierController!.value;
      _positionController.value = _bezierController!.value * 0.3;
      _scaleFactor.value =
          offset < 40.0 ? 0.0 : (_bezierController!.value - 0.5) * 2 + 0.5;
    }
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    return SizedBox(
      height: 100.0,
      child: Stack(
        children: <Widget>[
          CustomPaint(
            painter: _BezierPainter(
                listener: _bezierController,
                color:
                    widget.backgroundColor ?? Theme.of(context).primaryColor),
            child: Container(),
          ),
          CustomPaint(
            painter: _showWater
                ? _WaterPainter(
                    ratio: widget.distance / widget.height,
                    color: widget.backgroundColor ??
                        Theme.of(context).primaryColor,
                    listener: _positionFactor)
                : null,
            child: _buildIndicator(
                widget.backgroundColor ?? Theme.of(context).primaryColor),
          )
        ],
      ),
    );
  }
}

class _WaterPainter extends CustomPainter {
  final Color? color;
  final Animation<Offset>? listener;

  Offset get offset => listener!.value;
  final double? ratio;

  _WaterPainter({this.color, this.listener, this.ratio})
      : super(repaint: listener);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    paint.color = color!;
    final Path path = Path();
    path.moveTo(size.width / 2 - 20.0, offset.dy * 100.0 + 20.0);
    path.conicTo(
        size.width / 2,
        offset.dy * 100.0 - 70.0 * (ratio! - offset.dy),
        size.width / 2 + 20.0,
        offset.dy * 100.0 + 20.0,
        10.0 * (ratio! - offset.dy));
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_WaterPainter oldDelegate) {
    return this != oldDelegate || offset != oldDelegate.offset;
  }
}

class _BezierPainter extends CustomPainter {
  final AnimationController? listener;
  final Color? color;

  double get value => listener!.value;

  _BezierPainter({this.listener, this.color}) : super(repaint: listener);

  @override
  void paint(Canvas canvas, Size size) {
    final double middleX = size.width / 2;
    final Paint paint = Paint();
    paint.color = color!;
    if (value < 0.5) {
      final Path path = Path();
      path.moveTo(0.0, 0.0);
      path.quadraticBezierTo(middleX, 70.0 * value, size.width, 0.0);
      canvas.drawPath(path, paint);
    } else if (value <= 1.0) {
      final Path path = Path();
      final double offsetY = 60.0 * (value - 0.5) + 20.0;
      path.moveTo(0.0, 0.0);
      path.quadraticBezierTo(middleX + 40.0 * (value - 0.5),
          40.0 - 40.0 * value, middleX - 10.0, offsetY);
      path.lineTo(middleX + 10.0, offsetY);
      path.quadraticBezierTo(
          middleX - 40.0 * (value - 0.5), 40.0 - 40.0 * value, size.width, 0.0);
      path.moveTo(size.width, 0.0);
      path.lineTo(0.0, 0.0);
      canvas.drawPath(path, paint);
    } else {
      final Path path = Path();
      path.moveTo(0.0, 0.0);
      path.conicTo(middleX, 60.0 * (1.5 - value), size.width, 0.0, 5.0);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_BezierPainter oldDelegate) {
    return this != oldDelegate || oldDelegate.value != value;
  }
}
