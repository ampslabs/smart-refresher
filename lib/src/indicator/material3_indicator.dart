import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;

import '../internals/indicator_wrap.dart';
import '../smart_refresher.dart';
import '../theming/indicator_theme.dart';
import '../internals/refresh_localizations.dart';

/// A Material 3 pull-to-refresh header that follows the 2024 circular indicator style.
///
/// This indicator reads its defaults from [Theme.of] and
/// [ProgressIndicatorTheme.of] so it adapts automatically to Material 3 color
/// schemes, including seeded light and dark themes.
///
/// The Material 3 color roles used here, such as
/// [ColorScheme.surfaceContainerLow], require a modern Flutter SDK.
class Material3Header extends RefreshIndicator {
  /// Overrides the spinner and success icon color.
  ///
  /// When null, this falls back to [ProgressIndicatorThemeData.color] and then
  /// [ColorScheme.primary].
  final Color? color;

  /// Overrides the floating container background color.
  ///
  /// When null, this falls back to [ColorScheme.surfaceContainerLow].
  final Color? backgroundColor;

  /// The elevation applied to the circular Material container.
  final double elevation;

  /// A custom widget shown when refresh completes successfully.
  final Widget? completeIcon;

  /// A custom widget shown when refresh fails.
  final Widget? failedIcon;

  /// Custom accessibility label for the indicator.
  final String? semanticsLabel;

  /// Custom accessibility hint for the indicator.
  final String? semanticsHint;

  /// Creates a Material 3 floating refresh header.
  const Material3Header({
    super.key,
    this.color,
    this.backgroundColor,
    this.elevation = 6.0,
    this.completeIcon,
    this.failedIcon,
    this.semanticsLabel,
    this.semanticsHint,
    super.completeDuration = const Duration(milliseconds: 600),
    super.height = 80.0,
    super.refreshStyle = RefreshStyle.front,
  });

  @override
  State<StatefulWidget> createState() => Material3HeaderState();
}

/// The state for [Material3Header].
class Material3HeaderState extends RefreshIndicatorState<Material3Header>
    with TickerProviderStateMixin {
  static const Cubic _emphasizedDecelerate = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Cubic _emphasizedAccelerate = Cubic(0.3, 0.0, 0.8, 0.15);
  static const double _containerSize = 40.0;
  static const double _spinnerSize = 24.0;
  static const double _strokeWidth = 4.0;
  static const double _trackGap = 4.0;

  late final AnimationController _scaleController;
  late final AnimationController _iconFadeController;
  late final Animation<double> _scaleAnimation;

  double _dragProgress = 0.0;
  _TerminalState _terminalState = _TerminalState.none;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: _emphasizedDecelerate,
      reverseCurve: _emphasizedAccelerate,
    );
    _iconFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  bool needReverseAll() => false;

  @override
  void onOffsetChange(double offset) {
    final double triggerDistance =
        configuration?.headerTriggerDistance ?? widget.height;
    final double nextProgress = triggerDistance == 0.0
        ? 0.0
        : (offset / triggerDistance).clamp(0.0, 1.0);
    if ((_dragProgress - nextProgress).abs() > 0.001 && mounted) {
      setState(() {
        _dragProgress = nextProgress;
      });
    } else {
      _dragProgress = nextProgress;
    }
    super.onOffsetChange(offset);
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    switch (mode) {
      case RefreshStatus.idle:
        _collapse();
        break;
      case RefreshStatus.canRefresh:
        setState(() {
          _terminalState = _TerminalState.none;
        });
        _iconFadeController.value = 0.0;
        _scaleController.forward();
        break;
      case RefreshStatus.refreshing:
        setState(() {
          _terminalState = _TerminalState.none;
          _dragProgress = 1.0;
        });
        _iconFadeController.value = 0.0;
        _scaleController.forward();
        break;
      case RefreshStatus.completed:
        setState(() {
          _terminalState = _TerminalState.completed;
        });
        _iconFadeController.forward(from: 0.0);
        _scaleController.forward();
        break;
      case RefreshStatus.failed:
        setState(() {
          _terminalState = _TerminalState.failed;
        });
        _iconFadeController.forward(from: 0.0);
        _scaleController.forward();
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

  void _collapse() {
    _iconFadeController.value = 0.0;
    _scaleController.reverse().then((_) {
      if (!mounted || mode != RefreshStatus.idle) {
        return;
      }
      setState(() {
        _terminalState = _TerminalState.none;
        _dragProgress = 0.0;
      });
    });
  }

  @override
  void resetValue() {
    _dragProgress = 0.0;
    _iconFadeController.value = 0.0;
    _terminalState = _TerminalState.none;
    super.resetValue();
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final ProgressIndicatorThemeData progressTheme =
        ProgressIndicatorTheme.of(context);

    final IndicatorThemeData indicatorTheme = IndicatorThemeData.resolve(
      context,
      widgetPrimaryColor: widget.color ?? progressTheme.color,
      widgetTrackColor: progressTheme.circularTrackColor ??
          colorScheme.surfaceContainerHighest,
      widgetMaterial3BackgroundColor:
          widget.backgroundColor ?? colorScheme.surfaceContainerLow,
      widgetMaterial3Elevation: widget.elevation,
    );

    // Custom track gap fallback as it's not part of the standard indicator theme.
    final double trackGap = progressTheme.trackGap ?? _trackGap;
    final RefreshString strings =
        RefreshLocalizations.of(context)?.currentLocalization ??
            EnRefreshString();

    final String label = widget.semanticsLabel ??
        (_terminalState == _TerminalState.completed
            ? strings.refreshCompleteText!
            : _terminalState == _TerminalState.failed
                ? strings.refreshFailedText!
                : mode == RefreshStatus.refreshing
                    ? strings.refreshingText!
                    : mode == RefreshStatus.canRefresh
                        ? strings.canRefreshText!
                        : strings.idleRefreshText!);

    final Widget child = switch (_terminalState) {
      _TerminalState.completed => FadeTransition(
          opacity: _iconFadeController,
          child: widget.completeIcon ??
              Icon(
                Icons.check_circle_outline,
                size: 20.0,
                color: indicatorTheme.iconColor,
              ),
        ),
      _TerminalState.failed => FadeTransition(
          opacity: _iconFadeController,
          child: widget.failedIcon ??
              Icon(Icons.error_outline, size: 20.0, color: colorScheme.error),
        ),
      _TerminalState.none => SizedBox(
          width: _spinnerSize,
          height: _spinnerSize,
          child: CircularProgressIndicator(
            value: mode == RefreshStatus.refreshing ? null : _dragProgress,
            color: indicatorTheme.primaryColor,
            backgroundColor: indicatorTheme.trackColor,
            strokeWidth: _strokeWidth,
            trackGap: trackGap,
            strokeCap: StrokeCap.round,
            semanticsLabel: label,
          ),
        ),
    };

    return SizedBox(
      height: widget.height,
      child: Center(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Semantics(
            label: label,
            hint: widget.semanticsHint,
            child: Material(
              elevation: indicatorTheme.material3Elevation,
              shape: const CircleBorder(),
              color: indicatorTheme.material3BackgroundColor,
              child: SizedBox(
                width: _containerSize,
                height: _containerSize,
                child: Center(child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _iconFadeController.dispose();
    super.dispose();
  }
}

enum _TerminalState { none, completed, failed }
