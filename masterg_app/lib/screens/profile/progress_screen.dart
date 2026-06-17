import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../theme/theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppStateProvider.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Learning Progress"),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          children: [
            // Title
            Text(
              "Analytics & Charts",
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Visualize your English mastery trends over time.",
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),

            // Weekly Activity Custom Painted Chart
            _buildChartSection(
              context, theme, isDark,
              title: "Weekly Activity (XP Earned)",
              subtitle: "Tracks daily continuous learning consistency",
              chartHeight: 140,
              painter: WeeklyActivityPainter(
                data: [35, 50, 20, 80, 40, 110, appState.streak.xp.toDouble()],
                color: theme.colorScheme.primary,
                secondaryColor: theme.colorScheme.secondary,
              ),
              bottomLabels: const ["M", "T", "W", "T", "F", "S", "S"],
            ),
            const SizedBox(height: 20),

            // Vocabulary Growth Custom Painted Chart
            _buildChartSection(
              context, theme, isDark,
              title: "Vocabulary Growth",
              subtitle: "Cumulative words added to your glossary",
              chartHeight: 140,
              painter: VocabularyGrowthPainter(
                data: [90, 100, 115, 120, 132, 138, appState.stats.wordsLearned.toDouble()],
                color: theme.colorScheme.secondary,
              ),
              bottomLabels: const ["May", "Jun", "Jul", "Aug", "Sep", "Oct", "Now"],
            ),
            const SizedBox(height: 24),

            // Score milestones
            Text(
              "Learning Scores",
              style: theme.textTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildScoreList(theme, appState),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(
    BuildContext context,
    ThemeData theme,
    bool isDark, {
    required String title,
    required String subtitle,
    required double chartHeight,
    required CustomPainter painter,
    required List<String> bottomLabels,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppTheme.cardBorderRadius,
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: AppTheme.getSoftShadow(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: chartHeight,
            child: CustomPaint(
              size: Size.infinite,
              painter: painter,
            ),
          ),
          const SizedBox(height: 12),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: bottomLabels.map((label) {
              return SizedBox(
                width: 24,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreList(ThemeData theme, AppState appState) {
    // Standard score progress meters
    return Column(
      children: [
        _buildScoreRow(theme, "Grammar Mastery", 0.78, "78%", Colors.purple),
        const SizedBox(height: 14),
        _buildScoreRow(theme, "Speaking Pronunciation", 0.92, "92%", Colors.orange),
        const SizedBox(height: 14),
        _buildScoreRow(theme, "Listening Comprehension", 0.64, "64%", Colors.pink),
      ],
    );
  }

  Widget _buildScoreRow(ThemeData theme, String title, double percentage, String labelText, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.bold)),
              Text(labelText, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 6,
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Weekly Activity (Vertical Bar Graph)
class WeeklyActivityPainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final Color secondaryColor;

  WeeklyActivityPainter({required this.data, required this.color, required this.secondaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final maxVal = data.reduce(max);
    final widthPerBar = size.width / data.length;
    final barWidth = widthPerBar * 0.44;

    for (int i = 0; i < data.length; i++) {
      final val = data[i];
      final pct = maxVal == 0 ? 0.0 : val / maxVal;
      final barHeight = size.height * pct * 0.85; // 85% maximum height
      
      final x = (i * widthPerBar) + (widthPerBar - barWidth) / 2;
      final y = size.height - barHeight;

      // Color current day differently or draw gradient
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(8),
      );

      paint.shader = LinearGradient(
        colors: [color.withOpacity(0.8), secondaryColor.withOpacity(0.9)],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      ).createShader(Rect.fromLTWH(x, y, barWidth, barHeight));

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant WeeklyActivityPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}

// Custom Painter for Vocabulary Growth (Curved Line Graph)
class VocabularyGrowthPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  VocabularyGrowthPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()..style = PaintingStyle.fill;

    final maxVal = data.reduce(max);
    final minVal = data.reduce(min);
    final valRange = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    final widthBetween = size.width / (data.length - 1);
    
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final pct = (data[i] - minVal) / valRange;
      final x = i * widthBetween;
      final y = size.height - (pct * size.height * 0.7) - 15; // padding
      points.add(Offset(x, y));
    }

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      // Draw smooth curve using cubic bezier
      final p0 = points[i];
      final p1 = points[i + 1];
      final controlX = p0.dx + (p1.dx - p0.dx) / 2;
      path.cubicTo(controlX, p0.dy, controlX, p1.dy, p1.dx, p1.dy);
    }

    // Draw lines
    canvas.drawPath(path, linePaint);

    // Draw gradient fill below the line
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    fillPaint.shader = LinearGradient(
      colors: [color.withOpacity(0.24), color.withOpacity(0.01)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    // Draw indicator dot on the last point
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final ringPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(points.last, 6, ringPaint);
    canvas.drawCircle(points.last, 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant VocabularyGrowthPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
