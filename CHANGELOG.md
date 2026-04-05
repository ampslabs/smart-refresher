## 1.0.1

### Security & Maintenance
- **Vulnerability Patches**: Resolved several high-severity security vulnerabilities in the documentation project (`doc/`) by updating transitive dependencies (`defu`, `picomatch`, `h3`, `smol-toml`).
- **Dependency Updates**: Updated `iconify_sdk` to `1.0.0` and `flutter_lints` to `6.0.0` in the example application.
- **CI/CD Reliability**: Fixed integration failures in the example project by adding missing `flutter_driver` dependencies and suppressing internal lint warnings for the test extension.

### Added
- **WaterDropHeader Showcase**: Added a dedicated screen in the example application to demonstrate the `WaterDropHeader` in action.
- **Improved Authentic Droplet Effect**: Enhanced the `WaterDropHeader` to accurately replicate the original "dropping" animation. The droplet now stretches, "breaks" away from the base, and falls during the refresh trigger, providing a more polished and nostalgic experience.

### Refactoring & Quality
- **Accessibility Fix**: Resolved a regression in `WaterDropHeader` by consolidating `Semantics` widgets, ensuring screen readers correctly announce status changes.
- **Code Formatting**: Applied global `dart format` across the entire library and example projects.
- **Test Verification**: Confirmed 100% pass rate for the full test suite (174/174 tests).

## 1.0.0

### Added
- **ElasticHeader**: A new physics-based stretch header that provides an elastic visual effect, common in premium iOS apps. Includes real-time stretch factor calculation and integration with lazy construction.
- **Example App Update**: Added `ElasticHeaderScreen` to the example app, showcasing the ElasticHeader with a hero image.

### Security & Compliance

- **Input Validation**: Added robust `AssertionError` guards to `requestRefresh`, `requestTwoLevel`, and `requestLoading` in `RefreshController` for safer API usage.
- **Exception Surfacing**: Refactored internal callback execution to ensure `onRefreshFailed` and `onLoadingFailed` robustly catch and surface both synchronous and asynchronous exceptions.
- **Typed API**: Hardened internal logic to eliminate `dynamic` type usage in callback execution paths.
- **Sensitive Data Guard**: Added a security note to `SmartRefresher`'s API documentation advising against using callbacks for sensitive data handling.
- **`SECURITY.md` Policy**: Published a formal security policy with private reporting channels, acknowledgment SLAs, and an incident response process.
- **Static Analysis Hardening**: Enabled `always_use_package_imports` and `no_runtimeType_toString` lints, converting all relative imports to package imports and fixing violations.
- **Secret Scanning**: Configured `gitleaks` with `.gitleaks.toml` and documented pre-commit hook usage for automated credential detection.
- **Supply Chain Security**: Pinned all GitHub Action workflows (`ci.yml`, `publish.yml`, `stale.yml`) to full commit SHAs for enhanced protection against tag mutation attacks.
- **Automated Updates**: Configured Dependabot (`.github/dependabot.yml`) for weekly dependency and GitHub Actions updates.
- **SBOM Generation**: Integrated `cyclonedx-dart` into the release pipeline (`publish.yml`) and added a dry-run to `ci.yml` for generating Software Bill of Materials.
- **Dependency Audit**: Removed `iconify_sdk` from root `pubspec.yaml` to `example/pubspec.yaml` as it was only used in the demo app.

### Refactoring & Code Quality
- Removed all blanket `ignore_for_file` suppressions from core library files, replacing them with surgical line-level `// ignore:` comments where accessing Flutter internals is necessary.
- Replaced protected `setState()` calls in `RefreshController` with the public `update()` method from `IndicatorStateMixin`.
- Removed unnecessary `ignore_for_file: camel_case_types` from `ios17_indicator.dart`.


### Performance & Code Cleanup
- **Rebuild Minimisation**: Wrapped indicator content (`buildContent`) within both `RefreshIndicatorState` and `LoadIndicatorState` with `RepaintBoundary` to isolate repaints during drag gestures.
- **Lazy Header Construction**: Implemented lazy header construction; the header's child widget tree is now deferred until the first pull gesture, improving initial mount performance.
- **Jank Profiling Baseline**: Established a performance baseline with a new `integration_test` macrobenchmark script in `/benchmarks`, recording timeline traces for scroll and refresh interactions.
- **Animation Curve Audit**: Ensured all `AnimationController` instances use appropriate hardware-accelerated curves and have explicit durations, confirming compliance with Flutter's 16ms frame budget.
- **Memory Leak Scan**: Verified proper disposal of all `AnimationController` and `ScrollController` instances through `flutter test --track-widget-creation` and code audit.
- **`const` Propagation**: Achieved 100% compliance with `prefer_const_constructors` lint rule across indicator widgets.
- **Dead Code Removal**: Removed unused imports (`slivers.dart`) and addressed boilerplate TODOs.
- **Consistent Naming**: Refactored cryptic or single-letter variables (e.g., `e` to `element`, `u` to `shouldUpdate`) to descriptive names in line with Dart's style guide.
- **Magic Constants Extraction**: Centralized hardcoded numeric and string literals (e.g., animation durations, spring physics, icon sizes, spacing) into `SmartRefresherConstants` in `enums.dart`.
- **Standardized Async Patterns**: Replaced ad-hoc `Future.delayed` workarounds with `WidgetsBinding.instance.addPostFrameCallback` for single-frame waits and `endRefreshWithTimer` for timed delays.


### API Modernisation & Developer Experience

- **`RefreshController.stream`**: Added a `.stream` getter to `RefreshController` as an alias for `.headerStream`, providing a reactive entry point for refresh status.
- **`ValueNotifier` State Exposure**: Enhanced `RefreshController` with `ValueNotifier`-based state exposure (`contentStatus`, `headerMode`, `footerMode`), enabling easier integration with state management solutions.
- **`onRefreshFailed` Callback**: Introduced a dedicated `onRefreshFailed` callback for `SmartRefresher`, allowing indicators to show distinct error states without manual consumer management.
- **Haptic Feedback Opt-in**: Implemented optional haptic feedback (`HapticFeedback.mediumImpact()`) at the pull threshold, disabled by default via `RefreshConfiguration`.
- **Integration Examples**: Added comprehensive examples for Riverpod, Provider, and BLoC state management patterns in the example app.
- **`SmartRefresher.builder` Constructor**: Introduced `SmartRefresher.builder` for declarative UI composition, providing dedicated slots for `empty`, `error`, and `loading` states.
- **English Comments**: Ensured 100% of source code comments are in English, translating all legacy Chinese comments.
- **Comprehensive API Docs**: Significantly improved and added rich `///` documentation for all public members, including `SmartRefresher.builder`, `SmartRefresher.slivers`, `RefreshNotifier`, and `IndicatorStateMixin`.
- **Migration Guide**: Published `MIGRATING.md` to guide users transitioning from the upstream `pull_to_refresh` package.

## 0.2.0

### New Indicators & Theming
- **Material 3 Header**: Added `Material3Header`, a floating pull-to-refresh indicator using the 2024 circular progress design with theme-aware colors and dedicated completion/error states.
- **iOS 17 Header**: Added `iOS17Header`, featuring native iOS 17 tick geometry, threshold scale pop, haptic feedback (iOS only), and optional last-updated text.
- **Skeleton Footer**: Added `SkeletonFooter` with four built-in bone styles (`listTile`, `card`, `textBlock`, `imageRow`) and a shared shimmer engine for modern pagination placeholders.
- **Advanced Theming**: Introduced `SmartRefresherThemeData` (ThemeData extension) and `SmartRefresherTheme` (InheritedWidget) for app-wide or subtree indicator styling.
- **Color Resolution**: Implemented `IndicatorThemeData` to automatically resolve indicator colors from `ColorScheme` with safe Cupertino fallbacks.

### Accessibility
- **Semantic Labels**: Added `semanticsLabel` and `semanticsHint` to all built-in indicators.
- **Localized Defaults**: Proper localized labels (e.g., "Pull down Refresh", "Refreshing…") are now announced by screen readers out of the box.

### Layout & Compatibility
- **Multi-Sliver Support**: Added `center` property to `SmartRefresher` and `SmartRefresher.slivers` to support bidirectional scrolling and complex sliver layouts.
- **Sliver Geometry Fixes**: Improved `SliverRefresh` to correctly respect `constraints.overlap` from pinned slivers, preventing headers from being hidden under app bars.
- **ScrollBar Compatibility**: Fixed scrollbar thumb jitter by implementing correct scroll offset correction during indicator layout transitions.
- **WASM Compatible**: Audited and confirmed full compatibility with Flutter's WASM web target.
- **Smart Insertion**: Updated `SmartRefresher.slivers` to detect if indicators are manually placed in the sliver list, avoiding redundant auto-insertion.

### Bug Fixes & Maintenance
- **CI Stability**: Resolved a GitHub Actions failure by removing incorrectly checked-in temporary files (`.flutter-plugins-dependencies`).
- **Web Assets**: Added missing `cupertino_icons` dependency to the example app to ensure correct font rendering on web/WASM targets.
- **Code Quality**: Resolved several analyzer warnings related to deprecated members (`withOpacity` -> `withValues`) and unused imports.

### Infrastructure & Testing
- **New Test Suites**: Added `test/accessibility_test.dart`, `test/complex_slivers_test.dart`, and `test/scrollbar_test.dart` covering edge cases in complex layouts.
- **Dependency Update**: Raised minimum Flutter SDK to 3.27.0 to support modern Material 3 color roles.

## 0.1.0

- **Initial Fork Release**: Rebranded package as `smart_refresher` and initialized maintained fork release line.
- **Documentation & Localization**:
  - Added comprehensive English documentation comments to all public members.
  - Translated all source code comments and header timestamps from Chinese to English.
  - Fully localized the example application UI and developer comments into English.
- **Bug Fixes**:
  - Resolved a state transition bug in "Two-Level" (Second Floor) mode.
  - Fixed a compilation error caused by an invalid `const` instance field.
- **Infrastructure**:
  - Updated CI configuration.
  - Added `SECURITY.md` and Mintlify-style documentation in `doc/`.
