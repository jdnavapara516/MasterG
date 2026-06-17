import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import 'word_learning_screen.dart';

class VocabularyLevelsScreen extends StatefulWidget {
  const VocabularyLevelsScreen({super.key});

  @override
  State<VocabularyLevelsScreen> createState() => _VocabularyLevelsScreenState();
}

class _VocabularyLevelsScreenState extends State<VocabularyLevelsScreen> {
  List<dynamic> _levelsData = [];
  bool _isLoading = true;
  String? _errorMessage;

  final Map<String, Map<String, dynamic>> _levelMetaData = {
    "A1": {
      "title": "Beginner",
      "icon": Icons.child_care_rounded,
      "color": Colors.blue,
      "total_words": 100
    },
    "A2": {
      "title": "Elementary",
      "icon": Icons.directions_walk_rounded,
      "color": Colors.green,
      "total_words": 80
    },
    "B1": {
      "title": "Intermediate",
      "icon": Icons.directions_run_rounded,
      "color": Colors.orange,
      "total_words": 60
    },
    "B2": {
      "title": "Upper Intermediate",
      "icon": Icons.airplanemode_active_rounded,
      "color": Colors.red,
      "total_words": 50
    },
    "C1": {
      "title": "Advanced",
      "icon": Icons.emoji_events_rounded,
      "color": Colors.purple,
      "total_words": 40
    },
    "C2": {
      "title": "Proficient",
      "icon": Icons.psychology_rounded,
      "color": Colors.pink,
      "total_words": 30
    }
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchLevels();
    });
  }

  Future<void> _fetchLevels() async {
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
        Uri.parse("http://127.0.0.1:8000/api/vocabulary/levels/"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _levelsData = jsonDecode(response.body);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = "Failed to load levels. Server error: ${response.statusCode}";
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vocabulary Learning"),
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
                            onPressed: _fetchLevels,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text("Retry Connection"),
                          ),
                        ],
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchLevels,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                      children: [
                        Text(
                          "Vocabulary Learning",
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Choose your English level",
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        ..._levelsData.map((data) {
                          final String levelCode = data["level"];
                          final int learnedWords = data["learned_words"];
                          final meta = _levelMetaData[levelCode] ?? {
                            "title": "Level",
                            "icon": Icons.bookmark_rounded,
                            "color": Colors.blue,
                            "total_words": 50
                          };

                          final String title = "$levelCode ${meta['title']}";
                          final int totalWords = meta['total_words'];
                          final double progress = (learnedWords / totalWords).clamp(0.0, 1.0);
                          final Color color = meta['color'];
                          final IconData icon = meta['icon'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                borderRadius: AppTheme.cardBorderRadius,
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                                  width: 1.2,
                                ),
                                boxShadow: AppTheme.getSoftShadow(context),
                              ),
                              child: ClipRRect(
                                borderRadius: AppTheme.cardBorderRadius,
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => WordLearningScreen(
                                          levelCode: levelCode,
                                          levelTitle: title,
                                        ),
                                      ),
                                    );
                                    _fetchLevels(); // Refresh levels learned count on return
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      children: [
                                        // Left: Level Icon Circle
                                        Container(
                                          width: 52,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: color.withOpacity(0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(icon, color: color, size: 26),
                                        ),
                                        const SizedBox(width: 16),
                                        // Middle: Level Info & Progress
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: theme.textTheme.titleMedium?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "$learnedWords Words Learned",
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 10),
                                              // Progress Indicator Bar
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(4),
                                                      child: SizedBox(
                                                        height: 6,
                                                        child: LinearProgressIndicator(
                                                          value: progress,
                                                          backgroundColor: color.withOpacity(0.1),
                                                          valueColor: AlwaysStoppedAnimation<Color>(color),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    "${(progress * 100).round()}%",
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: color,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        // Right: Arrow Button
                                        Icon(
                                          Icons.arrow_forward_ios_rounded,
                                          color: theme.colorScheme.outline.withOpacity(0.7),
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
      ),
    );
  }
}
