---
name: local-dev-setup
description: Instructions for provisioning and running both MasterG backend and frontend locally.
---

# Local Development Setup

## 1. Backend (`masterg_api`)
```bash
cd masterg_api
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
python api/manage.py migrate
python api/vocabulary/script.py
python api/manage.py runserver 127.0.0.1:8000
```

## 2. Frontend (`masterg_app`)
```bash
cd masterg_app
flutter pub get

# Target local backend:
flutter run -d macos --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000/api
```
