## 0.1.0

- **Initial Fork Release**: Rebranded package as `smart_refresher` and initialized maintained fork release line.
- **Documentation & Localization**:
  - Added comprehensive English documentation comments to all public members.
  - Translated all source code comments and header timestamps from Chinese to English.
  - Fully localized the example application UI and developer comments into English.
  - Enabled and fulfilled `public_member_api_docs`, `comment_references`, and other documentation lint rules.
- **Bug Fixes**:
  - Resolved a state transition bug in "Two-Level" (Second Floor) mode where layout compensation incorrectly triggered premature closure.
  - Fixed a compilation error caused by an invalid `const` instance field in `SmartRefresher`.
  - Improved type safety for callbacks and `Future` return types to comply with `strict-raw-types`.
- **Infrastructure**:
  - Updated CI configuration to trigger on pushes to the `main` branch.
  - Fixed various analyzer warnings and improved codebase consistency.
  - Added `SECURITY.md` and Mintlify-style documentation in `doc/`.
