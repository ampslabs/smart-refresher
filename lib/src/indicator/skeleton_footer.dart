/*
 *   Author: OpenAI Codex
 *   createTime:2026-03-11
 */

import 'package:flutter/material.dart';

import '../internals/enums.dart';
import '../internals/indicator_wrap.dart';
import '../internals/refresh_localizations.dart';
import 'shimmer.dart';
import 'skeleton_bones.dart';

/// The preset skeleton layouts available out of the box.
enum SkeletonBoneStyle {
  /// A list tile layout with a leading avatar and two text lines.
  listTile,

  /// A card layout with media and text content.
  card,

  /// A paragraph-like block of text lines.
  textBlock,

  /// A horizontal row of image thumbnails.
  imageRow,
}

/// A load-more footer that renders shimmering skeleton rows instead of a spinner.
///
/// The default [height] is tuned for three [BoneListTile] rows. When changing
/// [skeletonCount] or using a taller custom [boneBuilder], update [height] to
/// avoid clipping the skeleton content while loading.
class SkeletonFooter extends LoadIndicator {
  /// Creates a [SkeletonFooter].
  const SkeletonFooter({
    super.key,
    this.skeletonCount = 3,
    this.boneStyle = SkeletonBoneStyle.listTile,
    this.boneBuilder,
    this.shimmerGradient,
    this.fadeInDuration = const Duration(milliseconds: 200),
    this.fadeOutDuration = const Duration(milliseconds: 150),
    this.semanticsLabel,
    this.semanticsHint,
    super.loadStyle = LoadStyle.showWhenLoading,
    super.height = 160.0,
  })  : _isStaggered = false,
        assert(
          skeletonCount >= 1 && skeletonCount <= 5,
          'skeletonCount must be between 1 and 5',
        );

  /// Creates a [SkeletonFooter] whose rows fade in sequentially.
  const SkeletonFooter.staggered({
    super.key,
    this.skeletonCount = 3,
    this.boneStyle = SkeletonBoneStyle.listTile,
    this.boneBuilder,
    this.shimmerGradient,
    this.fadeInDuration = const Duration(milliseconds: 240),
    this.fadeOutDuration = const Duration(milliseconds: 150),
    this.semanticsLabel,
    this.semanticsHint,
    super.loadStyle = LoadStyle.showWhenLoading,
    super.height = 160.0,
  })  : _isStaggered = true,
        assert(
          skeletonCount >= 1 && skeletonCount <= 5,
          'skeletonCount must be between 1 and 5',
        );

  /// The number of skeleton rows to render while loading.
  final int skeletonCount;

  /// The built-in skeleton layout to use when [boneBuilder] is null.
  final SkeletonBoneStyle boneStyle;

  /// Builds a custom skeleton row for the given index.
  final Widget Function(BuildContext context, int index)? boneBuilder;

  /// Overrides the default light or dark shimmer gradient.
  final LinearGradient? shimmerGradient;

  /// The fade-in duration used when loading begins.
  final Duration fadeInDuration;

  /// The fade-out duration used before the footer collapses.
  final Duration fadeOutDuration;

  /// Custom accessibility label for the indicator.
  final String? semanticsLabel;

  /// Custom accessibility hint for the indicator.
  final String? semanticsHint;

  final bool _isStaggered;

  @override
  State<StatefulWidget> createState() => SkeletonFooterState();
}

/// State for [SkeletonFooter].
class SkeletonFooterState extends LoadIndicatorState<SkeletonFooter>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: widget.fadeInDuration,
      reverseDuration: widget.fadeOutDuration,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
      reverseCurve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(covariant SkeletonFooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fadeInDuration != widget.fadeInDuration) {
      _fadeController.duration = widget.fadeInDuration;
    }
    if (oldWidget.fadeOutDuration != widget.fadeOutDuration) {
      _fadeController.reverseDuration = widget.fadeOutDuration;
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// The fade animation driving the skeleton visibility.
  Animation<double> get fadeAnimation => _fadeAnimation;

  /// The controller used for fade transitions.
  AnimationController get fadeController => _fadeController;

  @override
  Future<void> endLoading() async {
    if (_fadeController.value == 0.0) {
      await super.endLoading();
      return;
    }
    await _fadeController.reverse();
    if (mounted) {
      setState(() {});
    }
    await super.endLoading();
  }

  void _ensureVisible() {
    if (_fadeController.isAnimating || _fadeController.value == 1.0) {
      return;
    }
    _fadeController.forward();
  }

  Widget _buildSkeletonContent() {
    if (widget._isStaggered) {
      return _SkeletonRows(footer: widget, fadeAnimation: _fadeAnimation);
    }
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _SkeletonRows(footer: widget),
    );
  }

  @override
  Widget buildContent(BuildContext context, LoadStatus? mode) {
    if (mode == LoadStatus.loading || _fadeController.value > 0.0) {
      if (mode == LoadStatus.loading) {
        _ensureVisible();
      }
      final RefreshString strings =
          RefreshLocalizations.of(context)?.currentLocalization ??
              EnRefreshString();

      return Semantics(
        label: widget.semanticsLabel ?? strings.loadingText!,
        hint: widget.semanticsHint,
        child: _buildSkeletonContent(),
      );
    }
    return const SizedBox.shrink();
  }
}

class _SkeletonRows extends StatelessWidget {
  const _SkeletonRows({required this.footer, this.fadeAnimation});

  final SkeletonFooter footer;
  final Animation<double>? fadeAnimation;

  Widget _buildBone(BuildContext context, int index) {
    if (footer.boneBuilder != null) {
      return footer.boneBuilder!(context, index);
    }
    switch (footer.boneStyle) {
      case SkeletonBoneStyle.listTile:
        return const BoneListTile();
      case SkeletonBoneStyle.card:
        return const BoneCard();
      case SkeletonBoneStyle.textBlock:
        return const BoneTextBlock();
      case SkeletonBoneStyle.imageRow:
        return const BoneImageRow();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      gradient: footer.shimmerGradient,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List<Widget>.generate(footer.skeletonCount, (int index) {
          Widget row = ShimmerLoading(
            isLoading: true,
            child: _buildBone(context, index),
          );
          if (fadeAnimation != null) {
            final double delay = index * 0.15;
            final double end = (delay + 0.6).clamp(0.0, 1.0);
            row = FadeTransition(
              opacity: CurvedAnimation(
                parent: fadeAnimation!,
                curve: Interval(delay, end, curve: Curves.easeIn),
              ),
              child: row,
            );
          }
          return row;
        }),
      ),
    );
  }
}
