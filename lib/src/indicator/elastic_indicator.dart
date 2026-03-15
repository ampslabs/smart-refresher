import 'package:flutter/widgets.dart';
import 'package:smart_refresher/src/internals/indicator_wrap.dart';
import 'package:smart_refresher/src/internals/enums.dart';

/// A header that stretches its content based on the overscroll distance.
///
/// This provides a physics-based "elastic" effect common in high-end iOS apps.
class ElasticHeader extends RefreshIndicator {
  /// Creates an [ElasticHeader].
  const ElasticHeader({
    super.key,
    required this.child,
    super.height = 100.0,
    super.refreshStyle = RefreshStyle.follow,
    super.completeDuration = const Duration(milliseconds: 600),
  });

  /// The widget to be stretched.
  final Widget child;

  @override
  State<StatefulWidget> createState() {
    return _ElasticHeaderState();
  }
}

class _ElasticHeaderState extends RefreshIndicatorState<ElasticHeader> {
  double _stretchFactor = 1.0;

  @override
  void onOffsetChange(double offset) {
    super.onOffsetChange(offset);
    
    // Calculate stretch factor based on overscroll distance
    // We start stretching after the initial offset
    final double newFactor = 1.0 + (offset / widget.height).clamp(0.0, 2.0);
    
    if (newFactor != _stretchFactor) {
      setState(() {
        _stretchFactor = newFactor;
      });
    }
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    return Transform.scale(
      scaleY: _stretchFactor,
      alignment: Alignment.bottomCenter,
      child: widget.child,
    );
  }
}
