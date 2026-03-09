---
title: "Custom Indicators"
description: "Build your own unique refresh and loading experiences."
---

`smart_refresher` is designed to be highly extensible. You can build custom indicators using two primary methods.

## Method 1: Using CustomHeader/CustomFooter

This is the easiest way to create a custom look without managing low-level state transitions.

```dart
CustomHeader(
  builder: (BuildContext context, RefreshStatus? mode) {
    Widget body;
    if (mode == RefreshStatus.idle) {
      body = Text("pull down refresh");
    } else if (mode == RefreshStatus.refreshing) {
      body = CupertinoActivityIndicator();
    } else if (mode == RefreshStatus.canRefresh) {
      body = Text("release to refresh");
    } else if (mode == RefreshStatus.completed) {
      body = Text("refreshCompleted!");
    }
    return Container(
      height: 55.0,
      child: Center(child: body),
    );
  },
)
```

## Method 2: Extending RefreshIndicator/LoadIndicator

For complex animations or physics-driven effects, you can extend the base classes.

### Custom Header Example

```dart
class MyCustomHeader extends RefreshIndicator {
  const MyCustomHeader({super.key}) : super(height: 80.0);

  @override
  State<StatefulWidget> createState() => _MyCustomHeaderState();
}

class _MyCustomHeaderState extends RefreshIndicatorState<MyCustomHeader> {
  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    // Return your widget based on the 'mode'
    return Center(child: Text("Mode: $mode"));
  }

  @override
  void onOffsetChange(double offset) {
    // Use the raw scroll offset for custom animations
    super.onOffsetChange(offset);
  }
}
```

### Key Overrides

- `buildContent`: **Required**. Define what your indicator looks like.
- `onOffsetChange`: Handle scroll progress (useful for parallax or SVG animations).
- `onModeChange`: React to state transitions.
- `readyToRefresh`: Perform any logic before the `onRefresh` callback is triggered.
- `endRefresh`: Perform logic after refreshing is done but before returning to idle.
