---
title: "Configuration"
description: "Global settings and behavior customization."
---

`smart_refresher` provides several ways to customize behavior, from local properties on `SmartRefresher` to global settings using `RefreshConfiguration`.

## RefreshConfiguration

`RefreshConfiguration` is an `InheritedWidget` that allows you to set default indicators and behavior for all `SmartRefresher` widgets in its subtree. This is typically placed at the root of your app.

```dart
RefreshConfiguration(
  headerBuilder: () => WaterDropHeader(),        // Global default header
  footerBuilder:  () => ClassicFooter(),        // Global default footer
  headerTriggerDistance: 80.0,        // header trigger distance
  springDescription:SpringDescription(stiffness: 170, damping: 16, mass: 1.9),         // custom spring back animate, such as stiffness, damping, mass
  maxOverScrollExtent :100, //The maximum overscroll distance which can be dragged of header
  maxUnderScrollExtent:0, //The maximum overscroll distance which can be dragged of footer
  enableScrollWhenRefreshCompleted: true, //This property is incompatible with PageView and TabBarView. If you need PagView to scroll, please set this property to false.
  enableLoadingWhenFailed : true, //In the case of load failure, whether to still allow pull-up to generate load events
  hideFooterWhenNotFull: false, // Whether to hide the footer when the content does not fill the screen
  enableBallisticRefresh: false, // Whether to allow trigger refresh while ballistic scroll
  child: MaterialApp(
      ...
  )
);
```

## SmartRefresher Properties

| Property | Type | Description |
| -------- | ---- | ----------- |
| `controller` | `RefreshController` | **Required**. Manages header and footer states. |
| `child` | `Widget` | The scrollable content. |
| `header` | `Widget` | Custom header indicator. |
| `footer` | `Widget` | Custom footer indicator. |
| `enablePullDown`| `bool` | Whether to enable pull-down refresh. Default: `true`. |
| `enablePullUp` | `bool` | Whether to enable pull-up loading. Default: `false`. |
| `onRefresh` | `VoidCallback` | Triggered on refresh. |
| `onLoading` | `VoidCallback` | Triggered on loading more. |

## RefreshController

The `RefreshController` is used to programmatically trigger or complete refresh actions.

```dart
// Complete refresh
_refreshController.refreshCompleted();

// Reset to idle
_refreshController.refreshToIdle();

// Refresh failed
_refreshController.refreshFailed();

// Complete loading more
_refreshController.loadComplete();

// No more data to load
_refreshController.loadNoData();

// Reset footer from NoData to idle
_refreshController.resetNoData();
```
