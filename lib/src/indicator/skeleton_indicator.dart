// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart'
    hide RefreshIndicator, RefreshIndicatorState;

import '../internals/indicator_wrap.dart';
import '../smart_refresher.dart';

/// The geometry presets used by [BoneListTile] and [SkeletonFooter].
enum BoneStyle { list, card, text, compact }

/// A placeholder row designed to visually match the example app's fake list item.
class BoneListTile extends StatelessWidget {
  const BoneListTile({
    super.key,
    this.style = BoneStyle.list,
    this.index = 0,
    this.baseColor,
    this.highlightColor,
  });

  final BoneStyle style;
  final int index;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color fill = baseColor ??
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7);
    final Color glow = highlightColor ??
        theme.colorScheme.surfaceContainer.withValues(alpha: 0.9);
    final double titleWidth = 120.0 + (index % 5) * 20.0;
    final double subtitleWidth = 200.0 - (index % 3) * 28.0;
    final BorderRadius radius = BorderRadius.circular(
      style == BoneStyle.card ? 18.0 : 14.0,
    );

    Widget line(double width, {double height = 10.0}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: glow,
          borderRadius: BorderRadius.circular(height / 2),
        ),
      );
    }

    final Widget tile = Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: <Widget>[
          Container(
            width: style == BoneStyle.compact ? 42.0 : 48.0,
            height: style == BoneStyle.compact ? 42.0 : 48.0,
            decoration: BoxDecoration(color: glow, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                line(titleWidth, height: 12.0),
                const SizedBox(height: 8.0),
                if (style != BoneStyle.text) line(subtitleWidth),
                if (style == BoneStyle.list ||
                    style == BoneStyle.card) ...<Widget>[
                  const SizedBox(height: 6.0),
                  line(140.0, height: 8.0),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (style == BoneStyle.card) {
      return Card(
        elevation: 0,
        color: fill,
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: tile,
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(color: fill, borderRadius: radius),
      child: tile,
    );
  }
}

/// A loading footer that previews incoming list items with skeleton placeholders.
class SkeletonFooter extends LoadIndicator {
  const SkeletonFooter({
    super.key,
    this.boneStyle = BoneStyle.list,
    this.skeletonCount = 3,
    this.staggered = true,
    this.baseColor,
    this.highlightColor,
    this.idleText = 'Pull up to load more',
    this.noMoreText = 'No more items',
    super.height = 220.0,
  }) : super(loadStyle: LoadStyle.ShowAlways);

  final BoneStyle boneStyle;
  final int skeletonCount;
  final bool staggered;
  final Color? baseColor;
  final Color? highlightColor;
  final String idleText;
  final String noMoreText;

  @override
  State<StatefulWidget> createState() => _SkeletonFooterState();
}

class _SkeletonFooterState extends LoadIndicatorState<SkeletonFooter> {
  @override
  Widget buildContent(BuildContext context, LoadStatus? mode) {
    final ThemeData theme = Theme.of(context);
    final bool showSkeleton =
        mode == LoadStatus.loading || mode == LoadStatus.canLoading;

    if (mode == LoadStatus.noMore) {
      return SizedBox(
        height: 64.0,
        child: Center(
          child: Text(
            widget.noMoreText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    if (!showSkeleton) {
      return SizedBox(
        height: 72.0,
        child: Center(
          child: Text(
            widget.idleText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: widget.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List<Widget>.generate(widget.skeletonCount, (int index) {
          final int effectiveIndex = widget.staggered ? index : 0;
          return BoneListTile(
            index: effectiveIndex,
            style: widget.boneStyle,
            baseColor: widget.baseColor,
            highlightColor: widget.highlightColor,
          );
        }),
      ),
    );
  }
}
