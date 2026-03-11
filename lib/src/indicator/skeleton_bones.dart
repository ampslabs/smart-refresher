/*
 *   Author: OpenAI Codex
 *   createTime:2026-03-11
 */

import 'package:flutter/material.dart';

import '../theming/indicator_theme.dart';

Color _defaultBoneColor(BuildContext context) {
  return IndicatorThemeData.resolve(context).skeletonBoneColor;
}

/// A rounded rectangular placeholder block used to compose skeleton layouts.
class SkeletonBone extends StatelessWidget {
  /// Creates a [SkeletonBone].
  const SkeletonBone({
    super.key,
    this.width,
    this.height = 14.0,
    this.borderRadius = 4.0,
    this.color,
  });

  /// The width of the bone.
  ///
  /// When null, the bone expands to the available width.
  final double? width;

  /// The height of the bone.
  final double height;

  /// The border radius applied to the rounded rectangle.
  final double borderRadius;

  /// The opaque base color used before the shimmer mask is applied.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? _defaultBoneColor(context),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

/// A skeleton layout that mirrors a typical list tile row.
class BoneListTile extends StatelessWidget {
  /// Creates a [BoneListTile].
  const BoneListTile({
    super.key,
    this.hasLeading = true,
    this.hasSubtitle = true,
    this.leadingShape = BoxShape.circle,
  });

  /// Whether to draw a leading avatar or thumbnail placeholder.
  final bool hasLeading;

  /// Whether to draw subtitle placeholders under the title line.
  final bool hasSubtitle;

  /// The shape used for the leading placeholder.
  final BoxShape leadingShape;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Row(
        children: <Widget>[
          if (hasLeading) ...<Widget>[
            _LeadingBone(shape: leadingShape),
            const SizedBox(width: 12.0),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const FractionallySizedBox(
                  widthFactor: 0.68,
                  alignment: Alignment.centerLeft,
                  child: SkeletonBone(),
                ),
                if (hasSubtitle) ...<Widget>[
                  const SizedBox(height: 8.0),
                  const Row(
                    children: <Widget>[
                      Expanded(flex: 4, child: SkeletonBone(height: 10.0)),
                      SizedBox(width: 8.0),
                      Expanded(flex: 3, child: SkeletonBone(height: 10.0)),
                      Spacer(flex: 3),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeadingBone extends StatelessWidget {
  const _LeadingBone({required this.shape});

  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42.0,
      height: 42.0,
      decoration: BoxDecoration(
        color: _defaultBoneColor(context),
        shape: shape,
        borderRadius:
            shape == BoxShape.rectangle ? BorderRadius.circular(10.0) : null,
      ),
    );
  }
}

/// A skeleton layout that mirrors a card with media and text.
class BoneCard extends StatelessWidget {
  /// Creates a [BoneCard].
  const BoneCard({super.key, this.imageAspectRatio = 16 / 9});

  /// The aspect ratio used for the leading media block.
  final double imageAspectRatio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: imageAspectRatio,
            child: const SkeletonBone(
              width: double.infinity,
              height: double.infinity,
              borderRadius: 12.0,
            ),
          ),
          const SizedBox(height: 10.0),
          const SkeletonBone(width: double.infinity),
          const SizedBox(height: 8.0),
          const FractionallySizedBox(
            widthFactor: 0.58,
            alignment: Alignment.centerLeft,
            child: SkeletonBone(),
          ),
        ],
      ),
    );
  }
}

/// A skeleton layout that mirrors a short block of text lines.
class BoneTextBlock extends StatelessWidget {
  /// Creates a [BoneTextBlock].
  const BoneTextBlock({super.key, this.lines = 3});

  /// The number of text lines to render.
  final int lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List<Widget>.generate(lines, (int index) {
          final bool isLast = index == lines - 1;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0.0 : 8.0),
            child: FractionallySizedBox(
              widthFactor: isLast ? 0.82 : 1.0,
              alignment: Alignment.centerLeft,
              child: const SkeletonBone(height: 13.0),
            ),
          );
        }),
      ),
    );
  }
}

/// A skeleton layout that mirrors a row of image thumbnails.
class BoneImageRow extends StatelessWidget {
  /// Creates a [BoneImageRow].
  const BoneImageRow({super.key, this.itemCount = 3, this.itemSize = 80.0});

  /// The number of thumbnails to show.
  final int itemCount;

  /// The width and height of each thumbnail square.
  final double itemSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: List<Widget>.generate(itemCount, (int index) {
          return Padding(
            padding: EdgeInsets.only(right: index < itemCount - 1 ? 8.0 : 0.0),
            child: SkeletonBone(
              width: itemSize,
              height: itemSize,
              borderRadius: 10.0,
            ),
          );
        }),
      ),
    );
  }
}
