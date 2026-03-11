# smart_refresher

[![pub.dev](https://img.shields.io/pub/v/smart_refresher.svg)](https://pub.dev/packages/smart_refresher)
[![pub points](https://img.shields.io/pub/points/smart_refresher)](https://pub.dev/packages/smart_refresher/score)
[![platforms](https://img.shields.io/badge/platforms-android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20linux%20%7C%20windows-blue)](https://pub.dev/packages/smart_refresher)
[![license: MIT](https://img.shields.io/badge/license-MIT-green)](https://github.com/ampslabs/smart-refresher/blob/main/LICENSE)

> **Maintained fork** of the unmaintained [`peng8350/flutter_pulltorefresh`](https://github.com/peng8350/flutter_pulltorefresh), actively maintained under the new name **smart_refresher** by [ampslabs](https://github.com/ampslabs).

A Flutter package that provides pull-to-refresh and infinite-scroll loading for any scrollable widget — with modern indicators, full accessibility support, and zero additional dependencies.

---

## Features

- **Pull-to-refresh** and **pull-up infinite loading** for `ListView`, `GridView`, `CustomScrollView`, and most other scrollable widgets
- **Modern indicators** — Classic, Material 3, iOS 17-style, and Skeleton footer
- **Accessibility first** — Proper semantic labels and hints for screen readers (TalkBack/VoiceOver) out of the box, with full customization
- **App-wide theming** via `SmartRefresherTheme` and `ThemeData` extensions — indicators read `colorScheme` automatically
- **Dark mode** support with no manual color props required
- **Programmatic control** via `RefreshController` — trigger or complete refresh from code
- **Global defaults** via `RefreshConfiguration` — set indicator, trigger distances, and scroll behaviour for the whole app
- **Complex layout support** — Works with `center` slivers, bidirectional scrolling, and pinned `SliverAppBar`s
- **WASM compatible** — Fully optimized for Flutter's WASM web target
- Flutter 3.27+ compatible, null-safe, zero external dependencies

---

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [SmartRefresher Properties](#smartrefresher-properties)
- [RefreshController](#refreshcontroller)
- [Headers](#headers)
  - [ClassicHeader](#classicheader)
  - [Material3Header](#material3header)
  - [iOS17Header](#ios17header)
- [Footers](#footers)
  - [ClassicFooter](#classicfooter)
  - [SkeletonFooter](#skeletonfooter)
- [Theming](#theming)
- [RefreshConfiguration (Global Defaults)](#refreshconfiguration-global-defaults)
- [Custom Indicators](#custom-indicators)
- [Common Patterns](#common-patterns)
- [Known Limitations](#known-limitations)
- [Migrating from pull_to_refresh](#migrating-from-pull_to_refresh)
- [Contributing](#contributing)

---

## Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  smart_refresher: ^0.2.0
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

```dart
import 'package:smart_refresher/smart_refresher.dart';

class MyList extends StatefulWidget {
  const MyList({super.key});

  @override
  State<MyList> createState() => _MyListState();
}

class _MyListState extends State<MyList> {
  final RefreshController _controller = RefreshController();
  List<String> _items = List.generate(15, (i) => 'Item ${i + 1}');

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _items = List.generate(15, (i) => 'Item ${i + 1}'));
    _controller.refreshCompleted();
  }

  Future<void> _onLoading() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (_items.length >= 50) {
      _controller.loadNoData();
      return;
    }
    setState(() => _items.addAll(
      List.generate(10, (i) => 'Item ${_items.length + i + 1}'),
    ));
    _controller.loadComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      enablePullUp: true,
      controller: _controller,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (_, i) => ListTile(title: Text(_items[i])),
      ),
    );
  }
}
```

---

## SmartRefresher Properties

| Property | Type | Default | Description |
|---|---|---|---|
| `controller` | `RefreshController` | **required** | Controls refresh/load state programmatically |
| `child` | `Widget?` | `null` | The scrollable content — typically `ListView`, `GridView`, or `CustomScrollView` |
| `header` | `Widget?` | `ClassicHeader()` | The pull-to-refresh indicator |
| `footer` | `Widget?` | `ClassicFooter()` | The load-more indicator |
| `enablePullDown` | `bool` | `true` | Whether pull-to-refresh is enabled |
| `enablePullUp` | `bool` | `false` | Whether pull-up load-more is enabled |
| `onRefresh` | `VoidCallback?` | `null` | Called when refresh is triggered |
| `onLoading` | `VoidCallback?` | `null` | Called when load-more is triggered |
| `center` | `Key?` | `null` | The key of the sliver that should be at the center of the viewport |
| `scrollDirection` | `Axis?` | `Axis.vertical` | Scroll axis |
| `reverse` | `bool?` | `false` | Whether scroll is reversed (bottom-to-top lists) |
| `physics` | `ScrollPhysics?` | `null` | Scroll physics — passed through to the inner scroll view |
| `primary` | `bool?` | `null` | Whether this is the primary scroll view |
| `cacheExtent` | `double?` | `null` | Pre-render extent beyond visible area |

**Important:** `SmartRefresher` should typically wrap the `ListView`/`GridView` directly. 

```dart
// ✅ Correct
SmartRefresher(
  controller: _controller,
  child: ListView(/* ... */),
)

// ✅ Multi-sliver layout
SmartRefresher.slivers(
  controller: _controller,
  slivers: [
    const SliverAppBar(pinned: true, title: Text('My App')),
    SliverList(/* ... */),
  ],
)

// ✅ Correct — ScrollBar wraps SmartRefresher
ScrollBar(
  child: SmartRefresher(
    child: ListView(/* ... */),
  ),
)
```

---

## RefreshController

`RefreshController` is the bridge between your data layer and the refresh widget. Create one per `SmartRefresher` and keep it alive with the same lifecycle as the widget — typically as a field in a `StatefulWidget`.

```dart
final RefreshController _controller = RefreshController(
  initialRefresh: false,  // true = trigger refresh immediately on first build
);
```

### Completing a refresh

Always call exactly one of these after `onRefresh` completes:

```dart
_controller.refreshCompleted();   // success
_controller.refreshFailed();      // error — header shows a failure state
```

### Completing a load

Always call exactly one of these after `onLoading` completes:

```dart
_controller.loadComplete();   // success — more items added
_controller.loadNoData();     // no more pages — footer hides permanently
_controller.loadFailed();     // error
```

---

## Headers

### ClassicHeader

The default header. Shows an arrow during the drag, a spinner during refresh, and text labels for each state. Platform-adaptive: uses `CircularProgressIndicator` on Android and `CupertinoActivityIndicator` on iOS.

**Key props:**

| Prop | Type | Default | Description |
|---|---|---|---|
| `refreshStyle` | `RefreshStyle` | `Follow` | `Follow`, `Behind`, `Front`, or `UnFollow` |
| `height` | `double` | `60.0` | Header zone height |
| `semanticsLabel` | `String?` | auto | Custom screen reader label |
| `semanticsHint` | `String?` | `null` | Custom screen reader hint |
| `textStyle` | `TextStyle?` | `null` | Text style for status labels |
| `idleText` | `String` | `'Pull down Refresh'` | Label in idle state |
| `refreshingText` | `String` | `'Refreshing…'` | Label during active refresh |

---

### Material3Header

A floating circular card using the updated Material 3 2024 `CircularProgressIndicator` design. Reads colors from `ThemeData.colorScheme` automatically.

**Key props:**

| Prop | Type | Default | Description |
|---|---|---|---|
| `color` | `Color?` | `primary` | Spinner arc color |
| `backgroundColor` | `Color?` | `surfaceContainerLow` | Card background |
| `elevation` | `double` | `6.0` | Card shadow elevation |
| `semanticsLabel` | `String?` | auto | Custom screen reader label |

---

### iOS17Header

A 12-spoke activity indicator matching native iOS 17 geometry. Features haptic feedback on threshold cross (iOS only).

**Key props:**

| Prop | Type | Default | Description |
|---|---|---|---|
| `enableHaptic` | `bool` | `true` | Whether to fire haptic impact |
| `showLastUpdated` | `bool` | `false` | Show completion timestamp |
| `semanticsLabel` | `String?` | auto | Custom screen reader label |

---

## Footers

### SkeletonFooter

An animated shimmer skeleton footer that replaces the spinner with placeholder rows while the next page loads.

**Key props:**

| Prop | Type | Default | Description |
|---|---|---|---|
| `boneStyle` | `SkeletonBoneStyle` | `listTile` | `listTile`, `card`, `textBlock`, `imageRow` |
| `skeletonCount` | `int` | `3` | Number of skeleton rows (1–5) |
| `semanticsLabel` | `String?` | `'Loading…'` | Custom screen reader label |

---

## Theming

All indicators read colors from `ThemeData.colorScheme` by default. Use `SmartRefresherTheme` for subtree overrides or `SmartRefresherThemeData` in your `MaterialApp` theme extensions for app-wide defaults.

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true,
    extensions: const [
      SmartRefresherThemeData(
        primaryColor: Colors.deepPurple,
        material3Elevation: 8.0,
      ),
    ],
  ),
)
```

---

## Known Limitations

| Limitation | Workaround |
|---|---|
| `AnimatedList` as direct child | Wrap inside a `CustomScrollView` |
| One controller per widget | Do not share a single `RefreshController` across tabs |
| `SmartRefresher` inside `ScrollBar` | Wrap `SmartRefresher` with `ScrollBar` instead |

---

## Contributing

Bug reports and pull requests are welcome at [ampslabs/smart-refresher](https://github.com/ampslabs/smart-refresher).

---

## License

MIT — see [`LICENSE`](https://github.com/ampslabs/smart-refresher/blob/main/LICENSE).
