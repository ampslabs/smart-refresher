# Contributing to smart_refresher

Thanks for your interest in contributing to **smart_refresher**! We welcome bug reports, feature requests, and pull requests.

## Getting started

1. Fork this repository and clone your fork.
2. Install Flutter (stable channel, 3.10.0 or later).
3. Install dependencies:

```bash
flutter pub get
```

## Development workflow

1. Create a branch from `main`:

```bash
git checkout -b feat/your-change
```

2. Make your changes.
3. Run checks locally:

```bash
flutter analyze
flutter test
dart pub publish --dry-run
```

4. Commit with a clear message and open a pull request.

## Pull request guidelines

- Keep PRs focused and small when possible.
- Add or update tests for behavior changes.
- Update documentation when public behavior changes.
- Add a changelog entry for noteworthy user-facing updates.

## Reporting issues

Please use the issue templates for bug reports and feature requests. Include reproduction steps and environment details to help maintainers triage quickly.
