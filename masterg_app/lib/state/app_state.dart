import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../grammar/services/grammar_progress_service.dart';

class Streak {
  int days;
  int? _longestDays;

  int get longestDays => _longestDays ?? days;

  set longestDays(int value) => _longestDays = value;

  Streak({required this.days, required int this._longestDays});
}

class UserStats {
  int wordsLearned;
  int grammarLessonsCompleted;
  int speakingSessionsCompleted;
  int chatSessionsCompleted;

  UserStats({
    required this.wordsLearned,
    required this.grammarLessonsCompleted,
    required this.speakingSessionsCompleted,
    required this.chatSessionsCompleted,
  });
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.id,
    required this.username,
    required this.points,
    required this.rank,
  });

  final int id;
  final String username;
  final int points;
  final int rank;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    if (json['id'] is! int ||
        json['username'] is! String ||
        json['points'] is! int ||
        json['rank'] is! int) {
      throw const FormatException(
        'The server returned invalid leaderboard data.',
      );
    }

    return LeaderboardEntry(
      id: json['id'] as int,
      username: json['username'] as String,
      points: json['points'] as int,
      rank: json['rank'] as int,
    );
  }
}

class LeaderboardSnapshot {
  const LeaderboardSnapshot({
    required this.topUsers,
    required this.currentUser,
    required this.totalUsers,
  });

  final List<LeaderboardEntry> topUsers;
  final LeaderboardEntry currentUser;
  final int totalUsers;

  factory LeaderboardSnapshot.fromJson(Map<String, dynamic> json) {
    final topUsersJson = json['top_users'];
    final currentUserJson = json['current_user'];
    if (topUsersJson is! List ||
        currentUserJson is! Map<String, dynamic> ||
        json['total_users'] is! int) {
      throw const FormatException(
        'The server returned invalid leaderboard data.',
      );
    }

    return LeaderboardSnapshot(
      topUsers: topUsersJson.map((entry) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException(
            'The server returned an invalid leaderboard entry.',
          );
        }
        return LeaderboardEntry.fromJson(entry);
      }).toList(),
      currentUser: LeaderboardEntry.fromJson(currentUserJson),
      totalUsers: json['total_users'] as int,
    );
  }
}

class Message {
  final String text;
  final bool isUser;
  final DateTime time;

  Message({required this.text, required this.isUser, required this.time});
}

class VocabularyWord {
  final String word;
  final String type; // noun, verb, adj
  final String definition;
  final String example;
  final String translation;
  bool isLearned;

  VocabularyWord({
    required this.word,
    required this.type,
    required this.definition,
    required this.example,
    required this.translation,
    this.isLearned = false,
  });
}

class AppState extends ChangeNotifier {
  static const String _dailyChatGreeting =
      "Hi! I am G-Bot, your AI English assistant. How has your day been so far?";

  final GrammarProgressService _grammarProgressService =
      GrammarProgressService();

  bool _isDarkMode = false;
  bool _isLoggedIn = false;
  String _userName = "Learner";
  String _userLevel = "A1";
  String? _accessToken;
  String? _refreshToken;
  Future<bool>? _refreshInFlight;

  late Streak _streak;
  late UserStats _stats;
  late List<VocabularyWord> _vocabularyList;
  late List<Message> _chatHistory;
  DateTime _chatHistoryDate = DateTime.now();
  Timer? _dailyChatResetTimer;

  // Track daily goals (out of 100)
  int _vocabGoalCount = 0; // target 5
  int _grammarGoalCount = 0; // target 1
  int _speakingGoalCount = 0; // target 1
  int _pointBalance = 0;

  AppState() {
    _streak = Streak(days: 0, longestDays: 0);
    _stats = UserStats(
      wordsLearned: 0,
      grammarLessonsCompleted: 0,
      speakingSessionsCompleted: 0,
      chatSessionsCompleted: 0,
    );

    _vocabularyList = [
      VocabularyWord(
        word: "Eloquent",
        type: "adjective",
        definition: "Fluent or persuasive in speaking or writing.",
        example: "She made an eloquent appeal for action.",
        translation: "सुवक्ता / स्पष्टवादी",
      ),
      VocabularyWord(
        word: "Pragmatic",
        type: "adjective",
        definition:
            "Dealing with things sensibly and realistically in a way that is based on practical rather than theoretical considerations.",
        example: "A pragmatic approach to politics is often best.",
        translation: "व्यवहारिक",
      ),
      VocabularyWord(
        word: "Ambiguity",
        type: "noun",
        definition:
            "The quality of being open to more than one interpretation; inexactness.",
        example: "We should avoid ambiguity in our contracts.",
        translation: "अस्पष्टता",
      ),
      VocabularyWord(
        word: "Benevolent",
        type: "adjective",
        definition:
            "Well meaning and kindly; serving a charitable rather than a profit-making purpose.",
        example: "A benevolent donor funded the new library.",
        translation: "परोपकारी",
      ),
      VocabularyWord(
        word: "Mitigate",
        type: "verb",
        definition: "Make something bad less severe, serious, or painful.",
        example: "Drainage schemes have helped to mitigate the problem.",
        translation: "कम करना / शांत करना",
      ),
      VocabularyWord(
        word: "Resilient",
        type: "adjective",
        definition:
            "Able to withstand or recover quickly from difficult conditions.",
        example: "Children are often remarkably resilient.",
        translation: "लचीला",
      ),
      VocabularyWord(
        word: "Superfluous",
        type: "adjective",
        definition: "Unnecessary, especially through being more than enough.",
        example: "Avoid superfluous information in your resume.",
        translation: "अनावश्यक",
      ),
    ];

    _chatHistory = _createDailyChatHistory(DateTime.now());
    _scheduleDailyChatReset();
  }

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get isLoggedIn => _isLoggedIn;
  String get userName => _userName;
  String get userLevel => _userLevel;
  String? get accessToken => _accessToken;
  Streak get streak => _streak;
  UserStats get stats => _stats;
  List<VocabularyWord> get vocabularyList => _vocabularyList;
  List<Message> get chatHistory {
    _resetChatHistoryIfNewDay();
    return _chatHistory;
  }

  List<Message> _createDailyChatHistory(DateTime now) => [
    Message(text: _dailyChatGreeting, isUser: false, time: now),
  ];

  bool _resetChatHistoryIfNewDay() {
    final now = DateTime.now();
    if (_chatHistoryDate.year == now.year &&
        _chatHistoryDate.month == now.month &&
        _chatHistoryDate.day == now.day) {
      return false;
    }

    _chatHistoryDate = now;
    _chatHistory = _createDailyChatHistory(now);
    return true;
  }

  void _scheduleDailyChatReset() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _dailyChatResetTimer = Timer(nextMidnight.difference(now), () {
      if (_resetChatHistoryIfNewDay()) {
        notifyListeners();
      }
      _scheduleDailyChatReset();
    });
  }

  @override
  void dispose() {
    _dailyChatResetTimer?.cancel();
    super.dispose();
  }

  int get vocabGoalCount => _vocabGoalCount;
  int get grammarGoalCount => _grammarGoalCount;
  int get speakingGoalCount => _speakingGoalCount;
  int get pointBalance => _pointBalance;

  double get dailyGoalCompletion {
    // Vocab goal: 5 words (each counts 20% of vocab progress, vocab progress contributes 40% of total daily goal)
    // Grammar goal: 1 lesson (contributes 30% of daily goal)
    // Speaking goal: 1 lesson (contributes 30% of daily goal)
    double vocabPart = (_vocabGoalCount / 5.0).clamp(0.0, 1.0) * 0.4;
    double grammarPart = (_grammarGoalCount / 1.0).clamp(0.0, 1.0) * 0.3;
    double speakingPart = (_speakingGoalCount / 1.0).clamp(0.0, 1.0) * 0.3;
    return (vocabPart + grammarPart + speakingPart) * 100.0;
  }

  // Setters/Actions
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  static const String apiBaseUrl = "${ApiConfig.apiBaseUrl}/auth";

  Future<String?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        _isLoggedIn = true;
        if (data['tokens'] != null) {
          _accessToken = data['tokens']['access'];
          _refreshToken = data['tokens']['refresh'];
        }
        if (data['user'] != null) {
          final userData = data['user'];
          _userName = userData['username'] ?? "Learner";
          _userLevel = userData['level'] ?? "A1";
          if (userData['stats'] != null) {
            final statsData = userData['stats'];
            _stats = UserStats(
              wordsLearned: statsData['wordsLearned'] ?? 0,
              grammarLessonsCompleted:
                  statsData['grammarLessonsCompleted'] ?? 0,
              speakingSessionsCompleted:
                  statsData['speakingSessionsCompleted'] ?? 0,
              chatSessionsCompleted: statsData['chatSessionsCompleted'] ?? 0,
            );
          }
          _streak = Streak(
            days: userData['streak'] ?? 0,
            longestDays: userData['longest_streak'] ?? 0,
          );
          _pointBalance = userData['point'] ?? 0;
        }
        notifyListeners();
        return null; // Success
      } else {
        return data['error'] ?? "Failed to log in. Please try again.";
      }
    } catch (e) {
      return "Network error: Make sure the Django API is running.";
    }
  }

  void logout() {
    _isLoggedIn = false;
    _accessToken = null;
    _refreshToken = null;
    notifyListeners();
  }

  void loginAsGuest() {
    _isLoggedIn = true;
    _userName = "Guest Learner";
    _userLevel = "A1";
    _streak = Streak(days: 1, longestDays: 1);
    _stats = UserStats(
      wordsLearned: 5,
      grammarLessonsCompleted: 1,
      speakingSessionsCompleted: 1,
      chatSessionsCompleted: 2,
    );
    _pointBalance = 50;
    notifyListeners();
  }

  Future<http.Response> authenticatedRequest(
    Future<http.Response> Function(String token) sendRequest,
  ) async {
    final token = _accessToken;
    if (token == null) return sendRequest('');

    final response = await sendRequest(token);
    if (response.statusCode != 401 || !await _refreshAccessToken()) {
      return response;
    }

    final refreshedToken = _accessToken;
    if (refreshedToken == null) return response;
    return sendRequest(refreshedToken);
  }

  Future<bool> _refreshAccessToken() async {
    final activeRefresh = _refreshInFlight;
    if (activeRefresh != null) return activeRefresh;

    final refreshToken = _refreshToken;
    if (refreshToken == null) return false;

    final refreshRequest = _requestNewAccessToken(refreshToken);
    _refreshInFlight = refreshRequest;
    try {
      return await refreshRequest;
    } finally {
      if (identical(_refreshInFlight, refreshRequest)) {
        _refreshInFlight = null;
      }
    }
  }

  Future<bool> _requestNewAccessToken(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$apiBaseUrl/token/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          data is Map<String, dynamic> &&
          data['access'] is String) {
        _accessToken = data['access'];
        if (data['refresh'] is String) _refreshToken = data['refresh'];
        notifyListeners();
        return true;
      }

      if (response.statusCode == 400 || response.statusCode == 401) {
        _isLoggedIn = false;
        _accessToken = null;
        _refreshToken = null;
        notifyListeners();
      }
    } catch (_) {
      // Keep the current session when a temporary network error blocks refresh.
    }
    return false;
  }

  Future<String?> signup(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$apiBaseUrl/register/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        _isLoggedIn = true;
        if (data['tokens'] != null) {
          _accessToken = data['tokens']['access'];
          _refreshToken = data['tokens']['refresh'];
        }
        if (data['user'] != null) {
          final userData = data['user'];
          _userName = userData['username'] ?? "Learner";
          _userLevel = userData['level'] ?? "A1";
          _streak = Streak(
            days: userData['streak'] ?? 0,
            longestDays: userData['longest_streak'] ?? 0,
          );
          _pointBalance = userData['point'] ?? 0;
          final statsData = userData['stats'];
          if (statsData != null) {
            _stats = UserStats(
              wordsLearned: statsData['wordsLearned'] ?? 0,
              grammarLessonsCompleted:
                  statsData['grammarLessonsCompleted'] ?? 0,
              speakingSessionsCompleted:
                  statsData['speakingSessionsCompleted'] ?? 0,
              chatSessionsCompleted: statsData['chatSessionsCompleted'] ?? 0,
            );
          }
        }
        notifyListeners();
        return null; // Success
      } else {
        return data['error'] ?? "Failed to create account.";
      }
    } catch (e) {
      return "Network error: Make sure the Django API is running.";
    }
  }

  void updateProfileName(String newName) {
    _userName = newName;
    notifyListeners();
  }

  Future<LeaderboardSnapshot> fetchLeaderboard() async {
    final response = await authenticatedRequest(
      (token) => http
          .get(
            Uri.parse('$apiBaseUrl/leaderboard/'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(const Duration(seconds: 10)),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(
        data is Map<String, dynamic>
            ? data['error']?.toString() ?? 'Could not load the leaderboard.'
            : 'Could not load the leaderboard.',
      );
    }
    if (data is! Map<String, dynamic>) {
      throw const FormatException(
        'The server returned invalid leaderboard data.',
      );
    }
    return LeaderboardSnapshot.fromJson(data);
  }

  Future<void> fetchUserProfile() async {
    if (!_isLoggedIn) return;
    try {
      final response = await authenticatedRequest(
        (token) => http
            .get(
              Uri.parse("${ApiConfig.apiBaseUrl}/vocabulary/profile/"),
              headers: {"Authorization": "Bearer $token"},
            )
            .timeout(const Duration(seconds: 5)),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _streak.days = data["streak"] ?? _streak.days;
        _streak.longestDays = data["longest_streak"] ?? _streak.longestDays;
        _vocabGoalCount = data["today_progress"] ?? _vocabGoalCount;
        _pointBalance = data["point"] ?? _pointBalance;
        _stats.wordsLearned = data["words_learned"] ?? _stats.wordsLearned;
        _stats.grammarLessonsCompleted =
            data["grammar_lessons_completed"] ?? _stats.grammarLessonsCompleted;
        _stats.speakingSessionsCompleted =
            data["speaking_sessions"] ?? _stats.speakingSessionsCompleted;
        _stats.chatSessionsCompleted =
            data["chat_sessions"] ?? _stats.chatSessionsCompleted;
        _grammarGoalCount = _stats.grammarLessonsCompleted > 0 ? 1 : 0;
        _speakingGoalCount = _stats.speakingSessionsCompleted > 0 ? 1 : 0;
        if (data["username"] != null) {
          _userName = data["username"];
        }
        if (data["level"] != null) _userLevel = data["level"];
        notifyListeners();
      }
    } catch (_) {
      // Quietly fail or ignore if offline
    }
  }

  void updateProfileLevel(String newLevel) {
    _userLevel = newLevel;
    notifyListeners();
  }

  void syncVocabularyProgress(int todayProgress, int streakDays) {
    _vocabGoalCount = todayProgress.clamp(0, 5);
    _streak.days = streakDays;
    notifyListeners();
  }

  Future<int> submitPoints(int point, {String? activity}) async {
    final response = await authenticatedRequest(
      (token) => http
          .post(
            Uri.parse('$apiBaseUrl/score/'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'point': point, 'activity': ?activity}),
          )
          .timeout(const Duration(seconds: 10)),
    );
    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        data is Map<String, dynamic>
            ? data['error']?.toString() ?? 'Could not save points.'
            : 'Could not save points.',
      );
    }

    _pointBalance = data['point'] ?? (_pointBalance + point);
    if (data['speaking_sessions'] != null) {
      _stats.speakingSessionsCompleted = data['speaking_sessions'];
      _speakingGoalCount = _stats.speakingSessionsCompleted > 0 ? 1 : 0;
    }
    if (data['chat_sessions'] != null) {
      _stats.chatSessionsCompleted = data['chat_sessions'];
    }
    notifyListeners();
    return _pointBalance;
  }

  Future<void> learnVocabularyWord(String wordText) async {
    final word = _vocabularyList.firstWhere((w) => w.word == wordText);
    if (!word.isLearned) {
      word.isLearned = true;
      _stats.wordsLearned += 1;
      _vocabGoalCount = (_vocabGoalCount + 1).clamp(0, 5);
      await submitPoints(15, activity: 'vocabulary');
    }
  }

  Future<Map<String, dynamic>> fetchGrammarProgress() async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }
    final progress = await _grammarProgressService.getGrammarProgress(
      authenticatedRequest,
    );
    _stats.grammarLessonsCompleted =
        progress['completed_topics'] ?? _stats.grammarLessonsCompleted;
    _grammarGoalCount = ((progress['completed_topics'] ?? 0) > 0 ? 1 : 0).clamp(
      0,
      1,
    );
    notifyListeners();
    return progress;
  }

  Future<Map<String, dynamic>> completeGrammarTopic(
    String topicId,
    int correctAnswers,
  ) async {
    if (_accessToken == null) {
      throw Exception('Not authenticated');
    }

    final response = await _grammarProgressService.completeGrammarTopic(
      authenticatedRequest,
      topicId,
      correctAnswers,
    );
    final completedTopics =
        response['completed_topics'] ?? _stats.grammarLessonsCompleted;
    _stats.grammarLessonsCompleted = completedTopics;
    _grammarGoalCount = (completedTopics > 0 ? 1 : 0).clamp(0, 1);
    if ((response['points_awarded'] ?? 0) > 0) {
      _pointBalance = response['point'] ?? _pointBalance;
    }
    notifyListeners();
    return response;
  }

  Future<void> completeGrammarQuiz() async {
    await submitPoints(50, activity: 'grammar');
  }

  Future<void> completeSpeakingSession() async {
    await submitPoints(40, activity: 'speaking');
  }

  Future<String?> sendChatMessage(String text) async {
    if (_accessToken == null) {
      return 'Please log in to use AI chat.';
    }

    _resetChatHistoryIfNewDay();
    final sentAt = DateTime.now();
    _chatHistory.add(Message(text: text, isUser: true, time: sentAt));
    notifyListeners();

    final recentMessages = _chatHistory.skip(
      (_chatHistory.length - 20).clamp(0, _chatHistory.length),
    );
    final messages = recentMessages
        .map(
          (message) => {
            'role': message.isUser ? 'user' : 'assistant',
            'content': message.text,
          },
        )
        .toList();

    try {
      final response = await authenticatedRequest(
        (token) => http
            .post(
              Uri.parse('${ApiConfig.apiBaseUrl}/chat/'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: jsonEncode({'messages': messages}),
            )
            .timeout(const Duration(seconds: 35)),
      );
      final data = jsonDecode(response.body);

      if (response.statusCode != 200) {
        return data is Map<String, dynamic>
            ? data['error']?.toString() ?? 'AI chat could not respond.'
            : 'AI chat could not respond.';
      }

      final receivedAt = DateTime.now();
      if (sentAt.year != receivedAt.year ||
          sentAt.month != receivedAt.month ||
          sentAt.day != receivedAt.day) {
        _resetChatHistoryIfNewDay();
        notifyListeners();
        return null;
      }

      _chatHistory.add(
        Message(text: data['reply'], isUser: false, time: receivedAt),
      );
      _pointBalance = data['point'] ?? _pointBalance;
      _stats.chatSessionsCompleted =
          data['chat_sessions'] ?? _stats.chatSessionsCompleted;
      notifyListeners();
      return null;
    } catch (_) {
      return 'Could not reach the AI service. Check your connection and try again.';
    }
  }
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final AppStateProvider? result = context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(result != null, 'No AppStateProvider found in context');
    return result!.notifier!;
  }
}
