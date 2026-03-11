# smart_refresher

[![pub.dev](https://img.shields.io/pub/v/smart_refresher.svg)](https://pub.dev/packages/smart_refresher)
[![pub points](https://img.shields.io/pub/points/smart_refresher)](https://pub.dev/packages/smart_refresher/score)
[![platforms](https://img.shields.io/badge/platforms-android%20%7C%20ios%20%7C%20web%20%7C%20macos%20%7C%20linux%20%7C%20windows-blue)](https://pub.dev/packages/smart_refresher)
[![license: MIT](https://img.shields.io/badge/license-MIT-green)](https://github.com/ampslabs/smart-refresher/blob/main/LICENSE)

> **Maintained fork** of the unmaintained [`peng8350/flutter_pulltorefresh`](https://github.com/peng8350/flutter_pulltorefresh), actively maintained under the new name **smart_refresher** by [ampslabs](https://github.com/ampslabs).

A Flutter package that provides pull-to-refresh and infinite-scroll loading for any scrollable widget — with modern indicators, full theming support, and zero additional dependencies.

---

## Features

- **Pull-to-refresh** and **pull-up infinite loading** for `ListView`, `GridView`, `CustomScrollView`, and most other scrollable widgets
- **Five built-in indicators** — Classic, Material 3, iOS 17-style, Skeleton footer, and more
- **App-wide theming** via `SmartRefresherTheme` and `ThemeData` extensions — indicators read `colorScheme` automatically
- **Dark mode** support with no manual color props required
- **Programmatic control** via `RefreshController` — trigger or complete refresh from code
- **Global defaults** via `RefreshConfiguration` — set indicator, trigger distances, and scroll behaviour for the whole app
- **Custom indicators** — implement your own header or footer with full animation access
- Works with `NestedScrollView`, `PageView`, `TabBarView`, and non-`ScrollView` children
- Flutter 3.10+ compatible, null-safe, zero external dependencies

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
  - [SkeletonFooter](#skeletonfoter)
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
  smart_refresher: ^0.1.0
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
| `scrollDirection` | `Axis?` | `Axis.vertical` | Scroll axis |
| `reverse` | `bool?` | `false` | Whether scroll is reversed (bottom-to-top lists) |
| `physics` | `ScrollPhysics?` | `null` | Scroll physics — passed through to the inner scroll view |
| `primary` | `bool?` | `null` | Whether this is the primary scroll view |
| `cacheExtent` | `double?` | `null` | Pre-render extent beyond visible area |

**Important:** `SmartRefresher` must wrap the `ListView`/`GridView` directly. Do not put another scrollable widget between them.

```dart
// ✅ Correct
SmartRefresher(
  controller: _controller,
  child: ListView(/* ... */),
)

// ❌ Wrong — scrollable nested inside another widget
SmartRefresher(
  controller: _controller,
  child: Container(
    child: ListView(/* ... */),  // ListView not a direct child
  ),
)

// ❌ Wrong — SmartRefresher inside ScrollBar
SmartRefresher(
  child: ScrollBar(
    child: ListView(/* ... */),
  ),
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

### Triggering programmatically

```dart
// Trigger a refresh from code (e.g. on screen entry)
_controller.requestRefresh();

// Trigger load-more from code
_controller.requestLoading();

// Reset noData state (e.g. after a filter change that might have new results)
_controller.resetNoData();
```

### Lifecycle

Always `dispose` the controller when the widget is disposed:

```dart
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}
```

> **One controller per widget.** Do not share a single `RefreshController` between multiple `SmartRefresher` instances (e.g. across `TabBarView` tabs). Create one controller per tab.

---

## Headers

### ClassicHeader

The default header. Shows an arrow during the drag, a spinner during refresh, and text labels for each state. Platform-adaptive: uses `CircularProgressIndicator` on Android and `CupertinoActivityIndicator` on iOS.

```dart
SmartRefresher(
  header: const ClassicHeader(),
  // ...
)
```

**Key props:**

| Prop | Type | Default | Description |
|---|---|---|---|
| `refreshStyle` | `RefreshStyle` | `RefreshStyle.Follow` | How the header moves: `Follow` (scrolls with list), `Behind` (revealed under list), `Front` (floats on top), `UnFollow` (stays fixed) |
| `height` | `double` | `60.0` | Header zone height |
| `completeDuration` | `Duration` | `800ms` | How long the "Completed" state is shown |
| `textStyle` | `TextStyle?` | `null` | Text style for status labels |
| `idleText` | `String` | `'Pull down to refresh'` | Label in idle state |
| `releaseText` | `String` | `'Release to refresh'` | Label when threshold is crossed |
| `refreshingText` | `String` | `'Refreshing...'` | Label during active refresh |
| `completeText` | `String` | `'Refresh completed'` | Label after success |
| `failedText` | `String` | `'Refresh failed'` | Label after failure |

```dart
ClassicHeader(
  refreshStyle: RefreshStyle.Behind,
  idleText: 'Pull to sync',
  completeText: 'Up to date ✓',
  textStyle: const TextStyle(color: Colors.grey, fontSize: 13),
)
```

---

### Material3Header

A floating circular card using the updated Material 3 2024 `CircularProgressIndicator` design — rounded stroke ends, gap track, `year2023: false`. Reads colors from `ThemeData.colorScheme` automatically.

```dart
SmartRefresher(
  header: const Material3Header(),
  // ...
)
```

**Key props:**

| Prop | Type | Default | Description |
|---|---|---|---|
| `color` | `Color?` | `colorScheme.primary` | Spinner arc color |
| `backgroundColor` | `Color?` | `colorScheme.surfaceContainerLow` | Card background |
| `elevation` | `double` | `6.0` | Card shadow elevation |
| `completeDuration` | `Duration` | `600ms` | Duration of the completed state |
| `completeIcon` | `Widget?` | `Icons.check_circle_outline` | Icon shown after success |
| `failedIcon` | `Widget?` | `Icons.error_outline` | Icon shown after failure |

Uses `RefreshStyle.Front` — the card floats above the content, matching the Android M3 pattern.

```dart
Material3Header(
  color: Theme.of(context).colorScheme.tertiary,
  elevation: 8.0,
)
```

---

### iOS17Header

A 12-spoke activity indicator matching the native iOS 17 `UIActivityIndicatorView` geometry. Spokes reveal clockwise during the drag, fire a haptic impact at the refresh threshold (iOS only), and spin when active. Reads color from `CupertinoTheme`.

```dart
SmartRefresher(
  header: const iOS17Header(),
  // ...
)
```

**Key props:**

| Prop | Type | Default | Description |
|---|---|---|---|
| `color` | `Color?` | `CupertinoTheme.primaryColor` | Spoke tint color |
| `radius` | `double` | `10.0` | Indicator radius (matches `.medium` UIActivityIndicatorView) |
| `showLastUpdated` | `bool` | `false` | Show "Updated just now" text after completion |
| `lastUpdatedTextBuilder` | `String Function(DateTime)?` | `null` | Custom timestamp format |

Uses `RefreshStyle.Follow` — the indicator scrolls with content and clips at the top, matching `UIRefreshControl` behavior.

---

## Footers

### ClassicFooter

The default footer for infinite loading. Shows a spinner and text labels.

```dart
SmartRefresher(
  enablePullUp: true,
  footer: const ClassicFooter(),
  // ...
)
```

**Key props:**

| Prop | Type | Default | Description |
|---|---|---|---|
| `loadStyle` | `LoadStyle` | `LoadStyle.ShowWhenLoading` | When the footer takes up space |
| `height` | `double` | `55.0` | Footer zone height |
| `idleText` | `String` | `'Pull up to load more'` | Label in idle state |
| `canLoadingText` | `String` | `'Release to load'` | Label when threshold crossed |
| `loadingText` | `String` | `'Loading...'` | Label during active load |
| `noDataText` | `String` | `'No more data'` | Label when `loadNoData()` called |
| `failedText` | `String` | `'Load failed'` | Label after `loadFailed()` |

---

### SkeletonFooter

An animated shimmer skeleton footer that replaces the spinner with placeholder rows while the next page loads. The shimmer sweeps across all rows as a single surface, not per-row gradients.

```dart
SmartRefresher(
  enablePullUp: true,
  footer: const SkeletonFooter(),
  // ...
)
```

**Bone style presets:**

| Style | Widget | Best for |
|---|---|---|
| `SkeletonBoneStyle.listTile` | `BoneListTile` | Avatar + title + subtitle lists |
| `SkeletonBoneStyle.card` | `BoneCard` | Image + text card feeds |
| `SkeletonBoneStyle.textBlock` | `BoneTextBlock` | Article / comment lists |
| `SkeletonBoneStyle.imageRow` | `BoneImageRow` | Horizontal image galleries |

**Key props:**

| Prop | Type | Default | Description |
|---|---|---|---|
| `boneStyle` | `SkeletonBoneStyle` | `listTile` | Preset bone layout |
| `boneBuilder` | `Widget Function(BuildContext, int)?` | `null` | Custom bone layout (overrides `boneStyle`) |
| `skeletonCount` | `int` | `3` | Number of skeleton rows to show (1–5) |
| `shimmerGradient` | `LinearGradient?` | auto (light/dark) | Custom shimmer gradient |
| `fadeInDuration` | `Duration` | `200ms` | Fade-in when loading begins |
| `fadeOutDuration` | `Duration` | `150ms` | Fade-out before collapse |

```dart
// Preset card bones
SkeletonFooter(
  boneStyle: SkeletonBoneStyle.card,
  skeletonCount: 2,
)

// Custom bone layout matching your list item
SkeletonFooter(
  skeletonCount: 3,
  boneBuilder: (context, index) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(children: [
      SkeletonBone(width: 60, height: 60, borderRadius: 4),
      const SizedBox(width: 12),
      Expanded(child: Column(children: [
        const SkeletonBone(height: 16),
        const SizedBox(height: 6),
        const SkeletonBone(height: 12, width: 140),
      ])),
    ]),
  ),
)
```

---

## Theming

All indicators read colors from `ThemeData.colorScheme` by default — no manual color props needed in a standard Material 3 app.

### Resolution order (highest to lowest priority)

```
1. Explicit widget prop       ClassicHeader(color: Colors.red)
2. SmartRefresherTheme        subtree InheritedTheme widget
3. ThemeData extension        app-wide via MaterialApp.theme
4. colorScheme.primary        Flutter's own color system
5. Hardcoded fallback         Color(0xFF2196F3)
```

### App-wide defaults via ThemeData extension

```dart
MaterialApp(
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
    useMaterial3: true,
    extensions: const [
      SmartRefresherThemeData(
        textStyle: TextStyle(fontSize: 13, fontFamily: 'Roboto'),
        material3Elevation: 8.0,
      ),
    ],
  ),
  darkTheme: ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.deepPurple,
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    // Dark mode shimmer adjusts automatically — no extra config needed
  ),
)
```

### Subtree override via SmartRefresherTheme

```dart
SmartRefresherTheme(
  data: const SmartRefresherThemeData(
    primaryColor: Colors.teal,
  ),
  child: SmartRefresher(
    header: const ClassicHeader(),   // uses teal automatically
    // ...
  ),
)
```

### Available SmartRefresherThemeData tokens

| Token | Used by | Fallback |
|---|---|---|
| `primaryColor` | All indicators | `colorScheme.primary` |
| `accentColor` | Completion icons | `colorScheme.secondary` |
| `trackColor` | M3 spinner track | `colorScheme.surfaceContainerHighest` |
| `textColor` | Status labels | `colorScheme.onSurface` |
| `textStyle` | Status labels | `TextStyle(color: textColor, fontSize: 13)` |
| `arrowColor` | Classic arrow | Mirrors `primaryColor` |
| `iconColor` | Complete/failed icon | Mirrors `primaryColor` |
| `material3BackgroundColor` | M3 floating card | `colorScheme.surfaceContainerLow` |
| `material3Elevation` | M3 floating card | `6.0` |
| `iosTickColor` | iOS17 spokes | `CupertinoColors.inactiveGray` |
| `skeletonBoneColor` | Skeleton bones | `Color(0xFFE0E0E0)` / dark: `Color(0xFF3A3A3A)` |
| `skeletonShimmerBaseColor` | Shimmer gradient | `Color(0xFFEBEBF4)` / dark: `Color(0xFF2A2A2A)` |
| `skeletonShimmerHighlightColor` | Shimmer gradient | `Color(0xFFF4F4F4)` / dark: `Color(0xFF3A3A3A)` |

---

## RefreshConfiguration (Global Defaults)

`RefreshConfiguration` sets package-wide defaults for all `SmartRefresher` widgets in its subtree. Wrap it above your `MaterialApp` or `Navigator` root.

```dart
RefreshConfiguration(
  headerTriggerDistance: 80.0,        // how far to pull before triggering refresh
  footerTriggerDistance: 15.0,        // how close to bottom before triggering load
  headerBuilder: () => const Material3Header(),  // default header for all SmartRefreshers
  footerBuilder: () => const ClassicFooter(),
  enableScrollWhenRefreshCompleted: true,
  enableLoadingWhenFailed: true,
  hideFooterWhenNotFull: false,        // hide footer if list doesn't fill the screen
  enableBallisticLoad: true,          // trigger load on fling, not just scroll stop
  child: MaterialApp(/* ... */),
)
```

**Common `RefreshConfiguration` props:**

| Prop | Type | Default | Description |
|---|---|---|---|
| `headerTriggerDistance` | `double` | `80.0` | Pull distance required to trigger refresh |
| `footerTriggerDistance` | `double` | `15.0` | Distance from bottom to auto-trigger load |
| `maxOverScrollExtent` | `double?` | `null` | Maximum overscroll distance |
| `headerBuilder` | `IndicatorBuilder?` | `null` | Default header for all children |
| `footerBuilder` | `IndicatorBuilder?` | `null` | Default footer for all children |
| `hideFooterWhenNotFull` | `bool` | `true` | Hide footer if list content is shorter than viewport |
| `enableScrollWhenRefreshCompleted` | `bool` | `false` | Allow scrolling during completion animation |
| `enableLoadingWhenFailed` | `bool` | `true` | Allow re-triggering load after failure |
| `enableBallisticLoad` | `bool` | `true` | Trigger load on momentum scroll |

---

## Custom Indicators

### Custom Header

Extend `RefreshIndicator` and `RefreshIndicatorState`:

```dart
class MyHeader extends RefreshIndicator {
  const MyHeader({super.key}) : super(height: 60.0);

  @override
  State<StatefulWidget> createState() => _MyHeaderState();
}

class _MyHeaderState extends RefreshIndicatorState<MyHeader>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void onModeChange(RefreshStatus? mode) {
    if (mode == RefreshStatus.refreshing) {
      _controller.repeat();
    } else {
      _controller.stop();
    }
    super.onModeChange(mode);
  }

  @override
  Widget buildContent(BuildContext context, RefreshStatus? mode) {
    return SizedBox(
      height: widget.height,
      child: Center(
        child: RotationTransition(
          turns: _controller,
          child: const Icon(Icons.autorenew),
        ),
      ),
    );
  }
}
```

**`RefreshIndicatorState` hooks:**

| Method | When called | Purpose |
|---|---|---|
| `buildContent(context, mode)` | Every state change and drag tick | Build the indicator UI |
| `onModeChange(mode)` | Each `RefreshStatus` transition | Trigger animations on state change |
| `onOffsetChange(offset)` | Every scroll tick during drag | React to drag distance in real time |
| `percentageToRefresh` | Read in `buildContent` | Current drag as 0.0–1.0 fraction |

**`RefreshStatus` values:**

| Value | Meaning |
|---|---|
| `idle` | No activity, header hidden |
| `canRefresh` | User is dragging, threshold not yet reached |
| `refreshing` | Refresh in progress |
| `completed` | Refresh succeeded |
| `failed` | Refresh failed |

### Custom Footer

Same pattern, extending `LoadIndicator` and `LoadIndicatorState`:

```dart
class MyFooter extends LoadIndicator {
  const MyFooter({super.key})
      : super(height: 55.0, loadStyle: LoadStyle.ShowWhenLoading);

  @override
  State<StatefulWidget> createState() => _MyFooterState();
}

class _MyFooterState extends LoadIndicatorState<MyFooter> {
  @override
  Widget buildContent(BuildContext context, LoadStatus? mode) {
    return SizedBox(
      height: widget.height,
      child: Center(child: switch (mode) {
        LoadStatus.loading  => const CircularProgressIndicator(),
        LoadStatus.noMore   => const Text('No more items'),
        LoadStatus.failed   => const Text('Load failed — scroll up to retry'),
        _                   => const SizedBox.shrink(),
      }),
    );
  }
}
```

### Using CustomHeader / CustomFooter (Simpler)

For quick one-off indicators without subclassing:

```dart
SmartRefresher(
  header: CustomHeader(
    builder: (context, mode) {
      return SizedBox(
        height: 60,
        child: Center(
          child: mode == RefreshStatus.refreshing
              ? const CircularProgressIndicator()
              : const Text('Pull to refresh'),
        ),
      );
    },
  ),
  footer: CustomFooter(
    builder: (context, mode) {
      return SizedBox(
        height: 55,
        child: Center(
          child: mode == LoadStatus.loading
              ? const CircularProgressIndicator()
              : const Text(''),
        ),
      );
    },
  ),
  controller: _controller,
  child: ListView(/* ... */),
)
```

---

## Common Patterns

### Pull-down refresh only (no infinite load)

```dart
SmartRefresher(
  controller: _controller,
  onRefresh: _onRefresh,
  // enablePullUp defaults to false — no footer needed
  child: ListView(/* ... */),
)
```

### Infinite load only (no pull-to-refresh)

```dart
SmartRefresher(
  enablePullDown: false,
  enablePullUp: true,
  controller: _controller,
  onLoading: _onLoading,
  child: ListView(/* ... */),
)
```

### Trigger refresh on screen entry

```dart
@override
void initState() {
  super.initState();
  // Trigger refresh immediately after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _controller.requestRefresh();
  });
}
```

### Refresh with error handling

```dart
Future<void> _onRefresh() async {
  try {
    final data = await api.fetchItems();
    setState(() => _items = data);
    _controller.refreshCompleted();
  } catch (_) {
    _controller.refreshFailed();   // header shows failure state
  }
}
```

### TabBarView — one controller per tab

```dart
// ✅ Correct — separate controllers
final _controllers = [
  RefreshController(),
  RefreshController(),
  RefreshController(),
];

TabBarView(children: [
  SmartRefresher(controller: _controllers[0], child: ListView(/* ... */)),
  SmartRefresher(controller: _controllers[1], child: ListView(/* ... */)),
  SmartRefresher(controller: _controllers[2], child: ListView(/* ... */)),
])
```

### NestedScrollView

Use `SmartRefresher.builder` when wrapping `NestedScrollView`:

```dart
SmartRefresher.builder(
  controller: _controller,
  onRefresh: _onRefresh,
  builder: (context, physics) => NestedScrollView(
    physics: physics,
    headerSliverBuilder: (context, _) => [
      const SliverAppBar(/* ... */),
    ],
    body: ListView(/* ... */),
  ),
)
```

### Reverse list (chat / newest-first)

```dart
SmartRefresher(
  reverse: true,
  enablePullDown: true,
  controller: _controller,
  onRefresh: _onRefresh,
  child: ListView.builder(
    reverse: true,
    itemCount: _messages.length,
    itemBuilder: (_, i) => MessageBubble(_messages[i]),
  ),
)
```

---

## Known Limitations

| Limitation | Workaround |
|---|---|
| `AnimatedList` and `SliverAnimatedList` as direct children | Convert `AnimatedList` to `SliverAnimatedList` inside a `CustomScrollView` |
| `NestedScrollView` bounce-back on quick up-swipe with `BouncingScrollPhysics` | Use `SmartRefresher.builder` + documented workaround in the wiki |
| One `RefreshController` per `SmartRefresher` | Create one controller per widget — do not share across tabs |
| `SmartRefresher` inside `ScrollBar` | Wrap `SmartRefresher` with `ScrollBar`, not the other way around |
| `WebView` as child causes freeze | Use `SmartRefresher` outside the `WebView` hierarchy |

---

## Migrating from `pull_to_refresh`

`smart_refresher` is a drop-in replacement. Update your import:

```dart
// Before
import 'package:pull_to_refresh/pull_to_refresh.dart';

// After
import 'package:smart_refresher/smart_refresher.dart';
```

All existing class names (`SmartRefresher`, `RefreshController`, `ClassicHeader`, `ClassicFooter`, `RefreshConfiguration`, `CustomHeader`, `CustomFooter`, etc.) are unchanged.

See [`MIGRATING.md`](https://github.com/ampslabs/smart-refresher/blob/main/MIGRATING.md) for a full list of differences.

---

## Contributing

Bug reports and pull requests are welcome. Please read [`CONTRIBUTING.md`](https://github.com/ampslabs/smart-refresher/blob/main/CONTRIBUTING.md) before opening an issue or PR.

For bugs, include:
- Flutter version (`flutter --version`)
- Package version
- Minimal reproduction case
- What you expected vs what happened

---

## License

MIT — see [`LICENSE`](https://github.com/ampslabs/smart-refresher/blob/main/LICENSE).

---

*`smart_refresher` is maintained by [ampslabs](https://github.com/ampslabs). It is an independent fork and is not affiliated with the original author.*