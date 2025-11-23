import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/src/hex_color.dart'; 

class SpeakFeedbackPage extends StatefulWidget {
  const SpeakFeedbackPage({
    super.key,
    required this.cardBackground,
    required this.primaryPurple,
    this.isVisible = true, 
  });

  final Color cardBackground;
  final Color primaryPurple;
  final bool isVisible;

  @override
  State<SpeakFeedbackPage> createState() => _SpeakFeedbackPageState();
}

class _SpeakFeedbackPageState extends State<SpeakFeedbackPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant SpeakFeedbackPage oldWidget) {
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
    final Color accentCyan = "23B5D3".toColor();

    return Consumer<PublicSpeakingController>(
      builder: (context, controller, child) {
        double? score;
        if (controller.overallScore != null) {
          score = double.tryParse(controller.overallScore.toString());
        }

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            children: [
              const SizedBox(height: 20),
              
              // 1. TITLE
              FadeSlideTransition(
                controller: _controller,
                intervalStart: 0.0,
                intervalEnd: 0.4,
                child: Text(
                  'Overall Rating',
                  style: TextStyle(
                    color: widget.primaryPurple,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              // 2. ANIMATED SCORE CIRCLE
              FadeSlideTransition(
                controller: _controller,
                intervalStart: 0.2,
                intervalEnd: 0.6,
                child: _buildScoreRing(score, accentCyan),
              ),

              const SizedBox(height: 30),

              // 3. FEEDBACK CARD
              Expanded(
                child: FadeSlideTransition(
                  controller: _controller,
                  intervalStart: 0.4,
                  intervalEnd: 1.0,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: widget.cardBackground,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          // UPDATED
                          color: widget.primaryPurple.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: _buildFeedbackContent(controller),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Score Ring Widget ---
  Widget _buildScoreRing(double? score, Color color) {
    if (score == null) {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ],
        ),
        child: Center(
          child: CircularProgressIndicator(color: color),
        ),
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: score),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOutExpo,
      builder: (context, value, child) {
        return Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: color.withValues(alpha: 0.1), width: 4),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: value / 10,
                strokeWidth: 8,
                backgroundColor: color.withValues(alpha: 0.1),
                color: color,
                strokeCap: StrokeCap.round,
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      value.toStringAsFixed(0),
                      style: TextStyle(
                        color: widget.primaryPurple,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      "/ 100",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- Feedback Content Logic ---
  Widget _buildFeedbackContent(PublicSpeakingController controller) {
    final feedback = controller.formattedFeedback;

    if (feedback.contains("Generating feedback")) {
      return _buildAnalyzingState();
    }

    if (feedback.contains("Error") || feedback.contains("No feedback")) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 16),
          Text(
            feedback,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => controller.generateAIFeedback(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry Analysis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (controller.currentQuestion != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // UPDATED
              color: widget.primaryPurple.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              // UPDATED
              border: Border.all(color: widget.primaryPurple.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology_alt, size: 20, color: widget.primaryPurple),
                    const SizedBox(width: 8),
                    Text(
                      "THE TOPIC",
                      style: TextStyle(
                        color: widget.primaryPurple,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  controller.currentQuestion!,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        const Text(
          "AI Analysis",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),

        if (controller.aiParsedFeedback != null &&
            controller.aiParsedFeedback!.isNotEmpty) ...[
          ...controller.buildParsedFeedbackWidgets(controller.aiParsedFeedback)
              .map((w) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: w,
                  )),
        ] else ...[
          Text(
            feedback,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 16,
              height: 1.6,
            ),
          ),
        ],
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildAnalyzingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.2),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // UPDATED
                    color: widget.primaryPurple.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome, 
                    size: 40, 
                    color: widget.primaryPurple
                  ),
                ),
              );
            },
            onEnd: () {}, 
          ),
          const SizedBox(height: 24),
          const Text(
            'Analyzing your speech...',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w600, 
              color: Colors.black87
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Generating personalized feedback',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
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
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}