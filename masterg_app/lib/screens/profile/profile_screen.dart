import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          children: [
            // Header: Profile Pic, Name, Level
            _buildProfileHeader(theme, appState),
            const SizedBox(height: 28),

            // Statistics Grid Section
            Text(
              "Your Milestones",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildMilestonesGrid(theme, isDark, appState),
            const SizedBox(height: 28),

            // Achievements Badges
            Text(
              "Badges & Achievements",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildAchievementsGrid(theme, isDark),
            const SizedBox(height: 28),

            // Account settings list
            Text(
              "Settings & Preferences",
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            _buildSettingsPanel(context, theme, appState),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, AppState appState) {
    return Column(
      children: [
        Center(
          child: Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colorScheme.primary, width: 3),
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Center(
                  child: Text(
                    "JN",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.surface, width: 2),
                  ),
                  child: const Icon(
                    Icons.edit_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          appState.userName,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          appState.userLevel,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildMilestonesGrid(ThemeData theme, bool isDark, AppState appState) {
    final stats = appState.stats;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildMilestoneCard(theme, isDark, "Words Learned", "${stats.wordsLearned}", Icons.translate_rounded, Colors.blue),
        _buildMilestoneCard(theme, isDark, "Current Streak", "${appState.streak.days} Days", Icons.local_fire_department_rounded, Colors.orange),
        _buildMilestoneCard(theme, isDark, "Longest Streak", "24 Days", Icons.bolt_rounded, Colors.pink),
        _buildMilestoneCard(theme, isDark, "Total XP Earned", "4.8k XP", Icons.stars_rounded, Colors.amber),
      ],
    );
  }

  Widget _buildMilestoneCard(ThemeData theme, bool isDark, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
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
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsGrid(ThemeData theme, bool isDark) {
    // 5 badges
    final List<Map<String, dynamic>> badges = [
      {"name": "7 Day Streak", "icon": Icons.local_fire_department, "color": Colors.orange, "desc": "Continuous learning"},
      {"name": "30 Day Streak", "icon": Icons.workspace_premium, "color": Colors.pink, "desc": "Month long master"},
      {"name": "Vocab Master", "icon": Icons.translate, "color": Colors.blue, "desc": "Know 100+ words"},
      {"name": "Grammar Expert", "icon": Icons.spellcheck, "color": Colors.purple, "desc": "Perfect rule quiz"},
      {"name": "Speaking Champ", "icon": Icons.mic, "color": Colors.teal, "desc": "Excellent feedback"},
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        itemBuilder: (context, index) {
          final b = badges[index];
          return Padding(
            padding: const EdgeInsets.only(right: 14.0, bottom: 4.0),
            child: Container(
              width: 110,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: b["color"].withOpacity(0.12),
                    ),
                    child: Icon(b["icon"], color: b["color"], size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    b["name"],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    b["desc"],
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 9),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsPanel(BuildContext context, ThemeData theme, AppState appState) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildSettingsRow(
            theme,
            icon: Icons.person_outline_rounded,
            title: "Edit Profile",
            onTap: () => _showSettingSnack(context, "Edit Profile"),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFE2E8F0)),
          _buildSettingsRow(
            theme,
            icon: Icons.lock_outline_rounded,
            title: "Change Password",
            onTap: () => _showSettingSnack(context, "Change Password"),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFE2E8F0)),
          _buildSettingsToggleRow(
            theme,
            icon: Icons.dark_mode_outlined,
            title: "Dark Mode",
            value: appState.isDarkMode,
            onChanged: (val) {
              appState.toggleTheme();
            },
          ),
          const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFE2E8F0)),
          _buildSettingsRow(
            theme,
            icon: Icons.language_outlined,
            title: "Language Preferences",
            onTap: () => _showSettingSnack(context, "Language preferences"),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20, color: Color(0xFFE2E8F0)),
          _buildSettingsRow(
            theme,
            icon: Icons.logout_rounded,
            title: "Logout",
            titleColor: Colors.redAccent,
            showTrailing: false,
            onTap: () {
              appState.logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsRow(
    ThemeData theme, {
    required IconData icon,
    required String title,
    Color? titleColor,
    bool showTrailing = true,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? theme.colorScheme.onSurface),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: titleColor ?? theme.colorScheme.onSurface,
        ),
      ),
      trailing: showTrailing ? const Icon(Icons.arrow_forward_ios_rounded, size: 14) : null,
      onTap: onTap,
    );
  }

  Widget _buildSettingsToggleRow(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: theme.colorScheme.onSurface),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  void _showSettingSnack(BuildContext context, String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$name panel is simulated in this learning path."),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
