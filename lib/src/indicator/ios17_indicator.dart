// ignore_for_file: camel_case_types, public_member_api_docs

import 'dart:math' as math;
import 'dart:ui' as ui show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../internals/indicator_wrap.dart';
import '../smart_refresher.dart';

const int _kTickCount = 12;
const double _kTwoPi = math.pi * 2.0;

String _defaultLastUpdatedText(DateTime updatedAt, DateTime now) {
  final Duration difference = now.difference(updatedAt);
  if (difference.inMinutes <= 0) {
    return 'Updated just now';
  }
  if (difference.inMinutes == 1) {
    return 'Updated 1 min ago';
  }
  return 'Updated ${difference.inMinutes} min ago';
}

class IOS17ActivityIndicator extends StatelessWidget {
  const IOS17ActivityIndicator({
    super.key,
    required this.color,
    required this.radius,
    required this.progress,
    this.rotationValue = 0.0,
    this.gradientOpacity = 1.0,
  });

  final Color color;
  final double radius;
  final double progress;
  final double rotationValue;
  final double gradientOpacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: radius * 2.0,
      height: radius * 2.0,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _ActivityIndicatorPainter(
            color: color,
            progress: progress,
            rotationValue: rotationValue,
            gradientOpacity: gradientOpacity,
          ),
        ),
      ),
    );
  }
}

/// A Cupertino-inspired pull-to-refresh header matching iOS 17 styling.
class iOS17Header extends RefreshIndicator {
  const iOS17Header({
    super.key,
    this.color,
    this.radius = 10.0,
    this.showLastUpdated = false,
    this.lastUpdatedTextBuilder,
    this.enableHaptic = true,
    super.height = 60.0,
    super.completeDuration = const Duration(milliseconds: 300),
    super.refreshStyle = RefreshStyle.Follow,
  });

  final Color? color;
  final bool showLastUpdated;
  final String Function(DateTime updatedAt)? lastUpdatedTextBuilder;
  final double radius;
  final bool enableHaptic;

  @override
  State<StatefulWidget> createState() => iOS17HeaderState();
}

class iOS17HeaderState extends RefreshIndicatorState<iOS17Header>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;
  late final AnimationController _opacityController;
  late final AnimationController _dismissController;

  double _progress = 0.0;
  bool _didFireHaptic = false;
  DateTime? _lastUpdatedAt;

  Color get _resolvedColor =>
      widget.color ??
      CupertinoDynamicColor.resolve(CupertinoColors.systemFill, context);

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>(<TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.0,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60.0,
      ),
    ]).animate(_scaleController);
    _opacityController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _opacityController.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  @override
  bool needReverseAll() => false;

  @override
  void onOffsetChange(double offset) {
    final double triggerDistance = configuration?.headerTriggerDistance ?? 60.0;
    final double nextProgress = (offset / triggerDistance).clamp(0.0, 1.0);
    final bool crossedThreshold = _progress < 1.0 && nextProgress >= 1.0;
    _progress = nextProgress;

    if (crossedThreshold && !_scaleController.isAnimating) {
      _scaleController.forward(from: 0.0);
    }

    if (mounted) {
      setState(() {});
    }
    super.onOffsetChange(offset);
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    switch (mode) {
      case RefreshStatus.idle:
        _rotationController.stop();
        _rotationController.reset();
        _scaleController.reset();
        _opacityController.reset();
        _dismissController.reset();
        _progress = 0.0;
        _didFireHaptic = false;
        break;
      case RefreshStatus.refreshing:
        if (widget.enableHaptic &&
            defaultTargetPlatform == TargetPlatform.iOS &&
            !_didFireHaptic) {
          HapticFeedback.mediumImpact();
          _didFireHaptic = true;
        }
        if (!_scaleController.isAnimating && _progress >= 1.0) {
          _scaleController.forward(from: 0.0);
        }
        _dismissController.reset();
        _opacityController.forward(from: 0.0);
        if (!_rotationController.isAnimating) {
          _rotationController.repeat();
        }
        _progress = 1.0;
        break;
      case RefreshStatus.completed:
        _rotationController.stop();
        _lastUpdatedAt = DateTime.now();
        break;
      case RefreshStatus.failed:
        _rotationController.stop();
        break;
      case RefreshStatus.canRefresh:
      case RefreshStatus.canTwoLevel:
      case RefreshStatus.twoLevelOpening:
      case RefreshStatus.twoLeveling:
      case RefreshStatus.twoLevelClosing:
      case null:
        break;
    }

    if (mounted) {
      setState(() {});
    }
    super.onModeChange(mode);
  }

  @override
  Future<void> endRefresh() {
    return _dismissController.forward(from: 0.0);
  }

  @override
  void resetValue() {
    _progress = 0.0;
    _dismissController.reset();
    _opacityController.reset();
    _scaleController.reset();
    super.resetValue();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    final double indicatorOpacity = mode == RefreshStatus.idle
        ? 0.0
        : const Interval(0.0, 0.2, curve: Curves.easeIn).transform(_progress);
    final bool isCompleting =
        mode == RefreshStatus.completed || mode == RefreshStatus.failed;
    final double dismissValue = Curves.easeOut.transform(
      _dismissController.value,
    );
    final double dismissScale =
        isCompleting ? ui.lerpDouble(1.0, 0.5, dismissValue) ?? 0.5 : 1.0;
    final double dismissOpacity = isCompleting ? 1.0 - dismissValue : 1.0;
    final bool showTimestamp = widget.showLastUpdated &&
        mode == RefreshStatus.completed &&
        _lastUpdatedAt != null;

    final Widget indicator = AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[
        _rotationController,
        _scaleController,
        _opacityController,
        _dismissController,
      ]),
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: (indicatorOpacity * dismissOpacity).clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _scaleAnimation.value * dismissScale,
            child: IOS17ActivityIndicator(
              color: _resolvedColor,
              radius: widget.radius,
              progress: mode == RefreshStatus.refreshing || isCompleting
                  ? 1.0
                  : _progress,
              rotationValue: _rotationController.value,
              gradientOpacity: mode == RefreshStatus.refreshing || isCompleting
                  ? Curves.easeIn.transform(_opacityController.value)
                  : 0.0,
            ),
          ),
        );
      },
    );

    Widget content = indicator;
    if (showTimestamp) {
      final String text =
          widget.lastUpdatedTextBuilder?.call(_lastUpdatedAt!) ??
              _defaultLastUpdatedText(_lastUpdatedAt!, DateTime.now());
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          indicator,
          const SizedBox(height: 4.0),
          Opacity(
            opacity: dismissOpacity.clamp(0.0, 1.0),
            child: Text(
              text,
              style: CupertinoTheme.of(context)
                  .textTheme
                  .tabLabelTextStyle
                  .copyWith(color: _resolvedColor, fontSize: 11.0),
            ),
          ),
        ],
      );
    }

    return SizedBox(
      height: widget.height,
      child: Center(child: content),
    );
  }
}

class _ActivityIndicatorPainter extends CustomPainter {
  const _ActivityIndicatorPainter({
    required this.color,
    required this.progress,
    required this.rotationValue,
    required this.gradientOpacity,
  });

  final Color color;
  final double progress;
  final double rotationValue;
  final double gradientOpacity;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();
    final double radius = math.min(size.width, size.height) / 2.0;
    final double tickWidth = radius * 0.2;
    final double tickHeight = radius * 0.45;
    final double tickNearEdge = radius * 0.45;
    final double tickCornerRadius = tickWidth / 2.0;
    final RRect tick = RRect.fromLTRBXY(
      -tickWidth / 2.0,
      -(tickNearEdge + tickHeight),
      tickWidth / 2.0,
      -tickNearEdge,
      tickCornerRadius,
      tickCornerRadius,
    );

    canvas.save();
    canvas.translate(size.width / 2.0, size.height / 2.0);

    final int visibleTicks = (progress.clamp(0.0, 1.0) * _kTickCount).floor();
    final int activeTick = (_kTickCount * rotationValue).floor() % _kTickCount;

    for (int i = 0; i < _kTickCount; i++) {
      int alpha;
      if (progress < 1.0) {
        alpha = i < visibleTicks ? 255 : 0;
      } else {
        final int shifted = (i - activeTick) % _kTickCount;
        final int normalized = shifted < 0 ? shifted + _kTickCount : shifted;
        final List<int> trail = <int>[
          255,
          220,
          184,
          148,
          112,
          76,
          47,
          47,
          47,
          47,
          47,
          47,
        ];
        alpha = ui
                .lerpDouble(
                  255.0,
                  trail[normalized].toDouble(),
                  gradientOpacity.clamp(0.0, 1.0),
                )
                ?.round() ??
            trail[normalized];
      }
      if (alpha > 0) {
        paint.color = color.withAlpha(alpha);
        canvas.drawRRect(tick, paint);
      }
      canvas.rotate(_kTwoPi / _kTickCount);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ActivityIndicatorPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.progress != progress ||
        oldDelegate.rotationValue != rotationValue ||
        oldDelegate.gradientOpacity != gradientOpacity;
  }
}
