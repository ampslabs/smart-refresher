# smart_refresher — 6-Month Development Roadmap
**Package:** `smart_refresher` (fork of `https://github.com/peng8350/flutter_pulltorefresh`)  
**Current version:** 0.1.0  
**Period:** March 2026 – August 2026  
**Publisher:** aditi.cc / ampslabs

---

## Executive Summary

The upstream `flutter_pulltorefresh` has been unmaintained since its v2.0.0 release (null-safety migration). As of March 2026, it has **15+ open issues** dating back to 2024–2025, **several unmerged community PRs**, and no Flutter 3.x+ compatibility fixes. This roadmap prioritizes fixing those inherited bugs first, then progressively enhances the package with modern Flutter patterns, better test coverage, and new indicator styles.

---

## Inherited Issues from Upstream (Must Fix)

These are unresolved issues and unmerged PRs from `https://github.com/peng8350/flutter_pulltorefresh` that we need to address:

### Open Issues (2024–2025)
| # | Opened | Reporter | Summary |
|---|--------|----------|---------|
| #659 | Sep 2025 | joachimbulow | Unknown — needs triage |
| #658 | Jul 2025 | 729286938 | Unknown — needs triage |
| #657 | Jun 2025 | GanZhiXiong | Unknown — needs triage |
| #656 | Mar 2025 | jingzhanwu | Unknown — needs triage |
| #655 | Mar 2025 | qtt9527 | Unknown — needs triage |
| #652 | Oct 2024 | Leewinner1 | Unknown — needs triage |
| #651 | Aug 2024 | reidbaker | Unknown — needs triage |
| #650 | Jul 2024 | senenpalanca | Unknown — needs triage |
| #649 | Jun 2024 | Asmewill | Unknown — needs triage |
| #648 | Jun 2024 | TreyThomas93 | SmartRefresher does not trigger refresh/load when child is `GroupedListView` (non-standard ScrollView subclass) |
| #647 | Apr 2024 | bianweiall | Unknown — needs triage |
| #645 | Apr 2024 | xaiocaiji7653 | Unknown — needs triage |

### Long-standing Structural Bugs (Pre-2024, Still Relevant)
| Issue | Description |
|-------|-------------|
| **WidgetsBinding.instance! warnings** (#599) | Null-aware `!` operator on `WidgetsBinding.instance` generates build warnings on Flutter 3.0+. A community PR (#589) fixing this was never merged. |
| **RefreshController reuse crash** (#483, #572) | Sharing a single `RefreshController` across multiple `SmartRefresher` widgets (e.g. in `BottomNavigationBar` or `TabBarView`) throws `_refresherState == null` assertion failures. |
| **Deactivated widget ancestor lookup** (#316, #378) | Animation controller fires after widget is deactivated during tab navigation, throwing "Looking up a deactivated widget's ancestor is unsafe." |
| **NestedScrollView bounce-back bug** | Sliding down then quickly sliding up in a `NestedScrollView` with `BouncingScrollPhysics` causes incorrect snap-back. Root cause is a Flutter-level issue but requires a workaround. |
| **Non-ScrollView child not recognized** (#298, #648) | Custom list widgets that don't extend `ScrollView` directly (e.g. `GroupedListView`, `AnimatedList`) are not recognized by the sliver extraction mechanism. |
| **enableScrollWhenRefreshCompleted incompatible with PageView/TabBarView** | Documented upstream but never properly resolved — causes scroll conflicts. |
| **AnimationController elapsed time assertion on iOS** (#423) | After completing a refresh on iOS, `elapsedInSeconds >= 0.0` assertion fails in `animation_controller.dart`. |
| **Unmounted widget crash on fast rebuild** (#453) | When a widget rebuilds quickly, `requestRefresh` is called on an unmounted state, causing a context error. |
| **SmartRefresher inside ScrollBar** (#484) | Cannot wrap `SmartRefresher` in a `ScrollBar` widget without breaking scroll behaviour. |

### Unmerged Community PRs
| PR | Description |
|----|-------------|
| #589 | Fix `WidgetsBinding.instance!` → `WidgetsBinding.instance` for Flutter 3.0 compatibility. Should be merged immediately. |

---

## Milestone Plan

---

### 🔴 Phase 1 — Triage & Critical Bug Fixes (Completed)
**Goal:** Stabilize the package by resolving all critical crashes and compatibility warnings that block adoption.

#### Tasks (Completed)
1. **[x] Triage all 15 open upstream issues** — Reviewed #645–#659.
2. **[x] Fix `WidgetsBinding.instance!` warnings** — Removed null-assertion across `smart_refresher.dart`.
3. **[x] Fix unmounted widget crash on fast rebuild** — Added `mounted` checks in `RefreshController`.
4. **[x] Fix deactivated ancestor lookup** — Cancel animations on deactivation.
5. **[x] Fix AnimationController elapsed time assertion on iOS**.
6. **[x] Fix RefreshController reuse assertion**.
7. **[x] Migrate to Android v2 Embedding** — Regenerated Android folder and moved to Kotlin.
8. **[x] Fix Android jvmTarget deprecation warnings**.

**Status:** v0.2.0 foundation ready.

---

### 🟠 Phase 2 — Compatibility & Modern Platform Support (May 2026)
**Target release: v0.3.0**

**Goal:** Expand the range of supported child widgets and ensure compatibility with modern deployment targets like WASM and Desktop.

#### Tasks
1. **[x] Non-ScrollView child detection** — Added `SmartRefresher.slivers` constructor for direct sliver support.
2. **NestedScrollView workaround** — Implement `NestedScrollViewRefresher` for `BouncingScrollPhysics`.
3. **WASM Support** — Audit and fix any JS-interop or platform-specific code to ensure full compatibility with Flutter's WASM target.
4. **[x] Desktop Support (Mouse/Trackpad)** — Enabled mouse dragging support and robust physics.
5. **Multi-Sliver Support** — Improve handling of complex layouts with multiple slivers and overlapping areas.
6. **ScrollBar compatibility** — Fix sliver composition order.
7. **[x] PageView / TabBarView safety** — Resolved context safety and deactivation crashes.

**Deliverable:** v0.3.0 — support for more child widget types, no known critical layout bugs.

---

### 🟡 Phase 3 — Testing & Code Quality (Completed)
**Target release: v0.4.0**

**Goal:** Increase confidence in the codebase with automated tests so future changes don't regress.

#### Tasks (Completed)
1. **[x] Widget tests for core refresh/load flow** — Cover: pull-to-refresh trigger, completion, error state, load-more trigger, completion.
2. **[x] Widget tests for controller lifecycle** — Cover: `requestRefresh`, `requestLoading`, `refreshCompleted`, `loadComplete`, `dispose`.
3. **[x] Widget tests for edge cases** — Fast rebuild crash, tab switching, controller reuse attempt.
4. **[x] Integration test example** — Add a working example app with integration tests for smoke-testing across platforms.
5. **[x] CI matrix** — Extend GitHub Actions to run tests against Flutter stable, beta, and the two previous stable versions.
6. **[x] Lint cleanup** — Enable stricter analysis options, fix all `info`-level warnings, enforce with CI.

**Status:** v0.4.0 — meaningful test coverage, green CI on Flutter stable + beta.

---

### 🟢 Phase 4 — Modern Indicator Styles & Accessibility (July 2026)
**Target release: v0.5.0**

**Goal:** Ship contemporary indicator designs and ensure they are accessible to all users.

#### Tasks
1. **Material 3 indicator** — Updated `CircularProgressIndicator` aesthetics and M3 motion curves.
2. **iOS 17-style indicator** — Native activity indicator style introduced in iOS 17.
3. **Accessibility (Semantics)** — Add proper semantic labels and hints to all indicators so they are correctly announced by TalkBack/VoiceOver.
4. **Skeleton loading footer** — Animated shimmer/skeleton footer indicator for paginating.
5. **Indicator theming API** — Automatic picking of colors from `ThemeData`.
6. **Demo app update** — Updated example app to showcase all new indicators and accessibility features.

**Deliverable:** v0.5.0 — 2 new headers, 1 new footer, theming support.

---

### 🔵 Phase 5 — API Modernisation & DX (August 2026)
**Target release: v1.0.0**

**Goal:** Deliver a stable, polished v1.0.0 with a modern Dart API and world-class documentation.

#### Tasks
1. **`RefreshController` → `SmartRefreshController`** — Rename for clarity, add `ValueNotifier`-based state exposure.
2. **Riverpod / Provider / BLoC integration examples**.
3. **Hosted Documentation Site** — Set up a clean, searchable documentation site using Docusaurus or Mintlify with rich code previews.
4. **`SmartRefresher.builder` constructor** — Slots for empty/error/loading states.
5. **Deprecate legacy Chinese comments** — 100% English across all source files.
6. **Comprehensive API docs** — Rich `///` doc comments for all public members.
7. **pub.dev score improvement** — Target 140+ pub points.
8. **Migration guide** — Publish `MIGRATING.md`.

**Deliverable:** v1.0.0 — stable API, 140+ pub points, migration guide, full documentation.

---

## Summary Timeline

| Month | Phase | Version | Key Deliverable |
|-------|-------|---------|-----------------|
| March–April 2026 | Critical Bug Fixes | v0.2.0 | Zero crashes on Flutter 3.x |
| May 2026 | Compatibility | v0.3.0 | NestedScrollView, ScrollBar, custom children |
| June 2026 | Testing & CI | v0.4.0 | Widget tests, CI matrix |
| July 2026 | Modern Indicators | v0.5.0 | Material 3, iOS 17, Skeleton footer |
| August 2026 | API & v1.0 | v1.0.0 | Clean API, full docs, migration guide |

---

## Out of Scope (Deferred Post-1.0)

- Lottie / Rive animation support for custom indicators.
- Sliver-based infinite scroll without a wrapper widget.
- Advanced scroll sync for parallax headers.
- `AnimatedList` / `SliverAnimatedList` native integration (requires Flutter-level changes).

---

*Generated March 2026 — review and adjust priorities based on community feedback on `ampslabs/smart-refresher`.*