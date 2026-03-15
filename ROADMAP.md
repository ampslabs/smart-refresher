# smart_refresher — Development Roadmap


## Phase 8 — Indicator Expansion & Visual Polish
**Version:** v1.1.0  
**Period:** December 2026  
**Goal:** Expand the indicator library and give designers first-class tooling.

- [ ] **Lottie/Rive header support** — Promote from "Out of Scope"; the `SmartRefresher.builder` constructor in v1.0 makes this straightforward
- [ ] **Glassmorphism variants** — Extend the glass header with coloured tints, gradient blur, and border shimmer
- [ ] **Elastic/spring header** — Physics-based stretch effect common in high-end iOS apps
- [ ] **Figma component kit** — Design tokens for glass, Material 3, and iOS 17 indicators so designers can prototype without writing code
- [ ] **Riverpod / BLoC companion package** — Ship `smart_refresher_riverpod` as a separate package with codegen snippets
- [ ] **Flutter DevTools extension** — Inspector panel showing refresh state, controller lifecycle, and event timeline in real time

**Deliverable:** v1.1.0 — Lottie/Rive support, glassmorphism variants, Figma kit, DevTools extension.

---

## Phase 9 — Scroll Intelligence & Architecture
**Version:** v2.0.0  
**Goal:** Rethink the scroll integration model and ship features that require breaking API changes — saved for a major version to give consumers sufficient migration time.

- [ ] **Sliver-based infinite scroll** — Native integration without a wrapper widget using `SliverFillRemaining`
- [ ] **`AnimatedList` / `SliverAnimatedList` support** — Now feasible as Flutter has matured since the upstream fork
- [ ] **Debounce & cooldown API** — `RefreshController.cooldown(Duration)` to prevent rapid re-triggers
- [ ] **Declarative controller** — Replace `RefreshController` with a purely reactive `SmartRefreshNotifier` (`ChangeNotifier`-based); imperative `requestRefresh()` retained as a convenience shim
- [ ] **Parallax header API** — First-class `SmartRefresher.parallax` constructor with configurable scroll factor and min/max bounds
- [ ] **Multi-axis support** — Horizontal pull-to-refresh for carousels and horizontal paging lists
- [ ] **Comprehensive migration guide** — `MIGRATING.md` with before/after code samples for every breaking change

**Deliverable:** v2.0.0 — declarative API, parallax header, horizontal refresh, infinite scroll without a wrapper.

---


## Out of Scope (Deferred Post-2.0)

- Advanced scroll sync for multi-pane desktop layouts.
- `SliverAppBar` stretching integration (requires Flutter SDK changes).
- First-party video/media pull-to-refresh gestures.
- Server-driven indicator configuration via remote config.

---
