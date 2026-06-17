import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../state/app_state.dart';
import '../../theme/theme.dart';

class WordLearningScreen extends StatefulWidget {
  final String levelCode;
  final String levelTitle;

  const WordLearningScreen({
    super.key,
    required this.levelCode,
    required this.levelTitle,
  });

  @override
  State<WordLearningScreen> createState() => _WordLearningScreenState();
}

class _WordLearningScreenState extends State<WordLearningScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  
  // Current Word details from API
  late int _wordNo;
  late String _word;
  late String _pronunciation;
  late String _gujaratiMeaning;
  late String _englishMeaning;
  late List<dynamic> _sentences;
  late int _todayProgress;
  late int _todayTarget;
  late int _streak;

  // Track previous word states in local history for "Previous" navigation
  final List<Map<String, dynamic>> _wordHistory = [];
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCurrentWord();
    });
  }

  Future<void> _fetchCurrentWord() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final appState = AppStateProvider.of(context);
      final token = appState.accessToken;
      final Map<String, String> headers = {};
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      final response = await http.get(
        Uri.parse("http://127.0.0.1:8000/api/vocabulary/current-word/?level=${widget.levelCode}"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _updateStateFromData(data);
            
            // Record initial history
            _wordHistory.clear();
            _wordHistory.add(data);
            _historyIndex = 0;
            
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "Server error. Failed to load vocabulary.";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Connection error. Make sure the Django API is running.";
          _isLoading = false;
        });
      }
    }
  }

  void _updateStateFromData(Map<String, dynamic> data) {
    _wordNo = data["word_no"];
    _word = data["word"];
    _pronunciation = data["pronunciation"];
    _gujaratiMeaning = data["gujarati_meaning"];
    _englishMeaning = data["english_meaning"];
    _sentences = data["sentences"];
    _todayProgress = data["today_progress"];
    _todayTarget = data["today_target"];
    _streak = data["streak"];

    // Sync with global app state!
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AppStateProvider.of(context).syncVocabularyProgress(_todayProgress, _streak);
      }
    });
  }

  Future<void> _handleNext() async {
    // If we are currently browsing history, navigate forward in history
    if (_historyIndex < _wordHistory.length - 1) {
      setState(() {
        _historyIndex++;
        _updateStateFromData(_wordHistory[_historyIndex]);
      });
      return;
    }

    // Check if the current word just completed is the 5th word (completion screen)
    if (_todayProgress >= _todayTarget) {
      _showCompletionScreen();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appState = AppStateProvider.of(context);
      final token = appState.accessToken;
      final Map<String, String> headers = {"Content-Type": "application/json"};
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }

      // POST next-word increments pointer and returns new word details
      final response = await http.post(
        Uri.parse("http://127.0.0.1:8000/api/vocabulary/next-word/"),
        headers: headers,
        body: jsonEncode({"level": widget.levelCode}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          if (data["daily_completed"] == true) {
            setState(() {
              _streak = data["streak"];
              _todayProgress = 5;
              _isLoading = false;
            });
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                final appState = AppStateProvider.of(context);
                appState.syncVocabularyProgress(5, _streak);
                appState.addXp(50);
              }
            });
            _showCompletionScreen();
            return;
          }

          setState(() {
            _updateStateFromData(data);
            _wordHistory.add(data);
            _historyIndex++;
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Failed to load next word.";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Connection error.";
        _isLoading = false;
      });
    }
  }

  void _handlePrevious() {
    if (_historyIndex > 0) {
      setState(() {
        _historyIndex--;
        _updateStateFromData(_wordHistory[_historyIndex]);
      });
    }
  }

  void _showCompletionScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  // Success Trophy/Ribbon Icon
                  Center(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.goldGradient,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber.withOpacity(0.35),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    "Daily Goal Completed",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Congratulations! You completed today's vocabulary goal by studying 5 target words.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Streak and XP badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSummaryBadge(Icons.local_fire_department_rounded, "Streak Updated", Colors.orange),
                      const SizedBox(width: 14),
                      _buildSummaryBadge(Icons.flash_on_rounded, "+50 XP Earned", Colors.purple),
                    ],
                  ),
                  const Spacer(),
                  
                  // Return Button
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: AppTheme.buttonBorderRadius,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.transparent,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Pop completion, returns to levels
                      },
                      child: const Text("Return to Home", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.levelTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _errorMessage != null
                ? Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 60),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: _fetchCurrentWord,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text("Retry Connection"),
                          ),
                        ],
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Top Section: Progress indicators & streak
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.school_rounded, color: Color(0xFF64748B), size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      widget.levelTitle,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                // Streak badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                        "$_streak Day Streak",
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Daily Target Indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Daily Target",
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                                ),
                                Text(
                                  "$_todayProgress / $_todayTarget Words Today",
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                height: 8,
                                child: LinearProgressIndicator(
                                  value: (_todayProgress / _todayTarget).clamp(0.0, 1.0),
                                  backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.4),
                                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Main Scrollable Body
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Main Word Card
                              Container(
                                padding: const EdgeInsets.all(28.0),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.surface,
                                  borderRadius: AppTheme.cardBorderRadius,
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                                    width: 1.5,
                                  ),
                                  boxShadow: AppTheme.getCardShadow(context),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _word,
                                      style: theme.textTheme.headlineLarge?.copyWith(
                                        fontSize: 34,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Pronunciation: $_pronunciation",
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 18),
                                    const Divider(),
                                    const SizedBox(height: 14),
                                    
                                    // Gujarati meaning
                                    Text(
                                      "Gujarati Meaning",
                                      style: TextStyle(
                                        color: theme.colorScheme.secondary,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _gujaratiMeaning,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 18),

                                    // English meaning
                                    Text(
                                      "English Meaning",
                                      style: TextStyle(
                                        color: theme.colorScheme.outline,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _englishMeaning,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontSize: 15,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Example Sentences
                              Text(
                                "Example Sentences",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...List.generate(_sentences.length, (index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(16.0),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: theme.colorScheme.outlineVariant.withOpacity(0.4),
                                      ),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: theme.colorScheme.primary.withOpacity(0.1),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              "${index + 1}",
                                              style: TextStyle(
                                                color: theme.colorScheme.primary,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _sentences[index],
                                            style: theme.textTheme.bodyLarge?.copyWith(
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                      // Bottom Navigation
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          border: Border(
                            top: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Previous button
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonBorderRadius),
                                ),
                                onPressed: _historyIndex > 0 ? _handlePrevious : null,
                                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                                label: const Text("Previous", style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Counter
                            SizedBox(
                              width: 90,
                              child: Text(
                                "Word $_todayProgress of $_todayTarget",
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Next button
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: AppTheme.buttonBorderRadius,
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    foregroundColor: Colors.white,
                                    shadowColor: Colors.transparent,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: _handleNext,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        _todayProgress >= _todayTarget ? "Finish" : "Next",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_rounded, size: 18),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
