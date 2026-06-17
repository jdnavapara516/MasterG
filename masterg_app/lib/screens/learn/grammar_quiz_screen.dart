import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';

class QuizQuestion {
  final String sentence;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  QuizQuestion({
    required this.sentence,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

class GrammarQuizScreen extends StatefulWidget {
  const GrammarQuizScreen({super.key});

  @override
  State<GrammarQuizScreen> createState() => _GrammarQuizScreenState();
}

class _GrammarQuizScreenState extends State<GrammarQuizScreen> {
  int _questionIndex = 0;
  int? _selectedAnswerIndex;
  bool _isAnswerSubmitted = false;
  int _score = 0;

  final List<QuizQuestion> _questions = [
    QuizQuestion(
      sentence: "Neither of the candidates _______ qualified for the English trainer position.",
      options: ["are", "is", "were", "have"],
      correctIndex: 1,
      explanation: "'Neither' is a singular pronoun and takes a singular verb ('is').",
    ),
    QuizQuestion(
      sentence: "If I _______ you, I would practice speaking English every day.",
      options: ["was", "am", "were", "be"],
      correctIndex: 2,
      explanation: "In hypothetical conditions (subjunctive mood), we use 'were' for all subject pronouns.",
    ),
    QuizQuestion(
      sentence: "She has been studying grammar _______ three hours.",
      options: ["since", "for", "during", "before"],
      correctIndex: 1,
      explanation: "We use 'for' to describe a duration of time (three hours), and 'since' for a specific starting point.",
    ),
    QuizQuestion(
      sentence: "By the time the class starts, I _______ my vocabulary homework.",
      options: ["will finish", "will have finished", "finish", "would finish"],
      correctIndex: 1,
      explanation: "The future perfect tense ('will have finished') expresses an action completed before another future event.",
    ),
  ];

  void _submitAnswer() {
    if (_selectedAnswerIndex == null) return;

    setState(() {
      _isAnswerSubmitted = true;
      if (_selectedAnswerIndex == _questions[_questionIndex].correctIndex) {
        _score += 1;
      }
    });
  }

  void _nextQuestion(AppState state) {
    if (_questionIndex < _questions.length - 1) {
      setState(() {
        _questionIndex += 1;
        _selectedAnswerIndex = null;
        _isAnswerSubmitted = false;
      });
    } else {
      _completeQuiz(state);
    }
  }

  void _completeQuiz(AppState state) {
    state.completeGrammarQuiz();
    final earnedXp = _score * 25;

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
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 24),
              const Text(
                "Quiz Completed!",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "You scored $_score out of ${_questions.length} questions correctly.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.flash_on_rounded, color: Colors.indigoAccent, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      "+$earnedXp XP Added",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6366F1),
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
                    state.addXp(earnedXp);
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to dashboard
                  },
                  child: const Text("Awesome!"),
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
    final question = _questions[_questionIndex];
    final isCorrect = _selectedAnswerIndex == question.correctIndex;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Grammar Quiz"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  height: 8,
                  child: LinearProgressIndicator(
                    value: (_questionIndex + 1) / _questions.length,
                    backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.4),
                    valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      "QUESTION ${_questionIndex + 1} OF ${_questions.length}",
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Sentence Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: AppTheme.cardBorderRadius,
                        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                        boxShadow: AppTheme.getSoftShadow(context),
                      ),
                      child: Text(
                        question.sentence,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 19,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Options list
                    ...List.generate(question.options.length, (index) {
                      final option = question.options[index];
                      final isSelected = _selectedAnswerIndex == index;
                      Color itemBorderColor = theme.colorScheme.outlineVariant;
                      Color itemBgColor = theme.colorScheme.surface;

                      if (isSelected) {
                        itemBorderColor = theme.colorScheme.primary;
                        itemBgColor = theme.colorScheme.primary.withOpacity(0.06);
                      }

                      if (_isAnswerSubmitted) {
                        if (index == question.correctIndex) {
                          itemBorderColor = const Color(0xFF10B981);
                          itemBgColor = const Color(0xFF10B981).withOpacity(0.08);
                        } else if (isSelected) {
                          itemBorderColor = const Color(0xFFEF4444);
                          itemBgColor = const Color(0xFFEF4444).withOpacity(0.08);
                        }
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: itemBgColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: itemBorderColor, width: isSelected ? 2.2 : 1.2),
                          ),
                          child: InkWell(
                            onTap: _isAnswerSubmitted
                                ? null
                                : () {
                                    setState(() {
                                      _selectedAnswerIndex = index;
                                    });
                                  },
                            borderRadius: BorderRadius.circular(18),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                              child: Row(
                                children: [
                                  // Circle Index Label
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant.withOpacity(0.4),
                                    ),
                                    child: Center(
                                      child: Text(
                                        String.fromCharCode(65 + index),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? Colors.white : theme.colorScheme.onSurface.withOpacity(0.8),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (_isAnswerSubmitted && index == question.correctIndex)
                                    const Icon(Icons.check_circle, color: Color(0xFF10B981))
                                  else if (_isAnswerSubmitted && isSelected && !isCorrect)
                                    const Icon(Icons.cancel, color: Color(0xFFEF4444))
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),

            // Answer evaluation overlay and trigger button
            _buildActionPanel(appState, question, isCorrect, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPanel(AppState appState, QuizQuestion question, bool isCorrect, ThemeData theme) {
    if (!_isAnswerSubmitted) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedAnswerIndex == null ? Colors.grey[400] : theme.colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          onPressed: _selectedAnswerIndex == null ? null : _submitAnswer,
          child: const Text("Check Answer"),
        ),
      );
    }

    final panelColor = isCorrect ? const Color(0xFFE6F4EA) : const Color(0xFFFCE8E6);
    final outlineColor = isCorrect ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final textColor = isCorrect ? const Color(0xFF137333) : const Color(0xFFC5221F);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: panelColor,
        border: Border(
          top: BorderSide(color: outlineColor, width: 2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                isCorrect ? Icons.check_circle_rounded : Icons.error_rounded,
                color: outlineColor,
                size: 28,
              ),
              const SizedBox(width: 10),
              Text(
                isCorrect ? "Brilliant! You are correct." : "Incorrect Answer",
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question.explanation,
            style: TextStyle(
              color: textColor.withOpacity(0.9),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: outlineColor,
              foregroundColor: Colors.white,
            ),
            onPressed: () => _nextQuestion(appState),
            child: Text(
              _questionIndex < _questions.length - 1 ? "Next Question" : "View Results",
            ),
          ),
        ],
      ),
    );
  }
}
