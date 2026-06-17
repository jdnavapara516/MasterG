import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Streak {
  int days;
  int xp;
  int targetXp;

  Streak({required this.days, required this.xp, this.targetXp = 500});

  double get progress => (xp / targetXp).clamp(0.0, 1.0);
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

class Message {
  final String text;
  final bool isUser;
  final DateTime time;

  Message({
    required this.text,
    required this.isUser,
    required this.time,
  });
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
  bool _isDarkMode = false;
  bool _isLoggedIn = false;
  String _userName = "Jenil Navapara";
  String _userLevel = "Intermediate (B1)";
  String? _accessToken;

  late Streak _streak;
  late UserStats _stats;
  late List<VocabularyWord> _vocabularyList;
  late List<Message> _chatHistory;

  // Track daily goals (out of 100)
  int _vocabGoalCount = 0; // target 5
  int _grammarGoalCount = 0; // target 1
  int _speakingGoalCount = 0; // target 1

  AppState() {
    _streak = Streak(days: 12, xp: 450, targetXp: 500);
    _stats = UserStats(
      wordsLearned: 142,
      grammarLessonsCompleted: 18,
      speakingSessionsCompleted: 7,
      chatSessionsCompleted: 14,
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
        definition: "Dealing with things sensibly and realistically in a way that is based on practical rather than theoretical considerations.",
        example: "A pragmatic approach to politics is often best.",
        translation: "व्यवहारिक",
      ),
      VocabularyWord(
        word: "Ambiguity",
        type: "noun",
        definition: "The quality of being open to more than one interpretation; inexactness.",
        example: "We should avoid ambiguity in our contracts.",
        translation: "अस्पष्टता",
      ),
      VocabularyWord(
        word: "Benevolent",
        type: "adjective",
        definition: "Well meaning and kindly; serving a charitable rather than a profit-making purpose.",
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
        definition: "Able to withstand or recover quickly from difficult conditions.",
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

    _chatHistory = [
      Message(
        text: "Hi Jenil! I am G-Bot, your AI English assistant. Let's practice conversation. How has your day been so far?",
        isUser: false,
        time: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];
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
  List<Message> get chatHistory => _chatHistory;

  int get vocabGoalCount => _vocabGoalCount;
  int get grammarGoalCount => _grammarGoalCount;
  int get speakingGoalCount => _speakingGoalCount;

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

  static const String apiBaseUrl = "http://127.0.0.1:8000/api/auth";

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
        }
        if (data['user'] != null) {
          final userData = data['user'];
          _userName = userData['username'] ?? "Jenil Navapara";
          _userLevel = userData['level'] ?? "Intermediate (B1)";
          if (userData['stats'] != null) {
            final statsData = userData['stats'];
            _stats = UserStats(
              wordsLearned: statsData['wordsLearned'] ?? 142,
              grammarLessonsCompleted: statsData['grammarLessonsCompleted'] ?? 18,
              speakingSessionsCompleted: statsData['speakingSessionsCompleted'] ?? 7,
              chatSessionsCompleted: statsData['chatSessionsCompleted'] ?? 14,
            );
          }
          _streak = Streak(
            days: userData['streak'] ?? 12,
            xp: userData['xp'] ?? 450,
          );
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
    notifyListeners();
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
        }
        if (data['user'] != null) {
          final userData = data['user'];
          _userName = userData['username'] ?? "Jenil Navapara";
          _userLevel = userData['level'] ?? "Intermediate (B1)";
          _streak = Streak(
            days: userData['streak'] ?? 12,
            xp: userData['xp'] ?? 450,
          );
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

  Future<void> fetchUserProfile() async {
    if (!_isLoggedIn) return;
    try {
      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/vocabulary/profile/"),
        headers: _accessToken != null ? {"Authorization": "Bearer $_accessToken"} : {},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _streak.days = data["streak"] ?? _streak.days;
        _vocabGoalCount = data["today_progress"] ?? _vocabGoalCount;
        _stats.wordsLearned = data["words_learned"] ?? _stats.wordsLearned;
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

  void learnVocabularyWord(String wordText) {
    final word = _vocabularyList.firstWhere((w) => w.word == wordText);
    if (!word.isLearned) {
      word.isLearned = true;
      _stats.wordsLearned += 1;
      _vocabGoalCount = (_vocabGoalCount + 1).clamp(0, 5);
      addXp(15);
    }
  }

  void completeGrammarQuiz() {
    _stats.grammarLessonsCompleted += 1;
    _grammarGoalCount = (_grammarGoalCount + 1).clamp(0, 1);
    addXp(50);
  }

  void completeSpeakingSession() {
    _stats.speakingSessionsCompleted += 1;
    _speakingGoalCount = (_speakingGoalCount + 1).clamp(0, 1);
    addXp(40);
  }

  void sendChatMessage(String text) {
    _chatHistory.add(Message(text: text, isUser: true, time: DateTime.now()));
    _stats.chatSessionsCompleted += 1;
    addXp(10);
    notifyListeners();

    // Simulate AI response
    _simulateAiResponse(text);
  }

  void addXp(int amount) {
    _streak.xp += amount;
    if (_streak.xp >= _streak.targetXp) {
      _streak.xp = _streak.xp - _streak.targetXp;
      _streak.days += 1; // Level up / Streak extends!
      _streak.targetXp = (_streak.targetXp * 1.1).round(); // Next level harder
    }
    notifyListeners();
  }

  void _simulateAiResponse(String userText) {
    // Quick automated AI tutor replies
    String aiReply = "That's very interesting! Could you elaborate more on that using other vocabulary words?";
    
    final lower = userText.toLowerCase();
    if (lower.contains("hello") || lower.contains("hi")) {
      aiReply = "Hello Jenil! Glad to chat with you. How can I help you practice your English today?";
    } else if (lower.contains("weather")) {
      aiReply = "I love discussing the weather. In English, we often say 'it's raining cats and dogs' for heavy rain. What's the climate like today where you are?";
    } else if (lower.contains("help") || lower.contains("difficult")) {
      aiReply = "Don't worry, learning English is a journey. Let's start with simple grammar: try writing a sentence in the present perfect tense!";
    } else if (lower.contains("sport") || lower.contains("play") || lower.contains("game")) {
      aiReply = "Sports are a great topic! Do you support any football or cricket team? Tell me in English!";
    } else if (userText.length < 10) {
      aiReply = "Nice answer. Try to write a longer response next time to practice sentence structure and connectives like 'because', 'although', or 'furthermore'!";
    }

    Timer(const Duration(seconds: 1), () {
      _chatHistory.add(Message(text: aiReply, isUser: false, time: DateTime.now()));
      notifyListeners();
    });
  }
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final AppStateProvider? result =
        context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(result != null, 'No AppStateProvider found in context');
    return result!.notifier!;
  }
}
