// ignore_for_file: camel_case_types

import 'dart:ui' as ui show lerpDouble;
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../internals/indicator_wrap.dart';
import '../smart_refresher.dart';
import '../theming/indicator_theme.dart';
import '../internals/refresh_localizations.dart';

const int _kTickCount = 12;
const double _kTwoPi = math.pi * 2.0;

/// The alpha values used by the iOS 17 spinner's comet tail.
@visibleForTesting
const List<int> kIOS17HeaderAlphaValues = <int>[
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

/// Returns the alpha for each tick for the current visual state.
@visibleForTesting
List<int> debugIOS17HeaderTickAlphas({
  required double progress,
  double rotationValue = 0.0,
  double gradientOpacity = 0.0,
}) {
  final double clampedProgress = progress.clamp(0.0, 1.0);
  final bool isSpinning = clampedProgress >= 1.0;

  if (!isSpinning) {
    final int visibleTicks = (clampedProgress * _kTickCount).floor();
    return List<int>.generate(
      _kTickCount,
      (int index) => index < visibleTicks ? kIOS17HeaderAlphaValues.first : 0,
    );
  }

  final int activeTick = (_kTickCount * rotationValue).floor() % _kTickCount;
  final double clampedGradientOpacity = gradientOpacity.clamp(0.0, 1.0);

  return List<int>.generate(_kTickCount, (int index) {
    final int shifted = (index - activeTick) % _kTickCount;
    final int gradientAlpha =
        kIOS17HeaderAlphaValues[shifted < 0 ? shifted + _kTickCount : shifted];
    return ui
            .lerpDouble(
              kIOS17HeaderAlphaValues.first.toDouble(),
              gradientAlpha.toDouble(),
              clampedGradientOpacity,
            )
            ?.round() ??
        gradientAlpha;
  });
}

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

/// Builds the completion timestamp text used by `iOS17Header`.
@visibleForTesting
String debugIOS17HeaderLastUpdatedText({
  required DateTime updatedAt,
  DateTime? now,
  String Function(DateTime updatedAt)? builder,
}) {
  if (builder != null) {
    return builder(updatedAt);
  }
  return _defaultLastUpdatedText(updatedAt, now ?? DateTime.now());
}

/// A reusable iOS 17 style activity indicator.
class IOS17ActivityIndicator extends StatelessWidget {
  /// Creates an [IOS17ActivityIndicator].
  const IOS17ActivityIndicator({
    super.key,
    required this.color,
    required this.radius,
    required this.progress,
    this.rotationValue = 0.0,
    this.gradientOpacity = 1.0,
  });

  /// Tint color of the ticks.
  final Color color;

  /// Radius of the activity indicator.
  final double radius;

  /// Drag or refresh progress, clamped to 0.0-1.0.
  final double progress;

  /// Current spinner rotation, where 1.0 is one full turn.
  final double rotationValue;

  /// How much of the spinning gradient is visible.
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
  /// Creates an [iOS17Header].
  const iOS17Header({
    super.key,
    this.color,
    this.radius = 10.0,
    this.showLastUpdated = false,
    this.enableHaptic = true,
    this.lastUpdatedTextBuilder,
    this.semanticsLabel,
    this.semanticsHint,
    super.height = 60.0,
    super.completeDuration = const Duration(milliseconds: 300),
    super.refreshStyle = RefreshStyle.Follow,
  });

  /// Tint color of the activity indicator ticks.
  ///
  /// Defaults to [CupertinoColors.systemFill] resolved against the current
  /// [CupertinoTheme].
  final Color? color;

  /// Whether to show a timestamp after a successful refresh.
  final bool showLastUpdated;

  /// Whether to trigger haptic feedback when entering refreshing mode.
  final bool enableHaptic;

  /// Optional custom formatter for the completion timestamp.
  final String Function(DateTime updatedAt)? lastUpdatedTextBuilder;

  /// Radius of the activity indicator. Defaults to 10.0.
  final double radius;

  /// Custom accessibility label for the indicator.
  final String? semanticsLabel;

  /// Custom accessibility hint for the indicator.
  final String? semanticsHint;

  @override
  State<StatefulWidget> createState() => iOS17HeaderState();
}

/// State for [iOS17Header].
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

  Color get _resolvedColor => IndicatorThemeData.resolve(
        context,
        widgetIosTickColor: widget.color,
      ).iosTickColor;

  @visibleForTesting

  /// Returns the current drag progress used by the indicator.
  double get debugProgress => _progress;

  @visibleForTesting

  /// Returns the current scale controller value.
  double get debugScaleControllerValue => _scaleController.value;

  @visibleForTesting

  /// Returns the current opacity controller value.
  double get debugOpacityControllerValue => _opacityController.value;

  @visibleForTesting

  /// Returns the current dismiss controller value.
  double get debugDismissControllerValue => _dismissController.value;

  @visibleForTesting

  /// Returns the current rotation controller value.
  double get debugRotationControllerValue => _rotationController.value;

  @visibleForTesting

  /// Returns the last completion timestamp, if any.
  DateTime? get debugLastUpdatedAt => _lastUpdatedAt;

  @visibleForTesting

  /// Updates the visual mode and runs the same side effects used in production.
  void debugSetVisualMode(RefreshStatus nextMode) {
    mode = nextMode;
    onModeChange(nextMode);
  }

  @visibleForTesting

  /// Starts the threshold-crossing scale pop.
  void debugStartScalePop() {
    _scaleController.forward(from: 0.0);
  }

  @visibleForTesting

  /// Starts the refreshing animations without going through scroll physics.
  void debugStartRefreshingAnimation() {
    _progress = 1.0;
    _opacityController.forward(from: 0.0);
    _rotationController.repeat();
    setState(() {});
  }

  @visibleForTesting

  /// Starts the fixed-duration dismiss animation.
  Future<void> debugStartDismissAnimation() {
    return _dismissController.forward(from: 0.0);
  }

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
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
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
  bool needReverseAll() {
    return false;
  }

  @override
  void onOffsetChange(double offset) {
    final double nextProgress =
        (offset / configuration!.headerTriggerDistance).clamp(0.0, 1.0);
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
      case RefreshStatus.canRefresh:
        break;
      case RefreshStatus.refreshing:
        if (defaultTargetPlatform == TargetPlatform.iOS &&
            !_didFireHaptic &&
            widget.enableHaptic) {
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
      default:
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
    final double dismissValue =
        Curves.easeOut.transform(_dismissController.value);
    final double dismissScale =
        isCompleting ? ui.lerpDouble(1.0, 0.5, dismissValue) ?? 0.5 : 1.0;
    final double dismissOpacity = isCompleting ? 1.0 - dismissValue : 1.0;
    final bool showTimestamp = widget.showLastUpdated &&
        mode == RefreshStatus.completed &&
        _lastUpdatedAt != null;

    final RefreshString strings =
        RefreshLocalizations.of(context)?.currentLocalization ??
            EnRefreshString();
    final String label = widget.semanticsLabel ??
        (mode == RefreshStatus.completed
            ? strings.refreshCompleteText!
            : mode == RefreshStatus.failed
                ? strings.refreshFailedText!
                : mode == RefreshStatus.refreshing
                    ? strings.refreshingText!
                    : mode == RefreshStatus.canRefresh
                        ? strings.canRefreshText!
                        : strings.idleRefreshText!);

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
              gradientOpacity: mode == RefreshStatus.refreshing ||
                      mode == RefreshStatus.completed ||
                      mode == RefreshStatus.failed
                  ? Curves.easeIn.transform(_opacityController.value)
                  : 0.0,
            ),
          ),
        );
      },
    );

    Widget content = indicator;
    if (showTimestamp) {
      final String text = widget.lastUpdatedTextBuilder != null
          ? debugIOS17HeaderLastUpdatedText(
              updatedAt: _lastUpdatedAt!,
              builder: widget.lastUpdatedTextBuilder,
            )
          : debugIOS17HeaderLastUpdatedText(
              updatedAt: _lastUpdatedAt!,
              now: DateTime.now(),
            );
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
      child: Center(
        child: Semantics(
          label: label,
          hint: widget.semanticsHint,
          child: content,
        ),
      ),
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
    final List<int> alphas = debugIOS17HeaderTickAlphas(
      progress: progress,
      rotationValue: rotationValue,
      gradientOpacity: gradientOpacity,
    );

    canvas.save();
    canvas.translate(size.width / 2.0, size.height / 2.0);

    for (int i = 0; i < _kTickCount; i++) {
      final int alpha = alphas[i];
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
