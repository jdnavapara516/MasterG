---
name: debug-reports
description: Diagnostic procedures for debugging runtime errors across Django REST backend and Flutter client.
---

# MasterG Debugging & Diagnostic Guide

## 1. Authentication & JWT 401 Unauthorized
- **Symptom**: Requests return `401 Unauthorized` or Flutter logout triggers unexpectedly.
- **Diagnostic Steps**:
  1. Inspect the HTTP `Authorization` header: ensure format is `Bearer <token>`.
  2. Check access token expiration: SimpleJWT access tokens expire after 5 minutes by default.
  3. Verify `_refreshAccessToken()` in `app_state.dart` successfully hits `POST /api/auth/token/refresh/`.
  4. Inspect token payload:
     ```python
     from rest_framework_simplejwt.tokens import AccessToken
     token = AccessToken(token_str)
     print(token.payload)
     ```

## 2. Missing Backend Endpoints (404 Not Found)
- **Symptom**: Flutter displays *"Could not load leaderboard"*, *"Could not load vocabulary round"*, or *"AI chat could not respond"*.
- **Diagnostic Steps**:
  1. Review Django server terminal logs to identify the exact requested URI.
  2. Verify the URI against `api/urls.py` and domain app `urls.py`.
  3. Ensure a trailing slash is present (Django redirects or rejects missing trailing slashes if `APPEND_SLASH=False`).

## 3. Database Integrity & SQLite Locks
- **Symptom**: `OperationalError: database is locked`.
- **Diagnostic Steps**:
  1. SQLite locks on concurrent write operations. Ensure views use `transaction.atomic()` with `select_for_update()`.
  2. For concurrent environments, consider migrating to PostgreSQL using `psycopg2-binary`.

## 4. Text-To-Speech (TTS) Audio on Flutter Web / Mobile
- **Symptom**: No audio heard when tapping the pronunciation button.
- **Diagnostic Steps**:
  1. Ensure device volume is not muted.
  2. Check platform permissions: Android requires `<uses-permission android:name="android.permission.INTERNET" />`, iOS requires microphone and speech recognition descriptions in `Info.plist`.
  3. On Web, user interaction (e.g. tap) must precede audio playback due to browser autoplay policies.
