/*
 *   Author: OpenAI Codex
 *   createTime:2026-03-11
 */

import 'package:flutter/material.dart';

const LinearGradient _kLightShimmerGradient = LinearGradient(
  colors: <Color>[Color(0xFFEBEBF4), Color(0xFFF4F4F4), Color(0xFFEBEBF4)],
  stops: <double>[0.1, 0.3, 0.4],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
);

const LinearGradient _kDarkShimmerGradient = LinearGradient(
  colors: <Color>[Color(0xFF2A2A2A), Color(0xFF3A3A3A), Color(0xFF2A2A2A)],
  stops: <double>[0.1, 0.3, 0.4],
  begin: Alignment(-1.0, -0.3),
  end: Alignment(1.0, 0.3),
);

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}

/// Hosts a shared animated gradient for descendant [ShimmerLoading] widgets.
class Shimmer extends StatefulWidget {
  /// Creates a [Shimmer].
  const Shimmer({
    super.key,
    required this.child,
    this.gradient,
    this.slidePercent,
  });

  /// Returns the nearest ancestor [ShimmerState].
  static ShimmerState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerState>();
  }

  /// The subtree that participates in the shimmer effect.
  final Widget child;

  /// Overrides the default light or dark shimmer gradient.
  final LinearGradient? gradient;

  /// Freezes the shimmer at a fixed slide value when provided.
  ///
  /// This is primarily useful for tests and golden generation.
  final double? slidePercent;

  @override
  ShimmerState createState() => ShimmerState();
}

/// State for [Shimmer].
class ShimmerState extends State<Shimmer> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this);
    _configureAnimation();
  }

  @override
  void didUpdateWidget(covariant Shimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slidePercent != widget.slidePercent) {
      _configureAnimation();
    }
  }

  void _configureAnimation() {
    _controller.stop();
    if (widget.slidePercent != null) {
      _controller.value = widget.slidePercent!;
      return;
    }
    _controller
      ..value = -0.5
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// The active shimmer gradient with the current slide transform applied.
  LinearGradient get gradient {
    final LinearGradient base = widget.gradient ??
        (Theme.of(context).brightness == Brightness.dark
            ? _kDarkShimmerGradient
            : _kLightShimmerGradient);
    return LinearGradient(
      colors: base.colors,
      stops: base.stops,
      begin: base.begin,
      end: base.end,
      tileMode: base.tileMode,
      transform: _SlidingGradientTransform(
        slidePercent: widget.slidePercent ?? _controller.value,
      ),
    );
  }

  /// Whether the render box for this shimmer host has a concrete size.
  bool get isSized {
    final RenderObject? renderObject = context.findRenderObject();
    return renderObject is RenderBox && renderObject.hasSize;
  }

  /// The current size of the shimmer host.
  Size get size {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) {
      throw StateError('Shimmer render object is not a RenderBox.');
    }
    return renderObject.size;
  }

  /// Returns the descendant's offset relative to this shimmer host.
  Offset getDescendantOffset({required RenderBox descendant}) {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderBox) {
      throw StateError('Shimmer render object is not a RenderBox.');
    }
    final RenderBox shimmerBox = renderObject;
    return descendant.localToGlobal(Offset.zero, ancestor: shimmerBox);
  }

  /// A listenable that notifies descendants when the gradient changes.
  Listenable get shimmerChanges => _controller;

  /// Overrides the active shimmer position for deterministic tests.
  @visibleForTesting
  void debugSetSlidePercent(double value) {
    _controller
      ..stop()
      ..value = value;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Applies the ancestor [Shimmer] gradient to the painted pixels of [child].
class ShimmerLoading extends StatefulWidget {
  /// Creates a [ShimmerLoading].
  const ShimmerLoading({
    super.key,
    required this.child,
    required this.isLoading,
  });

  /// The placeholder subtree that receives the shimmer mask.
  final Widget child;

  /// Whether the shimmer effect should be active.
  final bool isLoading;

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading> {
  Listenable? _shimmerChanges;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final Listenable? newShimmer = Shimmer.of(context)?.shimmerChanges;
    if (_shimmerChanges == newShimmer) {
      return;
    }
    _shimmerChanges?.removeListener(_onShimmerChanged);
    _shimmerChanges = newShimmer;
    _shimmerChanges?.addListener(_onShimmerChanged);
  }

  @override
  void dispose() {
    _shimmerChanges?.removeListener(_onShimmerChanged);
    super.dispose();
  }

  void _onShimmerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) {
      return widget.child;
    }
    final ShimmerState? shimmer = Shimmer.of(context);
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (shimmer == null ||
        !shimmer.isSized ||
        renderBox == null ||
        !renderBox.hasSize) {
      return widget.child;
    }
    final Offset offsetWithinShimmer = shimmer.getDescendantOffset(
      descendant: renderBox,
    );
    final Size shimmerSize = shimmer.size;
    return RepaintBoundary(
      child: ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (Rect bounds) {
          return shimmer.gradient.createShader(
            Rect.fromLTWH(
              -offsetWithinShimmer.dx,
              -offsetWithinShimmer.dy,
              shimmerSize.width,
              shimmerSize.height,
            ),
          );
        },
        child: widget.child,
      ),
    );
  }
}
