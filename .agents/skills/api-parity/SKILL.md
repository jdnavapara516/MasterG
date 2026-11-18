---
name: api-parity
description: Contract parity verification between Flutter client and Django REST endpoints.
---

# API Parity & Contract Invariants

Whenever an endpoint is created or refactored:

1. **Check URL mapping**: Ensure the path in `masterg_app/lib/config/api_config.dart` or `app_state.dart` matches Django's `urls.py`.
2. **Verify JSON keys**:
   - Leaderboard expects `top_users`, `current_user`, `total_users`.
   - Score expects `point`, `speaking_sessions`, `chat_sessions`.
   - Rapid fire expects `words` with exactly 10 objects having `english` and `gujarati` strings.
   - Revision expects `total_words_learned`, `completed_grammar_topics`, `words`.
   - AI Chat expects `reply`, `point`, `chat_sessions`.
3. **Verify Status Codes**:
   - Resource creation returns `201 Created`.
   - Successful operations return `200 OK`.
   - Validation errors return `400 Bad Request`.
   - Missing or expired credentials return `401 Unauthorized`.
