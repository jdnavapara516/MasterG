# MasterG Architecture Specification

This document provides a technical overview of the MasterG system architecture, encompassing the frontend Flutter client, the backend Django REST service, data persistence models, and security considerations.

---

## 1. High-Level System Architecture

MasterG employs a client-server architecture with separation between presentation, state orchestration, business logic, and relational persistence.

```mermaid
graph TD
    subgraph ClientLayer["Frontend Client (Flutter)"]
        UI["UI Screens (Material 3)"]
        State["AppState (ChangeNotifier)"]
        Services["Service Layer (TTS, Audio, HTTP)"]
        UI --> State
        State --> Services
    end

    subgraph TransportLayer["Communication"]
        HTTP["REST API (HTTPS / JSON / JWT)"]
        Services --> HTTP
    end

    subgraph BackendLayer["Backend Service (Django 6 / DRF)"]
        Router["URL Routing"]
        AuthApp["Authentication Service"]
        VocabApp["Vocabulary Service"]
        GrammarApp["Grammar Service"]
        ChatApp["AI Tutor Chat Service"]
        
        HTTP --> Router
        Router --> AuthApp
        Router --> VocabApp
        Router --> GrammarApp
        Router --> ChatApp
    end

    subgraph DataLayer["Persistence"]
        DB[(Relational DB / SQLite / PostgreSQL)]
        AuthApp --> DB
        VocabApp --> DB
        GrammarApp --> DB
        ChatApp --> DB
    end
```

---

## 2. Component Breakdown

### 2.1 Frontend Architecture (`masterg_app`)
- **UI Screens**: Modular screens organised by domain:
  - `screens/auth/`: User registration and authentication views.
  - `screens/dashboard/`: Main hub presenting daily goals, active streaks, and entry points.
  - `screens/learn/`: Learning modules (CEFR word learning, Rapid Fire, Revision, Grammar Quizzes).
  - `screens/chat/`: Real-time AI chat with voice recognition and speech playback.
  - `screens/profile/`: Progress tracking, leaderboard standings, and settings.
- **Navigation Shell**: `MainNavigationShell` utilizes an `IndexedStack` to preserve state, scroll coordinates, and network caches across tab switches.
- **State Management**: Built on `InheritedNotifier` (`AppStateProvider`) backed by a centralized `AppState` class controlling authentication tokens, daily goal metrics, streak records, and caching.
- **Audio Subsystem**:
  - `SpeechToText`: Converts learner speech into text for conversational turns.
  - `FlutterTts`: Synthesizes spoken English for vocabulary pronunciation and tutor replies.

### 2.2 Backend Architecture (`masterg_api`)
- **Django REST Framework**: Handles endpoint routing, request validation, serialization, and permissions.
- **JWT Authentication**: Powered by `rest_framework_simplejwt`, issuing short-lived access tokens and longer-lived refresh tokens.
- **Domain Modules**:
  - `authentication`: User registration, session verification, dynamic leaderboard calculation, and point recording.
  - `vocabulary`: CEFR levels (A1-C2), sequential word pointers, example sentences, daily progress trackers, rapid-fire generation, and review sets.
  - `grammar`: Topic completion validation, 5/5 score gate enforcement, and topic mastery recording.
  - `api/chat`: English conversational engine evaluating grammar, providing corrections, and connecting to Gemini API when configured.

---

## 3. Database Entity-Relationship Model

```mermaid
erDiagram
    User ||--o| UserProfile : "has"
    User ||--o| UserGrammarProgress : "tracks"
    User ||--o{ DailyVocabularyProgress : "records"
    Vocabulary ||--o{ VocabularySentence : "exemplified by"

    UserProfile {
        int id PK
        int user_id FK
        int current_streak
        int longest_streak
        int points
        int speaking_sessions
        int chat_sessions
        int a1_pointer
        int a2_pointer
        int b1_pointer
        int b2_pointer
        int c1_pointer
        int c2_pointer
        date last_learning_date
    }

    Vocabulary {
        int id PK
        string level
        int word_no
        string word
        string pronunciation
        string gujarati_meaning
        string english_meaning
    }

    VocabularySentence {
        int id PK
        int vocabulary_id FK
        string sentence
    }

    DailyVocabularyProgress {
        int id PK
        int user_id FK
        date date
        int completed_words
    }

    UserGrammarProgress {
        int id PK
        int user_id FK
        int completed_topics
        int total_points
        json completed_topic_ids
        string last_completed_topic
        datetime last_completed_at
    }
```

---

## 4. Authentication and Token Refresh Flow

```mermaid
sequenceDiagram
    autonumber
    actor Learner as Learner (Flutter App)
    participant API as Django REST API
    participant DB as Database

    Learner->>API: POST /api/auth/login/ (email, password)
    API->>DB: Validate user credentials
    DB-->>API: User verified
    API-->>Learner: 200 OK (access_token, refresh_token, profile)

    Note over Learner,API: Subsequent requests use Bearer Access Token
    Learner->>API: GET /api/grammar/progress/ (Bearer Access Token)
    API-->>Learner: 200 OK (progress data)

    Note over Learner,API: When Access Token expires (401 Unauthorized)
    Learner->>API: POST /api/auth/token/refresh/ (refresh_token)
    API-->>Learner: 200 OK (new access_token)
    Learner->>API: Retry original request with new access token
    API-->>Learner: 200 OK
```

---

## 5. Security & Data Protection

- **Password Storage**: Passwords are saved using PBKDF2 with SHA-256 password hashing.
- **JWT Protection**: Tokens are signed with HMAC-SHA256.
- **Cross-Origin Resource Sharing (CORS)**: Controlled through `django-cors-headers`. In production, origins should be restricted to trusted application domains.
- **Database Safety**: SQL injection prevention is guaranteed through the Django ORM query parameterization.
