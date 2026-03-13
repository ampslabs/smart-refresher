## [Unreleased]

### Added
- Added `GlassHeader`, a frosted glass pull-to-refresh indicator with drag-driven blur, custom arc painter, Cupertino spinner state, and light/dark adaptive tinting.
- Added `GlassHeader` widget tests and a new example screen showcasing gradient and photo backgrounds.

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
