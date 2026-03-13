import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;

import '../internals/indicator_wrap.dart';
import '../smart_refresher.dart';
import '../theming/smart_refresher_theme.dart';

/// A frosted-glass pull-to-refresh header that floats above scroll content.
///
/// The header uses a clipped [BackdropFilter] pill to blur content behind it,
/// then layers a semi-transparent tint, thin border, and progress content.
///
/// ## Platform notes
///
/// - **Web (HTML renderer):** [BackdropFilter] is not supported. The glass panel
///   renders with a semi-transparent fill but no blur. Use `kIsWeb` to check at
///   runtime if needed.
///
/// - **Performance:** [BackdropFilter] creates a separate compositing layer.
///   A [RepaintBoundary] is included automatically. Avoid placing [GlassHeader]
///   inside other expensive compositing contexts (for example, nested
///   [BackdropFilter]s).
///
/// - **[RefreshStyle.Front] only:** [GlassHeader] requires
///   [RefreshStyle.Front]. Setting a different [refreshStyle] can produce
///   incorrect blur behavior because the blurred content would not stay behind
///   the panel.
class GlassHeader extends RefreshIndicator {
  /// Tint color for the arc and spinner.
  ///
  /// Defaults to [SmartRefresherThemeData.primaryColor] and then
  /// [ColorScheme.primary].
  final Color? color;

  /// Override the glass fill color.
  ///
  /// Defaults to an auto-resolved light/dark tint.
  final Color? glassColor;

  /// Override the glass border color.
  ///
  /// Defaults to an auto-resolved light/dark edge highlight.
  final Color? borderColor;

  /// Blur intensity when fully extended.
  final double maxBlurSigma;

  /// Whether to show status text.
  final bool showText;

  /// Text shown when in idle state (initially hidden).
  final String idleText;

  /// Text shown when the user pulls far enough to trigger refresh.
  final String canRefreshText;

  /// Text shown while the refresh operation is in progress.
  final String refreshingText;

  /// Text shown when the refresh completes successfully.
  final String completeText;

  /// Text shown when the refresh operation fails.
  final String failedText;

  /// Creates a frosted-glass pull-to-refresh header.
  const GlassHeader({
    super.key,
    this.color,
    this.glassColor,
    this.borderColor,
    this.maxBlurSigma = 12.0,
    this.showText = true,
    this.idleText = '',
    this.canRefreshText = 'Pull to refresh',
    this.refreshingText = 'Refreshing…',
    this.completeText = 'Done',
    this.failedText = 'Failed',
    super.completeDuration = const Duration(milliseconds: 700),
    super.height = 80.0,
    super.refreshStyle = RefreshStyle.Front,
  });

  @override
  State<StatefulWidget> createState() => GlassHeaderState();
}

/// The state for a [GlassHeader].
class GlassHeaderState extends RefreshIndicatorState<GlassHeader>
    with TickerProviderStateMixin {
  static const Cubic _panelInCurve = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Cubic _panelOutCurve = Cubic(0.3, 0.0, 0.8, 0.15);

  late final AnimationController _panelController;
  late final AnimationController _dismissController;
  late final Animation<double> _panelScaleAnimation;
  late final Animation<double> _dismissAnimation;

  Timer? _dismissTimer;
  double _currentBlur = 0.0;
  double _currentFillOpacity = 0.0;
  double _dragProgress = 0.0;
  bool _isCompleted = false;
  bool _isFailed = false;
  String _statusText = '';

  @override
  void initState() {
    super.initState();
    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _panelScaleAnimation = CurvedAnimation(
      parent: _panelController,
      curve: _panelInCurve,
      reverseCurve: _panelOutCurve,
    );
    _dismissController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _dismissAnimation = CurvedAnimation(
      parent: _dismissController,
      curve: Curves.easeOut,
    );
    _statusText = widget.canRefreshText;
  }

  @override
  bool needReverseAll() => false;

  @override
  Future<void> endRefresh() {
    return endRefreshWithTimer(
      widget.completeDuration + const Duration(milliseconds: 300),
    );
  }

  @override
  void onOffsetChange(double offset) {
    final double triggerDistance =
        configuration?.headerTriggerDistance ?? widget.height;
    final double p = triggerDistance == 0.0
        ? 0.0
        : (offset / triggerDistance).clamp(0.0, 1.0);
    final double blurCurve = Curves.easeIn.transform(p);

    if (_panelController.value == 0.0 && offset > 0.0) {
      _panelController.forward();
    }

    if (mounted) {
      setState(() {
        _dragProgress = p;
        _currentBlur = blurCurve * widget.maxBlurSigma;
        _currentFillOpacity = (p / 0.8).clamp(0.0, 1.0);
      });
    }
    super.onOffsetChange(offset);
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    _dismissTimer?.cancel();
    switch (mode) {
      case RefreshStatus.idle:
        _isCompleted = false;
        _isFailed = false;
        _dismissController.reset();
        _panelController.reverse();
        if (mounted) {
          setState(() {
            _currentBlur = 0.0;
            _currentFillOpacity = 0.0;
            _dragProgress = 0.0;
            _statusText = widget.idleText;
          });
        }
        break;
      case RefreshStatus.canRefresh:
        _panelController.forward();
        if (mounted) {
          setState(() {
            _statusText = widget.canRefreshText;
          });
        }
        break;
      case RefreshStatus.refreshing:
        _panelController.forward();
        if (mounted) {
          setState(() {
            _isCompleted = false;
            _isFailed = false;
            _currentBlur = widget.maxBlurSigma;
            _currentFillOpacity = 1.0;
            _dragProgress = 1.0;
            _statusText = widget.refreshingText;
          });
        }
        break;
      case RefreshStatus.completed:
        if (mounted) {
          setState(() {
            _isCompleted = true;
            _isFailed = false;
            _statusText = widget.completeText;
          });
        }
        _dismissTimer = Timer(widget.completeDuration, _dismiss);
        break;
      case RefreshStatus.failed:
        if (mounted) {
          setState(() {
            _isCompleted = false;
            _isFailed = true;
            _statusText = widget.failedText;
          });
        }
        _dismissTimer = Timer(widget.completeDuration, _dismiss);
        break;
      case RefreshStatus.canTwoLevel:
      case RefreshStatus.twoLevelOpening:
      case RefreshStatus.twoLeveling:
      case RefreshStatus.twoLevelClosing:
      case null:
        break;
    }
    super.onModeChange(mode);
  }

  void _dismiss() {
    if (!mounted) {
      return;
    }
    _dismissController.forward(from: 0.0).then((_) {
      if (!mounted) {
        return;
      }
      _panelController.reverse();
      setState(() {
        _currentBlur = 0.0;
        _currentFillOpacity = 0.0;
      });
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _panelController.dispose();
    _dismissController.dispose();
    super.dispose();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final SmartRefresherThemeData refresherTheme = SmartRefresherTheme.of(
      context,
    );
    final Color accentColor =
        widget.color ?? refresherTheme.primaryColor ?? theme.colorScheme.primary;

    final Color fillColor = widget.glassColor ??
        (isDark
            ? Colors.black.withValues(alpha: 0.25 * _currentFillOpacity)
            : Colors.white.withValues(alpha: 0.18 * _currentFillOpacity));
    final Color glassBorder = widget.borderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.15 * _currentFillOpacity)
            : Colors.white.withValues(alpha: 0.50 * _currentFillOpacity));

    final bool isRefreshing = mode == RefreshStatus.refreshing;
    final bool isIdle = mode == null || mode == RefreshStatus.idle;
    final bool showPanel =
        _dragProgress > 0.0 ||
        mode == RefreshStatus.canRefresh ||
        isRefreshing ||
        _isCompleted ||
        _isFailed;

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double pillWidth = math.min(screenWidth * 0.75, 320.0);

    Widget indicator;
    if (isRefreshing) {
      indicator = CupertinoActivityIndicator(color: accentColor);
    } else {
      indicator = CustomPaint(
        size: const Size(28.0, 28.0),
        painter: _ArcPainter(
          progress: _dragProgress,
          trackColor: Colors.white.withValues(alpha: 0.25),
          arcColor: accentColor,
        ),
      );
    }

    Widget textWidget = const SizedBox.shrink();
    if (widget.showText && _statusText.isNotEmpty && !isIdle) {
      textWidget = Padding(
        padding: const EdgeInsets.only(left: 10.0),
        child: Text(
          _statusText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13.0,
            fontWeight: FontWeight.w500,
            shadows: <Shadow>[
              Shadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 4.0,
              ),
            ],
          ),
        ),
      );
    }

    Widget pill = SizedBox(
      width: pillWidth,
      height: 52.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26.0),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: _currentBlur, sigmaY: _currentBlur),
              child: Container(color: Colors.transparent),
            ),
            Container(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(26.0),
                border: Border.all(color: glassBorder),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 16.0,
                    offset: const Offset(0.0, 4.0),
                  ),
                ],
              ),
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[indicator, textWidget],
              ),
            ),
          ],
        ),
      ),
    );

    pill = ScaleTransition(scale: _panelScaleAnimation, child: pill);

    if (_isCompleted || _isFailed) {
      pill = FadeTransition(
        opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_dismissAnimation),
        child: pill,
      );
    }

    return SizedBox(
      height: widget.height,
      child: Center(
        child: Opacity(
          opacity: showPanel && !isIdle ? 1.0 : (_dragProgress > 0.0 ? 1.0 : 0.0),
          child: RepaintBoundary(child: pill),
        ),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color arcColor;
  final double strokeWidth = 2.5;

  const _ArcPainter({
    required this.progress,
    required this.trackColor,
    required this.arcColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2.0, size.height / 2.0);
    final double radius = (math.min(size.width, size.height) - strokeWidth) / 2.0;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    const double startAngle = -math.pi / 2.0;

    final Paint trackPaint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Paint arcPaint = Paint()
      ..color = arcColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0.0, math.pi * 2.0, false, trackPaint);

    if (progress > 0.0) {
      canvas.drawArc(rect, startAngle, math.pi * 2.0 * progress, false, arcPaint);
    }
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.arcColor != arcColor;
  }
}
