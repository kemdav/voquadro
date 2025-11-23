import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/src/models/session_model.dart';

class StatFeedbackPage extends StatefulWidget {
  const StatFeedbackPage({
    super.key,
    required this.cardBackground,
    required this.primaryPurple,
    required this.isVisible,
  });

  final Color cardBackground;
  final Color primaryPurple; 
  final bool isVisible; 


  @override
  State<StatFeedbackPage> createState() => _StatFeedbackPageState();
}

class _StatFeedbackPageState extends State<StatFeedbackPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Animation for Fade In + Chart Growth
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

   @override
  void didUpdateWidget(covariant StatFeedbackPage oldWidget) {
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
    final controller = context.watch<PublicSpeakingController>();
    final Session? session = controller.sessionResult;

    if (session == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // ------------------------------------------------------
    // 1. PREPARE DATA (Normalize to 0.0 - 1.0)
    // ------------------------------------------------------
    
    // A. Filler Control (Top)
    // Assuming EXP is 0-100, divide by 100.
    final double scoreFiller = (session.fillerControlEXP / 100).clamp(0.0, 1.0);

    // B. Pace Control (Right)
    final double scorePace = (session.paceControlEXP / 100).clamp(0.0, 1.0);

    // C. Clarity & Flow (Bottom Right)
    final double scoreClarity = (session.clarityStructureScore / 100).clamp(0.0, 1.0);

    // D. Vocal Delivery (Bottom Left)
    // Mapping 'Overall Rating' (assuming 0-10) to 0-1. Adjust if your scale differs.
    final double scoreVocal = (session.overallRating / 10).clamp(0.0, 1.0);

    // E. Message Depth (Left)
    final double scoreContent = (session.contentClarityScore / 100).clamp(0.0, 1.0);

    return Scaffold(
      // Using a very light purple background for the whole screen if needed
      backgroundColor: Colors.purple.withValues(alpha: 0.05),
      body: Column(
        children: [
          const SizedBox(height: 60), // Top spacing
          
          // 2. MAIN TITLE
          FadeSlideTransition(
            controller: _controller,
            intervalStart: 0.0,
            intervalEnd: 0.3,
            child: Text(
              "Dolph's Thoughts",
              style: TextStyle(
                color: widget.primaryPurple,
                fontSize: 32,
                fontWeight: FontWeight.w900, // Extra bold
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          const SizedBox(height: 20),

          // 3. THE CARD
          Expanded(
            child: FadeSlideTransition(
              controller: _controller,
              intervalStart: 0.2,
              intervalEnd: 0.6,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                decoration: BoxDecoration(
                  color: widget.cardBackground, // Likely a very light purple
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
                    
                    // CARD SUBTITLE
                    Text(
                      "How did you do, really?",
                      style: TextStyle(
                        color: widget.primaryPurple,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    // 4. THE RADAR CHART
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate size to fit nicely
                          final size = math.min(constraints.maxWidth, constraints.maxHeight);
                          
                          return Center(
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                // Curved animation for the chart growth
                                final progress = CurvedAnimation(
                                  parent: _controller,
                                  curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack),
                                ).value;

                                return CustomPaint(
                                  size: Size(size, size),
                                  painter: RadarChartPainter(
                                    primaryColor: widget.primaryPurple,
                                    animationValue: progress,
                                    // Pass the 5 scores in clockwise order starting from Top
                                    scores: [
                                      scoreFiller,  // Top
                                      scorePace,    // Right
                                      scoreClarity, // Bottom Right
                                      scoreVocal,   // Bottom Left
                                      scoreContent, // Left
                                    ],
                                    labels: [
                                      "Filler Word\nControl",
                                      "Pace\nControl",
                                      "Clarity &\nFlow",
                                      "Vocal\nDelivery",
                                      "Message\nDepth",
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
      ),
    );
  }
}

// ---------------------------------------------------------
// CUSTOM PAINTER: RADAR CHART
// ---------------------------------------------------------
class RadarChartPainter extends CustomPainter {
  final Color primaryColor;
  final double animationValue;
  final List<double> scores; // 5 values between 0.0 and 1.0
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

    // Styles
    final paintGrid = Paint()
      ..color = primaryColor.withValues(alpha: 0.2) // Faint lines for inner rings
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paintOuterBorder = Paint()
      ..color = primaryColor.withValues(alpha: 0.5) // Darker line for outer border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paintFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 1. DRAW SOLID BACKGROUND FIRST
    // We calculate the outermost path first to fill the background white
    final pathBackground = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * (math.pi / 180);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0) pathBackground.moveTo(x, y);
      else pathBackground.lineTo(x, y);
    }
    pathBackground.close();
    canvas.drawPath(pathBackground, paintFill); // Draw white background

    // 2. DRAW CONCENTRIC GRID LINES
    // Now we draw the lines on TOP of the white background
    int gridSteps = 4; // How many rings you want
    
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

      // Use darker border for the outermost ring, lighter for inner rings
      canvas.drawPath(pathGrid, step == gridSteps ? paintOuterBorder : paintGrid);
    }

    // 3. DRAW SPOKES (Lines from center to corners)
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * (math.pi / 180);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), paintGrid);
    }

    // 4. DRAW DATA POLYGON (The user's score)
    if (animationValue > 0) {
      final pathData = Path();
      final paintDataStroke = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..strokeJoin = StrokeJoin.round;

      final paintDataFill = Paint()
        ..color = primaryColor.withValues(alpha: 0.2) // Semi-transparent fill
        ..style = PaintingStyle.fill;

      for (int i = 0; i < 5; i++) {
        final angle = (i * 72 - 90) * (math.pi / 180);
        final val = scores[i] * animationValue;
        // Ensure a tiny minimum value so it doesn't collapse
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
          fontSize: 14,
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
    return oldDelegate.animationValue != animationValue;
  }
}

// ---------------------------------------------------------
// REUSABLE ANIMATION WRAPPER
// ---------------------------------------------------------
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
        final animation = CurvedAnimation(
          parent: controller,
          curve: Interval(
            intervalStart,
            intervalEnd,
            curve: Curves.easeOutQuart,
          ),
        );

        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}