import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import 'vocabulary_levels_screen.dart';
import 'grammar_quiz_screen.dart';
import 'speaking_practice_screen.dart';

class LearnHubScreen extends StatelessWidget {
  const LearnHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Learning Hub"),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            // Level progress
            _buildLevelProgressCard(theme, appState),
            const SizedBox(height: 28),

            // Modules path
            Text(
              "Your Learning Paths",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),

            _buildPathCard(
              theme, isDark,
              title: "📖 Daily Vocabulary Stack",
              subtitle: "Build word recognition & recall",
              description: "Go through 7 flashcards, learn definitions, usage examples, and translations.",
              progressText: "${appState.vocabGoalCount}/5 words complete",
              progress: appState.vocabGoalCount / 5.0,
              color: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VocabularyLevelsScreen())),
            ),
            const SizedBox(height: 16),

            _buildPathCard(
              theme, isDark,
              title: "📝 Master Grammar Rules",
              subtitle: "Conjunctions, relative pronouns, and tenses",
              description: "Take interactive multiple choice checks to test grammar, spelling, and structures.",
              progressText: "${appState.grammarGoalCount}/1 lesson complete",
              progress: appState.grammarGoalCount / 1.0,
              color: Colors.purple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GrammarQuizScreen())),
            ),
            const SizedBox(height: 16),

            _buildPathCard(
              theme, isDark,
              title: "🎤 Speech & Conversational Training",
              subtitle: "AI Speech and Accent evaluator",
              description: "Practice vocal exercises by reading sentences. The AI scans accuracy and pace.",
              progressText: "${appState.speakingGoalCount}/1 session complete",
              progress: appState.speakingGoalCount / 1.0,
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SpeakingPracticeScreen())),
            ),
            const SizedBox(height: 16),

            _buildPathCard(
              theme, isDark,
              title: "🎧 Audio Listening Comp",
              subtitle: "Listen and answer questions",
              description: "Improve verbal tracking with native recordings and scenario tests.",
              progressText: "Locked • Level up to open",
              progress: 0.0,
              color: Colors.pink,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Complete previous modules to unlock Listening comprehension."),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelProgressCard(ThemeData theme, AppState appState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "CURRENT CURRICULUM",
                    style: TextStyle(
                      color: theme.colorScheme.outline,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appState.userLevel,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.goldGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "LVL 3",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: appState.streak.progress,
                backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.4),
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Reach 500 XP to advance to next level path",
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildPathCard(
    ThemeData theme,
    bool isDark, {
    required String title,
    required String subtitle,
    required String description,
    required String progressText,
    required double progress,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.cardBorderRadius,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                        Text(
                          subtitle,
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.outline, size: 14),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontSize: 13,
                  color: theme.colorScheme.onBackground.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    progressText,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: progress >= 1.0 ? Colors.green : color,
                    ),
                  ),
                  if (progress >= 1.0)
                    const Icon(Icons.check_circle_rounded, color: Colors.green, size: 16)
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: color.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
