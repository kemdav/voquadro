import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/src/models/session_model.dart';

class PublicSpeakingFeedbackModal extends StatefulWidget {
  final Session session;

  const PublicSpeakingFeedbackModal({
    super.key,
    required this.session,
  });

  @override
  State<PublicSpeakingFeedbackModal> createState() =>
      _PublicSpeakingFeedbackModalState();
}

class _PublicSpeakingFeedbackModalState
    extends State<PublicSpeakingFeedbackModal> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color purpleDark = '49416D'.toColor();

    return Dialog(
      backgroundColor: const Color(0xFFF0E6F6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: purpleDark.withValues(alpha: 0.1)),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.session.topic,
                    style: TextStyle(
                      color: purpleDark,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Swipeable Content
            SizedBox(
              height: 450,
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) =>
                    setState(() => _currentPage = page),
                children: [
                  _buildStatsPage(purpleDark),
                  _buildFeedbackPage(purpleDark),
                  _buildTranscriptPage(purpleDark),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Swipe for details',
                  style: TextStyle(
                    color: purpleDark.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    _buildPageIndicator(0, purpleDark),
                    const SizedBox(width: 8),
                    _buildPageIndicator(1, purpleDark),
                    const SizedBox(width: 8),
                    _buildPageIndicator(2, purpleDark),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsPage(Color purpleDark) {
    // Prepare data for Radar Chart
    final session = widget.session;
    final scores = [
      (session.fillerControlEXP / 100).clamp(0.0, 1.0),
      (session.paceControlEXP / 100).clamp(0.0, 1.0),
      (session.clarityStructureScore / 100).clamp(0.0, 1.0),
      (session.vocalDeliveryScore / 100).clamp(0.0, 1.0),
      (session.messageDepthScore / 100).clamp(0.0, 1.0),
    ];
    final labels = [
      'Fillers',
      'Pace',
      'Clarity',
      'Vocal',
      'Depth',
    ];

    return Column(
      children: [
        Expanded(
          flex: 3,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutQuart,
            builder: (context, value, child) {
              return CustomPaint(
                painter: RadarChartPainter(
                  primaryColor: purpleDark,
                  animationValue: value,
                  scores: scores,
                  labels: labels,
                ),
                child: Container(),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          flex: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatTile(
                title: 'Pace',
                value: session.wordsPerMinute.toInt().toString(),
                unit: 'WPM',
                purpleDark: purpleDark,
              ),
              _buildStatTile(
                title: 'Fillers',
                value: session.fillerControl.toInt().toString(),
                unit: 'Count',
                purpleDark: purpleDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required String unit,
    required Color purpleDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: purpleDark.withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: purpleDark,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: purpleDark.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackPage(Color purpleDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "AI Feedback",
          style: TextStyle(
            color: purpleDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _parseFeedback(widget.session.feedback, purpleDark),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _parseFeedback(String feedback, Color color) {
    final List<Widget> widgets = [];
    final lines = feedback.split('\n');

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) continue;

      // Clean the line of bullet points
      String cleanLine = line.replaceAll(RegExp(r'^[•\-\*]\s*'), '');

      if (cleanLine.contains(':')) {
        // It's a main evaluation point (e.g. "Content Quality Evaluation: ...")
        final parts = cleanLine.split(':');
        final title = parts[0].trim();
        String content = parts.sublist(1).join(':').trim();

        // Remove any bullet points that might appear at the start of the content
        content = content.replaceAll(RegExp(r'^[•\-\*]\s*'), '');

        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 4),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: color.withValues(alpha: 0.8),
                  fontSize: 15,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: "$title: ",
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(
                    text: content,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        // It's a sub-point / advice
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "-",
                  style: TextStyle(
                    color: color.withValues(alpha: 0.6),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    cleanLine,
                    style: TextStyle(
                      color: color.withValues(alpha: 0.7),
                      fontSize: 14,
                      height: 1.4,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
    return widgets;
  }

  Widget _buildTranscriptPage(Color purpleDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          "Transcript",
          style: TextStyle(
            color: purpleDark,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Text(
                widget.session.transcript.isNotEmpty
                    ? widget.session.transcript
                    : "No transcript available.",
                style: TextStyle(
                  color: purpleDark.withValues(alpha: 0.8),
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int pageIndex, Color activeColor) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _currentPage == pageIndex ? 24 : 12,
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: _currentPage == pageIndex
            ? activeColor
            : activeColor.withValues(alpha: 0.2),
      ),
    );
  }
}

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
    final radius = (math.min(size.width, size.height) / 2) * 0.75;

    final paintGrid = Paint()
      ..color = primaryColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final paintOuterBorder = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final paintFill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Draw Background
    final pathBackground = Path();
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * (math.pi / 180);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      if (i == 0)
        pathBackground.moveTo(x, y);
      else
        pathBackground.lineTo(x, y);
    }
    pathBackground.close();
    canvas.drawPath(pathBackground, paintFill);

    // Draw Grid
    int gridSteps = 4;
    for (int step = 1; step <= gridSteps; step++) {
      double currentRadius = radius * (step / gridSteps);
      final pathGrid = Path();
      for (int i = 0; i < 5; i++) {
        final angle = (i * 72 - 90) * (math.pi / 180);
        final x = center.dx + currentRadius * math.cos(angle);
        final y = center.dy + currentRadius * math.sin(angle);
        if (i == 0)
          pathGrid.moveTo(x, y);
        else
          pathGrid.lineTo(x, y);
      }
      pathGrid.close();
      canvas.drawPath(
        pathGrid,
        step == gridSteps ? paintOuterBorder : paintGrid,
      );
    }

    // Draw Spokes
    for (int i = 0; i < 5; i++) {
      final angle = (i * 72 - 90) * (math.pi / 180);
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);
      canvas.drawLine(center, Offset(x, y), paintGrid);
    }

    // Draw Data
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
        if (i == 0)
          pathData.moveTo(x, y);
        else
          pathData.lineTo(x, y);
      }
      pathData.close();
      canvas.drawPath(pathData, paintDataFill);
      canvas.drawPath(pathData, paintDataStroke);
    }

    // Draw Labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    final textRadius = radius + 20;

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

