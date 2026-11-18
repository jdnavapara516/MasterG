import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';
import '../learn/vocabulary_levels_screen.dart';
import '../../grammar/screens/grammar_topics_screen.dart';
import '../learn/speaking_practice_screen.dart';
import '../learn/rapid_fire_screen.dart';
import '../learn/revision_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenChat});

  final VoidCallback onOpenChat;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AppStateProvider.of(context).fetchUserProfile();
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await appState.fetchUserProfile();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildHeader(context, appState, theme),
                    const SizedBox(height: 22),
                    _buildHeroCard(context, appState, theme),
                    const SizedBox(height: 26),
                    _buildQuickStats(appState, theme, isDark),
                    const SizedBox(height: 28),
                    _buildSectionTitle(theme, "Learning Modules"),
                    const SizedBox(height: 14),
                    _buildLearningModules(context, appState, theme, isDark),
                    const SizedBox(height: 28),
                    _buildSectionTitle(theme, "Daily Goals"),
                    const SizedBox(height: 14),
                    _buildDailyGoals(context, appState, theme, isDark),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState appState, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.primaryGradient,
            border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 2),
          ),
          child: Center(
            child: Text(
              _initials(appState.userName),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 17),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
              Text(
                appState.userName,
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 20),
              ),
            ],
          ),
        ),
        _buildIconButton(
          context, theme,
          icon: Icons.notifications_none_rounded,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text("No new notifications"),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIconButton(BuildContext context, ThemeData theme, {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: theme.colorScheme.onSurface.withValues(alpha: 0.7), size: 22),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, AppState appState, ThemeData theme) {
    final streak = appState.streak;
    final progress = (appState.pointBalance % 500) / 500.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFFD166), size: 18),
                    const SizedBox(width: 5),
                    Text(
                      "${streak.days} Day Streak",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.bolt_rounded, color: Color(0xFFFFD166), size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "${appState.pointBalance} pts",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Keep up the momentum!",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.3),
          ),
          const SizedBox(height: 6),
          Text(
            "Complete activities to earn points and build your streak.",
            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 8,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "${500 - (appState.pointBalance % 500)} to go",
                style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(AppState appState, ThemeData theme, bool isDark) {
    final stats = appState.stats;
    return Row(
      children: [
        Expanded(child: _buildMiniStat(theme, isDark, Icons.translate_rounded, "${stats.wordsLearned}", "Words", const Color(0xFF6366F1))),
        const SizedBox(width: 10),
        Expanded(child: _buildMiniStat(theme, isDark, Icons.menu_book_rounded, "${stats.grammarLessonsCompleted}", "Grammar", const Color(0xFF8B5CF6))),
        const SizedBox(width: 10),
        Expanded(child: _buildMiniStat(theme, isDark, Icons.mic_rounded, "${stats.speakingSessionsCompleted}", "Speaking", const Color(0xFFEC4899))),
        const SizedBox(width: 10),
        Expanded(child: _buildMiniStat(theme, isDark, Icons.forum_rounded, "${stats.chatSessionsCompleted}", "Chat", const Color(0xFF10B981))),
      ],
    );
  }

  Widget _buildMiniStat(ThemeData theme, bool isDark, IconData icon, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 18)),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, fontSize: 18));
  }

  Widget _buildLearningModules(BuildContext context, AppState appState, ThemeData theme, bool isDark) {
    final modules = [
      _ModuleData("Vocabulary", "Learn new words daily", Icons.abc_rounded, const Color(0xFF6366F1),
        (appState.vocabGoalCount / 5.0).clamp(0.0, 1.0),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const VocabularyLevelsScreen()))),
      _ModuleData("Grammar", "Lessons & quizzes", Icons.rule_folder_rounded, const Color(0xFF8B5CF6),
        (appState.grammarGoalCount / 1.0).clamp(0.0, 1.0),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrammarTopicsScreen()))),
      _ModuleData("Rapid Fire", "Spelling challenge", Icons.bolt_rounded, const Color(0xFF14B8A6),
        (appState.pointBalance / 500.0).clamp(0.0, 1.0),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RapidFireScreen()))),
      _ModuleData("Speaking", "AI conversation", Icons.mic_external_on_rounded, const Color(0xFFF97316),
        (appState.speakingGoalCount / 1.0).clamp(0.0, 1.0),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SpeakingPracticeScreen()))),
      _ModuleData("AI Chat", "Practice English", Icons.chat_bubble_rounded, const Color(0xFF10B981),
        (appState.stats.chatSessionsCompleted / 20.0).clamp(0.0, 1.0),
        widget.onOpenChat),
      _ModuleData("Revision", "Review vocabulary", Icons.replay_circle_filled_rounded, const Color(0xFFF59E0B),
        0.0,
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RevisionScreen()))),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) => _buildModuleCard(theme, isDark, modules[index]),
    );
  }

  Widget _buildModuleCard(ThemeData theme, bool isDark, _ModuleData module) {
    return GestureDetector(
      onTap: module.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: module.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(module.icon, color: module.color, size: 22),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: theme.colorScheme.outline.withValues(alpha: 0.5), size: 14),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(module.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(module.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
              ],
            ),
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Progress", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface.withValues(alpha: 0.4))),
                    Text("${(module.progress * 100).round()}%", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: module.color)),
                  ],
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 4,
                    child: LinearProgressIndicator(
                      value: module.progress,
                      backgroundColor: module.color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(module.color),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyGoals(BuildContext context, AppState appState, ThemeData theme, bool isDark) {
    final percent = appState.dailyGoalCompletion;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4)),
        boxShadow: AppTheme.getSoftShadow(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGoalItem(theme, "Vocabulary", "${appState.vocabGoalCount}/5 words", appState.vocabGoalCount >= 5, const Color(0xFF6366F1)),
                const SizedBox(height: 14),
                _buildGoalItem(theme, "Grammar", "${appState.grammarGoalCount}/1 lesson", appState.grammarGoalCount >= 1, const Color(0xFF8B5CF6)),
                const SizedBox(height: 14),
                _buildGoalItem(theme, "Speaking", "${appState.speakingGoalCount}/1 session", appState.speakingGoalCount >= 1, const Color(0xFFF97316)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            children: [
              SizedBox(
                width: 72, height: 72,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: percent / 100,
                      strokeWidth: 7,
                      strokeCap: StrokeCap.round,
                      backgroundColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percent >= 100 ? const Color(0xFF10B981) : theme.colorScheme.primary,
                      ),
                    ),
                    Center(
                      child: Text(
                        "${percent.round()}%",
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                percent >= 100 ? "Complete!" : "Today",
                style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalItem(ThemeData theme, String title, String value, bool done, Color color) {
    return Row(
      children: [
        Container(
          width: 22, height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? color : Colors.transparent,
            border: Border.all(color: done ? Colors.transparent : theme.colorScheme.outline.withValues(alpha: 0.3), width: 1.5),
          ),
          child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 13) : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
              Text(value, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }


  String _initials(String name) {
    return name.split(" ").where((s) => s.isNotEmpty).map((s) => s[0].toUpperCase()).take(2).join();
  }
}

class _ModuleData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final double progress;
  final VoidCallback onTap;

  const _ModuleData(this.title, this.subtitle, this.icon, this.color, this.progress, this.onTap);
}
