---
name: code-review
description: Use before committing, when creating a PR, or when asked to review a diff/PR across masterg_api and masterg_app.
---

# Code Review & PR Review Checklist

Run `git diff main...HEAD` to inspect changes. Review every modified file against this checklist:

## 1. Backend Security & Data Protection (`masterg_api/`)
- [ ] Protected endpoints enforce `@permission_classes([IsAuthenticated])`.
- [ ] No `User.objects.first()` fallbacks in views handling user progression.
- [ ] Passwords and secrets are never committed in plaintext or logged.
- [ ] All database queries filter by the authenticated user (`request.user`).
- [ ] Database migrations are checked with `python manage.py makemigrations --check --dry-run`.
- [ ] SimpleJWT token refresh works for expired access tokens.

## 2. Frontend Polish & UX Integrity (`masterg_app/`)
- [ ] Every screen with async data loading provides a loading indicator and retryable error state.
- [ ] Vocabulary screens provide working audio pronunciation via `FlutterTts`.
- [ ] `IndexedStack` is used in `main_shell.dart` to preserve tab state, scroll offsets, and active forms.
- [ ] Pull-to-refresh (`RefreshIndicator`) is available on scrollable dashboards.
- [ ] `addTearDown(appState.dispose)` is called in widget tests to prevent lingering timers from failing test runs.
- [ ] No hardcoded cloud IPs or secrets in Dart source files (`ApiConfig.apiBaseUrl` is used).

## 3. Review Reporting Format
Report each finding as:
`filepath:linenumber — issue — recommended remediation`
