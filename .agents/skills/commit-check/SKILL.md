---
name: commit-check
description: Use before every git commit touching masterg_api or masterg_app. Verifies tests, migrations, lints, and static analysis.
---

# Commit Check Quality Gate

Execute the following quality verification before creating any git commit:

## 1. Backend Verification (`masterg_api/`)
```bash
cd masterg_api
# Activate venv
source venv/bin/activate

# 1. Check migrations for unmigrated models
python api/manage.py makemigrations --check --dry-run

# 2. Run system checks
python api/manage.py check

# 3. Run all unit tests
python api/manage.py test authentication grammar vocabulary
```
All checks must exit 0.

## 2. Frontend Verification (`masterg_app/`)
```bash
cd masterg_app

# 1. Fetch dependencies
flutter pub get

# 2. Static analysis
flutter analyze

# 3. Widget & state tests
flutter test

# 4. Dry-run web compilation
flutter build web --no-wasm-dry-run
```
All tests must pass with 0 compilation errors.
