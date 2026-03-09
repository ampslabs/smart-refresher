---
title: "Bezier Indicators"
description: "Visually striking bezier curve effects."
---

The Bezier indicators provide a fluid, organic feel to the pull-down gesture.

## BezierHeader

A low-level header that provides a bezier curve container. You can place any widget inside it.

### Basic Usage

```dart
SmartRefresher(
  header: BezierHeader(
    bezierColor: Colors.blueAccent,
    child: Center(child: Text("Custom Content", style: TextStyle(color: Colors.white))),
  ),
  ...
)
```

## BezierCircleHeader

A pre-built header that combines the `BezierHeader` container with a clean circle indicator.

### Basic Usage

```dart
SmartRefresher(
  header: BezierCircleHeader(
    bezierColor: Colors.green,
    circleColor: Colors.white,
  ),
  ...
)
```

### Customization

| Property | Type | Description |
| -------- | ---- | ----------- |
| `bezierColor` | `Color` | Color of the background curve. |
| `circleColor` | `Color` | Color of the progress circle. |
| `dismissType` | `BezierDismissType` | Animation style when dismissing (`none`, `rectSpread`, `scaleToCenter`). |
