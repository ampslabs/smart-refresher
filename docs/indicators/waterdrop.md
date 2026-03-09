---
title: "WaterDrop Indicator"
description: "iOS QQ-style waterdrop effect."
---

The `WaterDropHeader` provides a unique "waterdrop" effect during the pull-down gesture, popular in many mobile applications.

## Basic Usage

```dart
SmartRefresher(
  header: WaterDropHeader(),
  ...
)
```

## Customization

| Property | Type | Description |
| -------- | ---- | ----------- |
| `waterDropColor` | `Color` | The color of the waterdrop. |
| `idleIcon` | `Widget` | The icon inside the waterdrop during pull. |
| `refresh` | `Widget` | The widget shown while refreshing. |
| `complete` | `Widget` | The widget shown when complete. |
| `failed` | `Widget` | The widget shown when failed. |

### Example with Custom Colors

```dart
WaterDropHeader(
  waterDropColor: Colors.blue,
  idleIcon: Icon(Icons.refresh, size: 15, color: Colors.white),
)
```
