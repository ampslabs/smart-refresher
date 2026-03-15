# smart_refresher — Development Roadmap
**Package:** `smart_refresher` (fork of `https://github.com/peng8350/flutter_pulltorefresh`)  
**Publisher:** aditi.cc / ampslabs

---

## Executive Summary

The upstream `flutter_pulltorefresh` has been unmaintained since its v2.0.0 release (null-safety migration). As of March 2026, it had **15+ open issues** dating back to 2024–2025, **several unmerged community PRs**, and no Flutter 3.x+ compatibility fixes. The first roadmap period (v0.1.0 → v1.0.0, March–August 2026) prioritises fixing those inherited bugs first, then progressively enhances the package with modern Flutter patterns, better test coverage, and new indicator styles. Post-1.0 work extends the package into a full-featured, production-grade refresh ecosystem.

---

## Inherited Issues from Upstream (Must Fix)

These are unresolved issues and unmerged PRs from `https://github.com/peng8350/flutter_pulltorefresh` that we needed to address.

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

## Phase 1 — Triage & Critical Bug Fixes ✅
**Version:** v0.2.0  
**Period:** March–April 2026  
**Goal:** Stabilize the package by resolving all critical crashes and compatibility warnings that block adoption.

#### Tasks
- [x] Triage all 15 open upstream issues — Reviewed #645–#659
- [x] Fix `WidgetsBinding.instance!` warnings — Removed null-assertion across `smart_refresher.dart`
- [x] Fix unmounted widget crash on fast rebuild — Added `mounted` checks in `RefreshController`
- [x] Fix deactivated ancestor lookup — Cancel animations on deactivation
- [x] Fix AnimationController elapsed time assertion on iOS
- [x] Fix RefreshController reuse assertion
- [x] Migrate to Android v2 Embedding — Regenerated Android folder and moved to Kotlin
- [x] Fix Android jvmTarget deprecation warnings

**Deliverable:** v0.2.0 — zero critical crashes on Flutter 3.x.

---

## Phase 2 — Compatibility & Modern Platform Support ✅
**Version:** v0.3.0  
**Period:** May 2026  
**Goal:** Expand the range of supported child widgets and ensure compatibility with modern deployment targets like WASM and Desktop.

#### Tasks
- [x] Non-ScrollView child detection — Added `SmartRefresher.slivers` constructor for direct sliver support
- [x] NestedScrollView workaround — Implement `NestedScrollViewRefresher` for `BouncingScrollPhysics`
- [x] WASM Support — Audit and fix JS-interop and platform-specific code
- [x] Desktop Support (Mouse/Trackpad) — Enabled mouse dragging support and robust physics
- [x] Multi-Sliver Support — Improved handling of complex layouts with multiple slivers
- [x] ScrollBar compatibility — Fix sliver composition order
- [x] PageView / TabBarView safety — Resolved context safety and deactivation crashes

**Deliverable:** v0.3.0 — support for more child widget types, no known critical layout bugs.

---

## Phase 3 — Testing & Code Quality ✅
**Version:** v0.4.0  
**Period:** June 2026  
**Goal:** Increase confidence in the codebase with automated tests so future changes don't regress.

#### Tasks
- [x] Widget tests for core refresh/load flow — Pull-to-refresh trigger, completion, error state, load-more trigger, completion
- [x] Widget tests for controller lifecycle — `requestRefresh`, `requestLoading`, `refreshCompleted`, `loadComplete`, `dispose`
- [x] Widget tests for edge cases — Fast rebuild crash, tab switching, controller reuse attempt
- [x] Integration test example — Working example app with integration tests for smoke-testing across platforms
- [x] CI matrix — Extended GitHub Actions to run tests against Flutter stable, beta, and the two previous stable versions
- [x] Lint cleanup — Enabled stricter analysis options, fixed all `info`-level warnings, enforced with CI

**Deliverable:** v0.4.0 — meaningful test coverage, green CI on Flutter stable + beta.

---

## Phase 4 — Modern Indicator Styles & Accessibility ✅
**Version:** v0.5.0  
**Period:** July 2026  
**Goal:** Ship contemporary indicator designs and ensure they are accessible to all users.

#### Tasks
- [x] Material 3 indicator — Updated `CircularProgressIndicator` aesthetics and M3 motion curves
- [x] iOS 17-style indicator — Native activity indicator style introduced in iOS 17
- [x] Glass/Frosted header — Blur + translucency using `BackdropFilter`, configurable opacity and tint colour; pairs cleanly with `SliverAppBar` and transparent `AppBar` setups
- [x] Accessibility (Semantics) — Proper semantic labels and hints on all indicators for TalkBack/VoiceOver
- [x] Skeleton loading footer — Animated shimmer/skeleton footer indicator for paginating
- [x] Indicator theming API — Automatic colour picking from `ThemeData`
- [x] Demo app update — Updated example app to showcase all new indicators and accessibility features

**Deliverable:** v0.5.0 — Material 3, iOS 17, glass, and skeleton indicators; theming support; full a11y.

---

## Phase 5 — API Modernisation & DX
**Version:** v1.0.0  
**Period:** August 2026  
**Goal:** Deliver a stable, polished v1.0.0 with a modern Dart API, world-class documentation, and a clean path for consumers migrating from the upstream package.

#### Tasks
- [x] `RefreshController` → add `ValueNotifier`-based state exposure
- [x] `RefreshController.stream` — Expose state as a `Stream<RefreshStatus>` for reactive consumers
- [x] `onRefreshFailed` callback — Distinct error-state callback; lets the indicator show failure without the consumer managing it manually
- [x] Haptic feedback opt-in — `HapticFeedback.mediumImpact()` at pull threshold, disabled by default
- [x] Riverpod / Provider / BLoC integration examples
- [ ] Hosted Documentation Site — Docusaurus or Mintlify with rich live code previews
- [x] `SmartRefresher.builder` constructor — Slots for empty/error/loading states
- [x] Deprecate legacy Chinese comments — 100% English across all source files
- [x] Comprehensive API docs — Rich `///` doc comments for all public members
- [ ] pub.dev score improvement — Target 140+ pub points
- [x] Migration guide — Publish `MIGRATING.md`

**Deliverable:** v1.0.0 — stable API, 140+ pub points, migration guide, full documentation.

---

## Phase 6 — Code Cleanup & Performance
**Version:** v1.1.0  
**Period:** September–October 2026  
**Goal:** Reduce technical debt accumulated during rapid bug-fix phases and establish measurable performance baselines that prevent regressions.

### Code Cleanup
- [x] **Dead code removal** — Audit all files for unreachable branches, unused fields, and deprecated internal helpers left over from the upstream codebase; remove without replacement
- [x] **Consistent naming conventions** — Align all identifiers with Dart's official style guide (lowerCamelCase, no Hungarian prefixes, no single-letter variables outside loops)
- [x] **Extract magic constants** — Move hardcoded numeric and string literals into named constants or a dedicated `SmartRefresherDefaults` class
- [x] **Decompose `SmartRefresherState`** — The main state class is currently a monolith; split drag handling, animation control, and sliver composition into focused mixins
- [x] **Standardise async patterns** — Replace ad-hoc `Future.delayed` workarounds with proper `TickerProvider` / `SchedulerBinding.addPostFrameCallback` patterns throughout
- [x] **Remove all upstream TODO/FIXME comments** — Either resolve the underlying issue or log a tracked GitHub issue; no stale comments in v1.1

### Performance
- [ ] **Rebuild minimisation** — Wrap indicator widgets in `RepaintBoundary` and audit `setState` call sites so only the indicator layer repaints during a drag, not the full list
- [ ] **Jank profiling baseline** — Record DevTools timeline traces for 60 fps and 120 fps devices on a 1 000-item list; commit traces as reference benchmarks in `/benchmarks`
- [ ] **Lazy header construction** — Defer indicator widget tree construction until the first pull gesture rather than building on mount
- [ ] **Animation curve audit** — Replace any linear animation fallbacks with hardware-accelerated curves; ensure all `AnimationController` durations are within Flutter's 16 ms frame budget at rest
- [ ] **Memory leak scan** — Run `flutter test --track-widget-creation` and DevTools memory profiler; fix any `AnimationController` or `ScrollController` instances not disposed on widget removal
- [ ] **`const` propagation** — Audit all indicator widgets for missing `const` constructors; enable `prefer_const_constructors` lint rule and fix all violations

**Deliverable:** v1.1.0 — measurably cleaner codebase, no-jank scrolling at 120 fps, documented performance baselines.

---

## Phase 7 — Security
**Version:** v1.2.0  
**Period:** November 2026  
**Goal:** Establish security hygiene appropriate for a widely-used Flutter package, covering supply-chain, dependency management, and safe API design.

### Dependency & Supply-Chain
- [ ] **Dependency audit** — Run `dart pub outdated` and `dart pub deps` to identify transitive dependencies with known CVEs; pin or replace as needed
- [ ] **Remove unused transitive deps** — Eliminate any packages pulled in by the upstream fork that are no longer referenced
- [ ] **Enable Dependabot** — Configure `dependabot.yml` for automated weekly dependency PRs on both `pubspec.yaml` and GitHub Actions workflows
- [ ] **Pin GitHub Actions to commit SHA** — Replace `uses: actions/checkout@v4` version tags with full SHA references to prevent supply-chain attacks via tag mutation
- [ ] **SBOM generation** — Add a step in CI that generates a Software Bill of Materials (`sbom.json`) on every release using `cyclonedx-dart`

### Safe API Design
- [ ] **Input validation on `RefreshController`** — Guard `requestRefresh`, `requestLoading`, and `scrollTo` against null, negative, or out-of-range arguments with clear `AssertionError` messages in debug mode
- [ ] **`onRefreshFailed` exception surface** — Ensure exceptions thrown inside the consumer-supplied refresh callback are caught, surfaced via `onRefreshFailed`, and never silently swallowed
- [ ] **No `dynamic` in public API** — Audit all public method signatures; replace `dynamic` with typed alternatives or generics
- [ ] **Sensitive data guard** — Document explicitly that `SmartRefresher` callbacks must not be used to cache or log scroll positions or user data; add a note in API docs

### Disclosure & Hardening
- [ ] **`SECURITY.md`** — Publish a responsible disclosure policy describing how to privately report vulnerabilities, the response SLA, and the CVE assignment process
- [ ] **Automated secret scanning** — Enable GitHub's native secret scanning and add a `gitleaks` pre-commit hook to the repo to prevent accidental credential commits
- [ ] **Static analysis hardening** — Enable `avoid_dynamic_calls`, `always_use_package_imports`, and `no_runtimeType_toString` lints; fix all violations before release

**Deliverable:** v1.2.0 — published `SECURITY.md`, clean dependency tree, hardened public API, automated secret scanning in CI.

---

## Phase 8 — Indicator Expansion & Visual Polish
**Version:** v1.3.0  
**Period:** December 2026  
**Goal:** Expand the indicator library and give designers first-class tooling.

- [ ] **Lottie/Rive header support** — Promote from "Out of Scope"; the `SmartRefresher.builder` constructor in v1.0 makes this straightforward
- [ ] **Glassmorphism variants** — Extend the glass header with coloured tints, gradient blur, and border shimmer
- [ ] **Elastic/spring header** — Physics-based stretch effect common in high-end iOS apps
- [ ] **Figma component kit** — Design tokens for glass, Material 3, and iOS 17 indicators so designers can prototype without writing code
- [ ] **Riverpod / BLoC companion package** — Ship `smart_refresher_riverpod` as a separate package with codegen snippets
- [ ] **Flutter DevTools extension** — Inspector panel showing refresh state, controller lifecycle, and event timeline in real time

**Deliverable:** v1.3.0 — Lottie/Rive support, glassmorphism variants, Figma kit, DevTools extension.

---

## Phase 9 — Scroll Intelligence & Architecture
**Version:** v2.0.0  
**Period:** Q1 2027  
**Goal:** Rethink the scroll integration model and ship features that require breaking API changes — saved for a major version to give consumers sufficient migration time.

- [ ] **Sliver-based infinite scroll** — Native integration without a wrapper widget using `SliverFillRemaining`
- [ ] **`AnimatedList` / `SliverAnimatedList` support** — Now feasible as Flutter has matured since the upstream fork
- [ ] **Debounce & cooldown API** — `RefreshController.cooldown(Duration)` to prevent rapid re-triggers
- [ ] **Declarative controller** — Replace `RefreshController` with a purely reactive `SmartRefreshNotifier` (`ChangeNotifier`-based); imperative `requestRefresh()` retained as a convenience shim
- [ ] **Parallax header API** — First-class `SmartRefresher.parallax` constructor with configurable scroll factor and min/max bounds
- [ ] **Multi-axis support** — Horizontal pull-to-refresh for carousels and horizontal paging lists
- [ ] **Comprehensive migration guide** — `MIGRATING_v2.md` with before/after code samples for every breaking change

**Deliverable:** v2.0.0 — declarative API, parallax header, horizontal refresh, infinite scroll without a wrapper.

---

## Summary Timeline

| Period | Phase | Version | Key Deliverable |
|--------|-------|---------|-----------------|
| March–April 2026 | Critical Bug Fixes | v0.2.0 | Zero crashes on Flutter 3.x |
| May 2026 | Compatibility | v0.3.0 | NestedScrollView, ScrollBar, custom children |
| June 2026 | Testing & CI | v0.4.0 | Widget tests, CI matrix |
| July 2026 | Modern Indicators | v0.5.0 | Material 3, iOS 17, glass header, skeleton footer |
| August 2026 | API & v1.0 | v1.0.0 | Clean API, full docs, migration guide |
| Sep–Oct 2026 | Code Cleanup & Performance | v1.1.0 | Refactored internals, 120 fps baselines |
| November 2026 | Security | v1.2.0 | SECURITY.md, dependency hardening, safe API |
| December 2026 | Indicator Expansion | v1.3.0 | Lottie/Rive, Figma kit, DevTools extension |
| Q1 2027 | Architecture | v2.0.0 | Declarative API, parallax, multi-axis, infinite scroll |

---

## Out of Scope (Deferred Post-2.0)

- Advanced scroll sync for multi-pane desktop layouts.
- `SliverAppBar` stretching integration (requires Flutter SDK changes).
- First-party video/media pull-to-refresh gestures.
- Server-driven indicator configuration via remote config.

---
