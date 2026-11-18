# MasterG REST API Documentation

Base URL for development: `http://127.0.0.1:8000/api`

---

## 1. Authentication Endpoints

### 1.1 User Registration
- **Method & Route**: `POST /auth/register/`
- **Authentication**: None
- **Request Body**:
```json
{
  "email": "learner@example.com",
  "password": "StrongPassword123!"
}
```
- **Success Response (201 Created)**:
```json
{
  "message": "User registered successfully.",
  "tokens": {
    "access": "eyJhbGciOi...",
    "refresh": "eyJhbGciOi..."
  },
  "user": {
    "id": 1,
    "email": "learner@example.com",
    "username": "Learner",
    "level": "Beginner (A1)",
    "streak": 0,
    "point": 0,
    "stats": {
      "wordsLearned": 0,
      "grammarLessonsCompleted": 0,
      "speakingSessionsCompleted": 0,
      "chatSessionsCompleted": 0
    }
  }
}
```

---

### 1.2 User Login
- **Method & Route**: `POST /auth/login/`
- **Authentication**: None
- **Request Body**:
```json
{
  "email": "learner@example.com",
  "password": "StrongPassword123!"
}
```
- **Success Response (200 OK)**:
```json
{
  "message": "Login successful.",
  "tokens": {
    "access": "eyJhbGciOi...",
    "refresh": "eyJhbGciOi..."
  },
  "user": {
    "id": 1,
    "email": "learner@example.com",
    "username": "Learner",
    "level": "Beginner (A1)",
    "streak": 1,
    "point": 120,
    "stats": {
      "wordsLearned": 10,
      "grammarLessonsCompleted": 2,
      "speakingSessionsCompleted": 1,
      "chatSessionsCompleted": 3
    }
  }
}
```

---

### 1.3 Token Refresh
- **Method & Route**: `POST /auth/token/refresh/`
- **Authentication**: None
- **Request Body**:
```json
{
  "refresh": "eyJhbGciOi..."
}
```
- **Success Response (200 OK)**:
```json
{
  "access": "eyJhbGciOi..."
}
```

---

### 1.4 Submit Points
- **Method & Route**: `POST /auth/score/`
- **Authentication**: `Bearer <access_token>`
- **Request Body**:
```json
{
  "point": 25,
  "activity": "speaking"
}
```
- **Success Response (200 OK)**:
```json
{
  "point": 145,
  "speaking_sessions": 2,
  "chat_sessions": 3,
  "message": "Points saved successfully."
}
```

---

### 1.5 Global Leaderboard
- **Method & Route**: `GET /auth/leaderboard/`
- **Authentication**: `Bearer <access_token>`
- **Success Response (200 OK)**:
```json
{
  "top_users": [
    {
      "id": 1,
      "username": "Alice",
      "points": 540,
      "rank": 1
    }
  ],
  "current_user": {
    "id": 2,
    "username": "Bob",
    "points": 145,
    "rank": 2
  },
  "total_users": 2
}
```

---

## 2. Vocabulary Endpoints

### 2.1 CEFR Levels Overview
- **Method & Route**: `GET /vocabulary/levels/`
- **Authentication**: Optional
- **Success Response (200 OK)**:
```json
[
  {"level": "A1", "learned_words": 15},
  {"level": "A2", "learned_words": 0},
  {"level": "B1", "learned_words": 0},
  {"level": "B2", "learned_words": 0},
  {"level": "C1", "learned_words": 0},
  {"level": "C2", "learned_words": 0}
]
```

---

### 2.2 Current Word
- **Method & Route**: `GET /vocabulary/current-word/?level=A1`
- **Authentication**: Optional
- **Success Response (200 OK)**:
```json
{
  "word_no": 1,
  "word": "Ambitious",
  "pronunciation": "am-bi-shus",
  "gujarati_meaning": "મહત્વાકાંક્ષી",
  "english_meaning": "Having a strong desire to succeed.",
  "sentences": [
    "She is ambitious and wants to become a doctor.",
    "My friend is ambitious about his career."
  ],
  "today_progress": 1,
  "today_target": 5,
  "streak": 2
}
```

---

### 2.3 Next Word
- **Method & Route**: `POST /vocabulary/next-word/`
- **Authentication**: Optional
- **Request Body**:
```json
{
  "level": "A1"
}
```
- **Success Response (200 OK)**:
```json
{
  "word_no": 2,
  "word": "Curious",
  "pronunciation": "kyoo-ree-uhs",
  "gujarati_meaning": "જિજ્ઞાસુ",
  "english_meaning": "Eager to know or learn something.",
  "sentences": ["Curious kids ask questions."],
  "today_progress": 2,
  "today_target": 5,
  "streak": 2,
  "daily_completed": false
}
```

---

### 2.4 Rapid Fire Words Challenge
- **Method & Route**: `POST /vocabulary/rapid-fire/words/`
- **Authentication**: `Bearer <access_token>`
- **Success Response (200 OK)**:
```json
{
  "words": [
    {
      "english": "Ambitious",
      "gujarati": "મહત્વાકાંક્ષી",
      "pronunciation": "am-bi-shus"
    }
  ]
}
```

---

### 2.5 Revision & Flashcard Sets
- **Method & Route**: `GET /vocabulary/revision/?count=20`
- **Authentication**: `Bearer <access_token>`
- **Success Response (200 OK)**:
```json
{
  "total_words_learned": 15,
  "completed_grammar_topics": ["basic_sentence_structure"],
  "words": [
    {
      "word": "Ambitious",
      "pronunciation": "am-bi-shus",
      "gujarati_meaning": "મહત્વાકાંક્ષી",
      "english_meaning": "Having a strong desire to succeed.",
      "level": "A1",
      "sentences": ["She is ambitious..."]
    }
  ]
}
```

---

## 3. Grammar Endpoints

### 3.1 Grammar Progress
- **Method & Route**: `GET /grammar/progress/`
- **Authentication**: `Bearer <access_token>`
- **Success Response (200 OK)**:
```json
{
  "completed_topics": 1,
  "total_points": 10,
  "completed_topic_ids": ["basic_sentence_structure"],
  "last_completed_topic": "basic_sentence_structure",
  "last_completed_at": "2026-11-18T20:00:00Z"
}
```

---

### 3.2 Complete Grammar Topic
- **Method & Route**: `POST /grammar/complete/`
- **Authentication**: `Bearer <access_token>`
- **Request Body**:
```json
{
  "topic_id": "basic_sentence_structure",
  "correct_answers": 5
}
```
- **Success Response (200 OK)**:
```json
{
  "success": true,
  "already_completed": false,
  "topic_id": "basic_sentence_structure",
  "topic_completed": true,
  "points_awarded": 10,
  "total_points": 10,
  "completed_topics": 1,
  "completed_topic_ids": ["basic_sentence_structure"],
  "message": "Grammar topic completed successfully."
}
```

---

## 4. AI Chat Endpoint

### 4.1 Tutor Chat Interaction
- **Method & Route**: `POST /chat/`
- **Authentication**: `Bearer <access_token>`
- **Request Body**:
```json
{
  "messages": [
    {"role": "user", "content": "Hello G-Bot, how can I practice speaking?"}
  ]
}
```
- **Success Response (200 OK)**:
```json
{
  "reply": "Hello! A great way to practice speaking is by describing your daily routine out loud or reading English sentences with our pronunciation audio. What did you do this morning?",
  "point": 150,
  "chat_sessions": 4
}
```
