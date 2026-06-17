import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';

class VocabularyScreen extends StatefulWidget {
  const VocabularyScreen({super.key});

  @override
  State<VocabularyScreen> createState() => _VocabularyScreenState();
}

class _VocabularyScreenState extends State<VocabularyScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  bool _showBack = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0.0, end: pi).animate(_flipController);
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showBack) {
      _flipController.reverse();
    } else {
      _flipController.forward();
    }
    setState(() {
      _showBack = !_showBack;
    });
  }

  void _handleWordAction(AppState state, bool learned) {
    if (learned) {
      final currentWord = state.vocabularyList[_currentIndex];
      state.learnVocabularyWord(currentWord.word);
    }

    if (_currentIndex < state.vocabularyList.length - 1) {
      // Transition to next card with reset flip
      setState(() {
        if (_showBack) {
          _flipController.reverse();
          _showBack = false;
        }
        _currentIndex += 1;
      });
    } else {
      // Completed all words!
      _showCompletionDialog(state);
    }
  }

  void _showCompletionDialog(AppState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: AppTheme.cardBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.goldGradient,
                ),
                child: const Icon(Icons.stars, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 24),
              const Text(
                "Vocab completed!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Awesome job! You studied all the flashcards in today's daily curriculum stack.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 20),
                    SizedBox(width: 6),
                    Text(
                      "+75 XP Earned",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    state.addXp(75);
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Go back to dashboard
                  },
                  child: const Text("Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);
    final words = appState.vocabularyList;
    final currentWord = words[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Daily Vocabulary"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Progress Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Card ${_currentIndex + 1} of ${words.length}",
                    style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${((_currentIndex) / words.length * 100).round()}% Completed",
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 8,
                  child: LinearProgressIndicator(
                    value: (_currentIndex + 1) / words.length,
                    backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.4),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Interactive Flashcard with Rotation
              Expanded(
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      final transform = Matrix4.identity()
                        ..setEntry(3, 2, 0.001) // perspective
                        ..rotateY(_flipAnimation.value);

                      return Transform(
                        transform: transform,
                        alignment: Alignment.center,
                        child: _flipAnimation.value < pi / 2
                            ? _buildFrontCard(theme, currentWord)
                            : Transform(
                                transform: Matrix4.identity()..rotateY(pi),
                                alignment: Alignment.center,
                                child: _buildBackCard(theme, currentWord),
                              ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Actions Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: AppTheme.buttonBorderRadius),
                        side: BorderSide(color: theme.colorScheme.primary, width: 2),
                      ),
                      onPressed: () => _handleWordAction(appState, false),
                      child: Text(
                        "Still Learning",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.successGradient,
                        borderRadius: AppTheme.buttonBorderRadius,
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () => _handleWordAction(appState, true),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 20),
                            SizedBox(width: 8),
                            Text("I Know This", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(ThemeData theme, VocabularyWord word) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5), width: 1.5),
        boxShadow: AppTheme.getCardShadow(context),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    word.type.toUpperCase(),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  word.word,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "Tap card to flip and see translation",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const Positioned(
            bottom: 20,
            right: 20,
            child: Icon(Icons.flip_camera_android_rounded, color: Color(0xFF64748B), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildBackCard(ThemeData theme, VocabularyWord word) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5), width: 1.5),
        boxShadow: AppTheme.getCardShadow(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "TRANSLATION",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.secondary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              word.translation,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 28,
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            const Divider(color: Color(0xFFE2E8F0)),
            const SizedBox(height: 20),
            Text(
              "DEFINITION",
              style: TextStyle(
                color: theme.colorScheme.outline,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              word.definition,
              style: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Text(
              "EXAMPLE SENTENCE",
              style: TextStyle(
                color: theme.colorScheme.outline,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "\"${word.example}\"",
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: theme.colorScheme.onBackground.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
