import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../learn/vocabulary_levels_screen.dart';
import '../learn/grammar_quiz_screen.dart';
import '../learn/speaking_practice_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Section: Greeting, Avatar, Notification
              _buildHeader(context, appState, theme),
              const SizedBox(height: 24),

              // Streak Card
              _buildStreakCard(context, appState, theme),
              const SizedBox(height: 24),

              // Section Title: Quick Stats
              _buildSectionTitle(theme, "Your Stats Today"),
              const SizedBox(height: 12),
              _buildQuickStatsGrid(appState, theme, isDark),
              const SizedBox(height: 28),

              // Section Title: Learning Modules
              _buildSectionTitle(theme, "Learning Modules"),
              const SizedBox(height: 12),
              _buildLearningModulesGrid(context, appState, theme, isDark),
              const SizedBox(height: 28),

              // Section Title: Daily Goals
              _buildSectionTitle(theme, "Daily Goals"),
              const SizedBox(height: 12),
              _buildDailyGoalsCard(context, appState, theme, isDark),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () {
                // Quick feedback
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Hello ${appState.userName}! Keep up the learning!"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary, width: 2),
                  gradient: AppTheme.primaryGradient,
                ),
                child: Center(
                  child: Text(
                    appState.userName.split(" ").where((s) => s.isNotEmpty).map((s) => s[0].toUpperCase()).take(2).join(""),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Good Morning,",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "${appState.userName} 👋",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          ),
          child: IconButton(
            icon: Icon(Icons.notifications_outlined, color: theme.colorScheme.onBackground),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("No new notifications today. Keep practicing!"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStreakCard(BuildContext context, AppState appState, ThemeData theme) {
    final streak = appState.streak;
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: AppTheme.cardBorderRadius,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.local_fire_department_rounded, color: Colors.orangeAccent, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          "${streak.days} Days Streak",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Text(
                "${streak.xp}/${streak.targetXp} XP",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "You are doing amazing!",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Complete speaking and grammar modules today to hit your daily goal.",
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              height: 10,
              child: LinearProgressIndicator(
                value: streak.progress,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildQuickStatsGrid(AppState appState, ThemeData theme, bool isDark) {
    final stats = appState.stats;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        _buildStatCard(theme, isDark, "Words Learned", "${stats.wordsLearned}", Icons.translate_rounded, const Color(0xFF3B82F6)),
        _buildStatCard(theme, isDark, "Grammar Lessons", "${stats.grammarLessonsCompleted}", Icons.menu_book_rounded, const Color(0xFF8B5CF6)),
        _buildStatCard(theme, isDark, "Speaking Sessions", "${stats.speakingSessionsCompleted}", Icons.mic_rounded, const Color(0xFFEC4899)),
        _buildStatCard(theme, isDark, "Chat Sessions", "${stats.chatSessionsCompleted}", Icons.forum_rounded, const Color(0xFF10B981)),
      ],
    );
  }

  Widget _buildStatCard(ThemeData theme, bool isDark, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.015),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningModulesGrid(BuildContext context, AppState appState, ThemeData theme, bool isDark) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.1,
      children: [
        _buildModuleCard(
          context, theme, isDark,
          "Vocabulary", "Learn 5 new words daily",
          Icons.abc_rounded, Colors.blue, (appState.vocabGoalCount / 5.0).clamp(0.0, 1.0),
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VocabularyLevelsScreen())),
        ),
        _buildModuleCard(
          context, theme, isDark,
          "Grammar", "Grammar lessons and quizzes",
          Icons.rule_folder_rounded, Colors.purple, (appState.grammarGoalCount / 1.0).clamp(0.0, 1.0),
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GrammarQuizScreen())),
        ),
        _buildModuleCard(
          context, theme, isDark,
          "Listening", "Listening exercises and audio",
          Icons.headset_rounded, Colors.pink, 0.0,
          () => _showComingSoonSnackBar(context, "Listening"),
        ),
        _buildModuleCard(
          context, theme, isDark,
          "Speaking", "AI speaking practice",
          Icons.mic_external_on_rounded, Colors.orange, (appState.speakingGoalCount / 1.0).clamp(0.0, 1.0),
          () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SpeakingPracticeScreen())),
        ),
        _buildModuleCard(
          context, theme, isDark,
          "AI Chat", "Practice English conversations",
          Icons.chat_bubble_rounded, Colors.teal, (appState.stats.chatSessionsCompleted / 20.0).clamp(0.0, 1.0),
          () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Tap the 'Chat' tab at the bottom to talk to G-Bot!"),
              behavior: SnackBarBehavior.floating,
            ),
          ),
        ),
        _buildModuleCard(
          context, theme, isDark,
          "Revision", "Review learned vocabulary",
          Icons.replay_circle_filled_rounded, Colors.amber, 0.0,
          () => _showComingSoonSnackBar(context, "Revision"),
        ),
      ],
    );
  }

  Widget _buildModuleCard(
    BuildContext context,
    ThemeData theme,
    bool isDark,
    String title,
    String description,
    IconData icon,
    Color color,
    double progress,
    VoidCallback onTap,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppTheme.cardBorderRadius,
        side: BorderSide(color: theme.colorScheme.outlineVariant.withOpacity(0.5), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.outline, size: 14),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Progress",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                      ),
                      Text(
                        "${(progress * 100).round()}%",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      height: 4,
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: color.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDailyGoalsCard(BuildContext context, AppState appState, ThemeData theme, bool isDark) {
    final completePercent = appState.dailyGoalCompletion;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: AppTheme.getSoftShadow(context),
      ),
      child: Row(
        children: [
          // Left Side: Goal items
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGoalRow(theme, "Vocabulary", "${appState.vocabGoalCount}/5 words", appState.vocabGoalCount >= 5, Colors.blue),
                const SizedBox(height: 12),
                _buildGoalRow(theme, "Grammar Quizzes", "${appState.grammarGoalCount}/1 lesson", appState.grammarGoalCount >= 1, Colors.purple),
                const SizedBox(height: 12),
                _buildGoalRow(theme, "Speaking practice", "${appState.speakingGoalCount}/1 session", appState.speakingGoalCount >= 1, Colors.orange),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Right Side: Goal indicator chart
          Column(
            children: [
              SizedBox(
                width: 76,
                height: 76,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: completePercent / 100,
                      strokeWidth: 8,
                      backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                    Center(
                      child: Text(
                        "${completePercent.round()}%",
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Completed",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalRow(ThemeData theme, String title, String value, bool isComplete, Color color) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isComplete ? color : Colors.transparent,
            border: Border.all(color: isComplete ? Colors.transparent : const Color(0xFF94A3B8), width: 1.5),
          ),
          child: isComplete
              ? const Icon(Icons.check, color: Colors.white, size: 12)
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showComingSoonSnackBar(BuildContext context, String moduleName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$moduleName exercises will be fully integrated in the next learning version. Currently simulating."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
