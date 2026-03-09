---
title: "Classic Indicator"
description: "The default and most versatile indicator style."
---

The `ClassicHeader` and `ClassicFooter` are the most commonly used indicators. They combine an icon and text to provide clear feedback to the user.

## ClassicHeader

### Basic Usage

```dart
SmartRefresher(
  header: ClassicHeader(),
  ...
)
```

### Customization

| Property | Type | Description |
| -------- | ---- | ----------- |
| `idleText` | `String` | Text shown before dragging. |
| `releaseText` | `String` | Text shown when ready to refresh. |
| `refreshingText` | `String` | Text shown while refreshing. |
| `completeText` | `String` | Text shown when refresh completes. |
| `idleIcon` | `Widget` | Icon shown before dragging. |
| `refreshingIcon` | `Widget` | Icon shown while refreshing. |
| `spacing` | `double` | Margin between icon and text. |
| `iconPos` | `IconPosition` | Position of icon relative to text (`left`, `right`, `top`, `bottom`). |

## ClassicFooter

### Basic Usage

```dart
SmartRefresher(
  enablePullUp: true,
  footer: ClassicFooter(),
  ...
)
```

### Customization

| Property | Type | Description |
| -------- | ---- | ----------- |
| `idleText` | `String` | Text shown in idle state. |
| `loadingText` | `String` | Text shown while loading. |
| `noDataText` | `String` | Text shown when there is no more data. |
| `failedText` | `String` | Text shown when loading fails. |
| `loadStyle` | `LoadStyle` | How the footer is displayed (`ShowAlways`, `HideAlways`, `ShowWhenLoading`). |
