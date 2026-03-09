---
title: "Material Indicators"
description: "Native-style Material Design indicators."
---

`smart_refresher` provides indicators that mimic the native Android Material Design experience.

## MaterialClassicHeader

This indicator uses the standard Flutter `RefreshProgressIndicator` but integrates it into the `SmartRefresher` workflow.

### Basic Usage

```dart
SmartRefresher(
  header: MaterialClassicHeader(),
  ...
)
```

### Customization

| Property | Type | Description |
| -------- | ---- | ----------- |
| `color` | `Color` | The progress indicator's color. |
| `backgroundColor` | `Color` | The background color of the indicator circle. |
| `distance` | `double` | The distance from the top where the indicator rests while refreshing. |

## WaterDropMaterialHeader

A variation of the Material indicator that adds a "waterdrop" pulling effect behind the progress circle.

### Basic Usage

```dart
SmartRefresher(
  header: WaterDropMaterialHeader(
    backgroundColor: Colors.blueAccent,
    color: Colors.white,
  ),
  ...
)
```
