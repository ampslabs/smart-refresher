# Migrating from `pull_to_refresh`

This guide explains how to migrate from the unmaintained `pull_to_refresh` package to `smart_refresher`.

## Key Changes

- **New Package Name:** Change your dependency from `pull_to_refresh` to `smart_refresher`.
- **Modern Flutter Support:** Fully compatible with Flutter 3.x and WASM.
- **Improved Indicators:** New Material 3, iOS 17, and Skeleton indicators.
- **Enhanced Controller:** `RefreshController` now exposes state via `ValueNotifier` and `Stream`.
- **Better Error Handling:** Dedicated `onRefreshFailed` and `onLoadingFailed` callbacks.

## Step-by-Step Migration

### 1. Update `pubspec.yaml`

Remove the old dependency and add the new one:

```yaml
dependencies:
  # Remove this:
  # pull_to_refresh: ^2.0.0
  
  # Add this:
  smart_refresher: ^0.2.0
```

### 2. Update Imports

Replace all `pull_to_refresh` imports with `smart_refresher`:

```dart
// Before:
import 'package:pull_to_refresh/pull_to_refresh.dart';

// After:
import 'package:smart_refresher/smart_refresher.dart';
```

### 3. Handle Status Changes

If you were manually listening to status changes, you can now use the `ValueNotifier` or `Stream` API on `RefreshController`.

```dart
// Using Stream
_controller.stream.listen((status) {
  print('Refresh status: $status');
});

// Using ValueNotifier (e.g., with ValueListenableBuilder)
ValueListenableBuilder<RefreshStatus>(
  valueListenable: _controller.headerMode!,
  builder: (context, status, child) {
    return Text('Current status: $status');
  },
)
```

### 4. Use New Callbacks

`SmartRefresher` now supports automatic error catching. If your `onRefresh` or `onLoading` throws an exception, the indicator will automatically enter the `failed` state and trigger the corresponding failure callback.

```dart
SmartRefresher(
  controller: _controller,
  onRefresh: () async {
    // If this throws, onRefreshFailed is called automatically
    await myApiCall();
    _controller.refreshCompleted();
  },
  onRefreshFailed: (error, stackTrace) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Refresh failed: $error')),
    );
  },
  // ...
)
```

### 5. Explore New Indicators

We recommend trying the new indicators that match modern platform aesthetics:

- `Material3Header`: Matches the latest Material Design.
- `Ios17Header`: Matches the native iOS 17 activity indicator.
- `GlassHeader`: Frosted glass effect for high-end UI.
- `SkeletonFooter`: Animated shimmer placeholders for loading next pages.

## Need Help?

If you encounter any issues during migration, please open an issue on [GitHub](https://github.com/ampslabs/smart-refresher/issues).
