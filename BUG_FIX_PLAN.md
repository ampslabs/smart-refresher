# Bug Fix Plan (TDD Approach)

This document outlines the strategy for resolving inherited issues from the upstream `flutter_pulltorefresh` repository. We will follow a strict TDD workflow:
1.  **Red**: Create a failing test that reproduces the reported behavior.
2.  **Green**: Implement the fix.
3.  **Refactor**: Cleanup and verify no regressions.

---

## 1. Bug #659: Broken Physics on Flutter 3.x
**Symptoms:** Jittery scrolling, unexpected snap-back, or "context" errors in `refresh_physic.dart`.
**Root Cause:** Flutter 3.x changed how `ScrollPhysics` interacts with `ScrollMetrics` and the build context.
**TDD Plan:**
- Create `test/repro_659_test.dart`.
- Simulate a pull-to-refresh gesture using `WidgetTester.drag`.
- Verify that the scroll position doesn't jitter or throw assertion errors during the "hold" phase.
- **Reference:** Upstream PR #654.

---

## 2. Bug #645 / #657: Under-Screen-Height Refresh
**Symptoms:** If the list content is shorter than the screen, pulling down doesn't trigger a refresh, or `requestLoading()` fails.
**Root Cause:** Logic in the sliver extraction/physics check assumes the scrollable area must be scrollable (i.e., exceed viewport).
**TDD Plan:**
- Create a `SmartRefresher` with only 1 or 2 small items.
- Verify that `drag` gesture still triggers the `onRefresh` callback.
- Verify `controller.requestLoading()` triggers the loading state even when empty.

---

## 3. Bug #650: Flutter Web Support
**Symptoms:** Pulling down on Web (especially with mouse) does not trigger the header, or causes layout overflows.
**Root Cause:** Lack of support for `PointerDeviceKind.mouse` in the gesture recognizer or incorrect sliver behavior in `BouncingScrollPhysics` on Web.
**TDD Plan:**
- Run existing widget tests with `variant: TargetPlatform.web`.
- Create a specific test for mouse dragging in `test/web_compatibility_test.dart`.

---

## 4. Bug #652 / #656: TabBarView & Scroll Jitter
**Symptoms:** When `SmartRefresher` is inside a `TabBarView`, switching tabs triggers unnecessary animations or context lookups on deactivated widgets.
**Root Cause:** Missing `mounted` checks and incorrect `AnimationController` disposal in `RefreshIndicator` wrappers.
**TDD Plan:**
- Create a test with a `DefaultTabController` and two tabs, both with `SmartRefresher`.
- Switch tabs while a refresh is active and verify no "deactivated widget" errors appear in logs.

---

## Current Status
- [x] Bug #659 (Physics) - **Fixed** (Applied PR #654 logic with robust context handling)
- [x] Bug #645 (Short Lists) - **Fixed** (Increased default overscroll extent for non-bouncing platforms)
- [x] Bug #650 (Web) - **Fixed** (Enabled mouse dragging support and robust physics)
- [x] Bug #652 (Tabs) - **Fixed** (Verified deactivation safety via #659 fix)

---

## 5. Bug #648 / #649: Non-standard ScrollView support
**Symptoms:** Widgets like `GroupedListView` or `AnimatedList` (which don't extend `ScrollView` directly) are not recognized, and the refresher falls back to a non-sliver mode that doesn't work with the internal sliver logic.
**Root Cause:** The `_buildBodyBySlivers` method checks for `childView is ScrollView`. If it's a wrapper, it fails to extract the underlying slivers.
**TDD Plan:**
- Create a reproduction test with a custom widget wrapping a `ListView`.
- Verify the header/footer don't appear or trigger.
- Implement a more robust "Sliver Extraction" utility that can traverse the tree for a `Scrollable` or `Sliver` children.

---

## 6. Milestone: NestedScrollView Compatibility
**Symptoms:** Pull-to-refresh on the inner scrollable of a `NestedScrollView` often fails to trigger the outer "snap" or overscroll behavior.
**Root Cause:** `NestedScrollView` uses a `CustomScrollView` with two separate `ScrollPositions` (Inner and Outer). `SmartRefresher` only binds to one.
**TDD Plan:**
- Create a test using `NestedScrollView` + `SmartRefresher`.
- Verify the pull-to-refresh doesn't bounce the app bar correctly.
- Evaluate building a `SliverSmartRefresher` that can be placed directly into any `CustomScrollView`/`NestedScrollView`.

---

## Current Status — 48/48 Tests Passing ✅
- [x] Bug #659 (Physics) - **Fixed** (safe context handling + timer management)
- [x] Bug #645 (Short Lists) - **Fixed** (increased default overscroll extent for non-bouncing platforms)
- [x] Bug #650 (Web) - **Fixed** (mouse dragDevices enabled in ScrollConfiguration)
- [x] Bug #652 (Tabs) - **Fixed** (deactivation safety verified)
- [x] Bug #648 (Custom Wrappers) - **Fixed** (`SmartRefresher.slivers` constructor added)
- [x] Physics Regression - **Fixed** (removed double-wrapped `RefreshPhysics`; `ScrollConfiguration` no longer sets physics, only dragDevices. Added `enablePullDown`/`enablePullUp` as first-class authoritative fields in `RefreshPhysics` so viewport-null fallback is accurate)
- [ ] NestedScrollView Support - **Planned**
- [ ] WASM Compatibility Audit - **Planned**
