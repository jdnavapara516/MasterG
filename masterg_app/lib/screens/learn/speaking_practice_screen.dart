import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';

class SpeakingPracticeScreen extends StatefulWidget {
  const SpeakingPracticeScreen({super.key});

  @override
  State<SpeakingPracticeScreen> createState() => _SpeakingPracticeScreenState();
}

class _SpeakingPracticeScreenState extends State<SpeakingPracticeScreen> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  bool _hasRecorded = false;
  String _listeningText = "Tap mic to start speaking...";
  double _waveformMultiplier = 0.0;
  
  late AnimationController _waveController;
  Timer? _recordingTimer;
  int _secondsRecorded = 0;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _toggleRecording() {
    if (_isRecording) {
      _stopRecording();
    } else {
      _startRecording();
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
      _hasRecorded = false;
      _listeningText = "Listening...";
      _secondsRecorded = 0;
      _waveformMultiplier = 1.0;
    });

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _secondsRecorded++;
        if (_secondsRecorded == 1) {
          _listeningText = "\"The weather is lovely, and I am learning English today.\"";
        }
        if (_secondsRecorded >= 4) {
          _stopRecording();
        }
      });
    });
  }

  void _stopRecording() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _waveformMultiplier = 0.0;
      _hasRecorded = true;
      _listeningText = "Recorded: \"The weather is lovely, and I am learning English today.\"";
    });

    // Award speaking practice XP
    final appState = AppStateProvider.of(context);
    appState.completeSpeakingSession();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Speaking Practice"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Prompt card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: AppTheme.cardBorderRadius,
                  border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
                  boxShadow: AppTheme.getSoftShadow(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "SPEAK THIS PHRASE",
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      "\"The weather is lovely, and I am learning English today.\"",
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Animated wave canvas
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _waveController,
                      builder: (context, child) {
                        return CustomPaint(
                          size: const Size(double.infinity, 120),
                          painter: WaveformPainter(
                            phase: _waveController.value * 2 * pi,
                            multiplier: _waveformMultiplier,
                            color: theme.colorScheme.primary,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        _listeningText,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _isRecording ? theme.colorScheme.primary : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // AI Feedback details (shown after recording)
              if (_hasRecorded) ...[
                _buildFeedbackCard(theme, isDark),
                const SizedBox(height: 30),
              ],

              // Microphone Button with Pulse Shadow
              Center(
                child: GestureDetector(
                  onTap: _toggleRecording,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _isRecording ? AppTheme.flameGradient : AppTheme.primaryGradient,
                      boxShadow: [
                        BoxShadow(
                          color: (_isRecording ? Colors.orange : theme.colorScheme.primary).withOpacity(0.35),
                          blurRadius: _isRecording ? 24 : 14,
                          spreadRadius: _isRecording ? 6 : 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  _isRecording ? "TAP TO FINISH" : "TAP TO TALK",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                    color: _isRecording ? Colors.orange : theme.colorScheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F4EA),
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(color: const Color(0xFF10B981), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                "AI Pronunciation Report",
                style: TextStyle(
                  color: Color(0xFF137333),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Accuracy Score:", style: TextStyle(color: Color(0xFF137333), fontSize: 13, fontWeight: FontWeight.w600)),
              Text("94% (Excellent)", style: TextStyle(color: Color(0xFF137333), fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 6),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Fluency & Pace:", style: TextStyle(color: Color(0xFF137333), fontSize: 13, fontWeight: FontWeight.w600)),
              Text("90%", style: TextStyle(color: Color(0xFF137333), fontSize: 13, fontWeight: FontWeight.w800)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Color(0xFF10B981), thickness: 0.5),
          const SizedBox(height: 8),
          const Text(
            "Feedback: Great sentence flow! Your vowel sounds in 'weather' and 'learning' are perfect. Keep practicing daily to build speech confidence.",
            style: TextStyle(
              color: Color(0xFF137333),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF137333).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.flash_on_rounded, color: Colors.orange, size: 16),
                SizedBox(width: 4),
                Text(
                  "+40 Speaking Practice XP Earned!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF137333)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final double phase;
  final double multiplier;
  final Color color;

  WaveformPainter({
    required this.phase,
    required this.multiplier,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (multiplier == 0) {
      // Draw flat line
      final paint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }

    final paint1 = Paint()
      ..color = color.withOpacity(0.7)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final paint2 = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path1 = Path();
    final path2 = Path();

    final midY = size.height / 2;
    path1.moveTo(0, midY);
    path2.moveTo(0, midY);

    for (double x = 0; x <= size.width; x += 2) {
      // Sine wave calculation
      final normX = x / size.width;
      final envelope = sin(normX * pi); // fades out at edges
      
      final y1 = midY + sin(normX * 4 * pi - phase) * 35 * envelope * multiplier;
      final y2 = midY + cos(normX * 6 * pi + phase) * 20 * envelope * multiplier;

      path1.lineTo(x, y1);
      path2.lineTo(x, y2);
    }

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.multiplier != multiplier;
  }
}
