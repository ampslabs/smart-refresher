---
title: "Two-Level Refresh"
description: "Advanced 'Second Floor' refresh functionality."
---

The `TwoLevelHeader` allows you to implement complex refresh behaviors where dragging further than a standard refresh triggers a new "level" of content, often used for marketing or special features.

## Basic Usage

```dart
SmartRefresher(
  enableTwoLevel: true,
  header: TwoLevelHeader(
    twoLevelWidget: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("images/secondfloor.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(child: Text("Welcome to the Second Floor")),
    ),
  ),
  onTwoLevel: (isOpen) {
    print("Two level is open: $isOpen");
  },
  ...
)
```

## How it Works

1.  **Enable Feature**: Set `enableTwoLevel: true` on your `SmartRefresher`.
2.  **Provide level Widget**: Pass a widget to the `twoLevelWidget` property of `TwoLevelHeader`.
3.  **Trigger Level**: When the user drags past the `twiceTriggerDistance` (default 150.0), the header enters the `canTwoLevel` state. Releasing will open the second level.
4.  **Close Level**: Call `_refreshController.twoLevelComplete()` to return to the normal list.

## Customization

| Property | Type | Description |
| -------- | ---- | ----------- |
| `twoLevelWidget` | `Widget` | The widget to display in the second level. |
| `displayAlignment` | `TwoLevelDisplayAlignment` | How content aligns (`fromTop`, `fromCenter`, `fromBottom`). |
| `decoration` | `BoxDecoration` | Background decoration for the header. |
