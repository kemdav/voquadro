import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:voquadro/data/models/interview_response_model.dart';
import 'package:voquadro/theme/voquadro_colors.dart';

class InterviewStatsPage extends StatefulWidget {
  final List<InterviewResponseModel> sessionResponses;
  final Color cardBackground;
  final Color primaryPurple;
  final bool isVisible;

  const InterviewStatsPage({
    super.key,
    required this.sessionResponses,
    this.cardBackground = Colors.white,
    required this.primaryPurple,
    this.isVisible = true,
  });

  @override
  State<InterviewStatsPage> createState() => _InterviewStatsPageState();
}

class _InterviewStatsPageState extends State<InterviewStatsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant InterviewStatsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ------------------------------------------------------
    // 1. PREPARE DATA (Normalize to 0.0 - 1.0)
    // ------------------------------------------------------

    // Calculate Average Response Time Score
    // Ideal response time is ~1-2 seconds.
    // 0s = 1.0 (Instant? Maybe too fast, but let's say 1.0)
    // 5s = 0.0 (Too slow)
    double totalResponseTimeMs = 0;
    if (widget.sessionResponses.isNotEmpty) {
      for (var r in widget.sessionResponses) {
        totalResponseTimeMs += r.responseTime.inMilliseconds;
      }
      double avgResponseTimeMs = totalResponseTimeMs / widget.sessionResponses.length;
      // Map 0ms -> 1.0, 5000ms -> 0.0
      double scoreResponseTime = (1.0 - (avgResponseTimeMs / 5000)).clamp(0.0, 1.0);
      
      // TODO: Replace these with real AI analysis data
      double scorePace = 0.75;       // Placeholder
      double scoreFiller = 0.80;     // Placeholder
      double scoreDelivery = 0.65;   // Placeholder
      double scoreRelevance = 0.70;  // Placeholder

      return Column(
        children: [
          const SizedBox(height: 20),

          // TITLE
          FadeSlideTransition(
              controller: _controller,
              intervalStart: 0.0,
              intervalEnd: 0.3,
              child: Text(
                "Interview Analysis",
                style: TextStyle(
                  color: widget.primaryPurple,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // THE CARD
            Expanded(
              child: FadeSlideTransition(
                controller: _controller,
                intervalStart: 0.2,
                intervalEnd: 0.6,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  decoration: BoxDecoration(
                    color: widget.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      Text(
                        "Performance Overview",
                        style: TextStyle(
                          color: widget.primaryPurple,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      // THE RADAR CHART
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final size = math.min(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            );

                            return Center(
                              child: AnimatedBuilder(
                                animation: _controller,
                                builder: (context, child) {
                                  final progress = CurvedAnimation(
                                    parent: _controller,
                                    curve: const Interval(
                                      0.4,
                                      1.0,
                                      curve: Curves.easeOutBack,
                                    ),
                                  ).value;

                                  return CustomPaint(
                                    size: Size(size, size),
                                    painter: RadarChartPainter(
                                      primaryColor: widget.primaryPurple,
                                      animationValue: progress,
                                      // Order: Top, Right, Bottom Right, Bottom Left, Left
                                      scores: [
                                        scorePace,          // Top
                                        scoreFiller,        // Right
                                        scoreResponseTime,  // Bottom Right
                                        scoreDelivery,      // Bottom Left
                                        scoreRelevance,     // Left
                                      ],
                                      labels: [
                                        "Pace\nControl",
                                        "Filler Word\nControl",
                                        "Response\nTime",
                                        "Message\nDelivery",
                                        "Content\nRelevance",
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
    } else {
      return const Center(child: Text("No data available", style: TextStyle(color: Colors.white)));
    }
  }
}

// ---------------------------------------------------------
// CUSTOM PAINTER: RADAR CHART
// ---------------------------------------------------------
class RadarChartPainter extends CustomPainter {
  final Color primaryColor;
  final double animationValue;
  final List<double> scores;
  final List<String> labels;

  RadarChartPainter({
    required this.primaryColor,
    required this.animationValue,
    required this.scores,
    required this.labels,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) * 0.65;

    final paintGrid = Paint()
      ..color = primaryColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paintOuterBorder = Paint()
      ..color = primaryColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paintFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 1. DRAW SOLID BACKGROUND
    final pathBackground = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * (math.pi / 180);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) pathBackground.moveTo(x, y);
      else pathBackground.lineTo(x, y);
    }
    pathBackground.close();
    canvas.drawPath(pathBackground, paintFill);

    // 2. DRAW GRID LINES
    int gridSteps = 4;
    for (int step = 1; step <= gridSteps; step++) {
      double currentRadius = radius * (step / gridSteps);
      final pathGrid = Path();
      for (int i = 0; i < 5; i++) {
        final angle = (i * 72 - 90) * (math.pi / 180);
        final x = center.dx + currentRadius * math.cos(angle);
        final y = center.dy + currentRadius * math.sin(angle);
        if (i == 0) pathGrid.moveTo(x, y);
        else pathGrid.lineTo(x, y);
      }
      pathGrid.close();
      canvas.drawPath(pathGrid, step == gridSteps ? paintOuterBorder : paintGrid);
    }

    // 3. DRAW SPOKES
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * (math.pi / 180);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), paintGrid);
    }

    // 4. DRAW DATA POLYGON
    if (animationValue > 0) {
      final pathData = Path();
      final paintDataStroke = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeJoin = StrokeJoin.round;

      final paintDataFill = Paint()
        ..color = primaryColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 5; i++) {
        final angle = (i * 72 - 90) * (math.pi / 180);
        final val = scores[i] * animationValue;
        final r = radius * (val < 0.05 ? 0.05 : val);
        final x = center.dx + r * math.cos(angle);
        final y = center.dy + r * math.sin(angle);
        if (i == 0) pathData.moveTo(x, y);
        else pathData.lineTo(x, y);
      }
      pathData.close();
      canvas.drawPath(pathData, paintDataFill);
      canvas.drawPath(pathData, paintDataStroke);
    }

    // 5. DRAW LABELS
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    final textRadius = radius + 35;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * (math.pi / 180);
      final x = center.dx + textRadius * math.cos(angle);
      final y = center.dy + textRadius * math.sin(angle);

      textPainter.text = TextSpan(
        text: labels[i],
        style: TextStyle(
          color: primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          height: 1.1,
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.scores != scores;
  }
}

class FadeSlideTransition extends StatelessWidget {
  final AnimationController controller;
  final double intervalStart;
  final double intervalEnd;
  final Widget child;

  const FadeSlideTransition({
    super.key,
    required this.controller,
    required this.intervalStart,
    required this.intervalEnd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double curvedValue = Interval(
          intervalStart,
          intervalEnd,
          curve: Curves.easeOutQuart,
        ).transform(controller.value);

        return Opacity(
          opacity: curvedValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - curvedValue)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
