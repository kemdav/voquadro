import 'package:flutter/material.dart';
import 'package:voquadro/theme/voquadro_colors.dart';

class InterviewAiFeedbackPage extends StatefulWidget {
  final String feedbackText;
  final Color cardBackground;
  final Color primaryPurple;
  final bool isVisible;

  const InterviewAiFeedbackPage({
    super.key,
    required this.feedbackText,
    this.cardBackground = Colors.white,
    required this.primaryPurple,
    this.isVisible = true,
  });

  @override
  State<InterviewAiFeedbackPage> createState() => _InterviewAiFeedbackPageState();
}

class _InterviewAiFeedbackPageState extends State<InterviewAiFeedbackPage>
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
  void didUpdateWidget(covariant InterviewAiFeedbackPage oldWidget) {
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
    return Column(
      children: [
        const SizedBox(height: 20),

        // TITLE
        FadeSlideTransition(
            controller: _controller,
            intervalStart: 0.0,
            intervalEnd: 0.3,
            child: Text(
              "Coach's Feedback",
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
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: widget.primaryPurple,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "AI Analysis",
                              style: TextStyle(
                                color: widget.primaryPurple,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.feedbackText.isEmpty 
                              ? "No feedback generated yet." 
                              : widget.feedbackText,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ),
        ),
      ],
    );
  }
}class FadeSlideTransition extends StatelessWidget {
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
