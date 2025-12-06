import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/src/helper-class/progression_conversion_helper.dart';

class InterviewProgressionPage extends StatefulWidget {
  final bool isVisible;
  final Color cardBackground;
  final Color primaryPurple;

  // Progression Data
  final int currentInterviewLevel;
  final int currentInterviewExp;
  final int gainedInterviewExp;

  final int currentPaceLevel;
  final int currentPaceExp;
  final int gainedPaceExp;

  final int currentFillerLevel;
  final int currentFillerExp;
  final int gainedFillerExp;

  const InterviewProgressionPage({
    super.key,
    this.isVisible = true,
    this.cardBackground = Colors.white,
    required this.primaryPurple,
    required this.currentInterviewLevel,
    required this.currentInterviewExp,
    required this.gainedInterviewExp,
    required this.currentPaceLevel,
    required this.currentPaceExp,
    required this.gainedPaceExp,
    required this.currentFillerLevel,
    required this.currentFillerExp,
    required this.gainedFillerExp,
  });

  @override
  State<InterviewProgressionPage> createState() => _InterviewProgressionPageState();
}

class _InterviewProgressionPageState extends State<InterviewProgressionPage>
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
  void didUpdateWidget(covariant InterviewProgressionPage oldWidget) {
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
    // Calculate Totals
    final int totalInterviewExp = widget.currentInterviewExp + widget.gainedInterviewExp;
    final int totalPaceExp = widget.currentPaceExp + widget.gainedPaceExp;
    final int totalFillerExp = widget.currentFillerExp + widget.gainedFillerExp;

    // Calculate Levels (Post-Session)
    final interviewLevelInfo = ProgressionConversionHelper.getLevelProgressInfo(totalInterviewExp);
    final paceLevelInfo = ProgressionConversionHelper.getLevelProgressInfo(totalPaceExp);
    final fillerLevelInfo = ProgressionConversionHelper.getLevelProgressInfo(totalFillerExp);

    // Previous Levels (Pre-Session)
    final prevInterviewLevel = ProgressionConversionHelper.getLevelProgressInfo(widget.currentInterviewExp).level;
    final prevPaceLevel = ProgressionConversionHelper.getLevelProgressInfo(widget.currentPaceExp).level;
    final prevFillerLevel = ProgressionConversionHelper.getLevelProgressInfo(widget.currentFillerExp).level;

    final bool isInterviewUp = interviewLevelInfo.level > prevInterviewLevel;
    final bool isPaceUp = paceLevelInfo.level > prevPaceLevel;
    final bool isFillerUp = fillerLevelInfo.level > prevFillerLevel;

    return Column(
      children: [
        const SizedBox(height: 20),

        // TITLE
        FadeSlideTransition(
          controller: _controller,
          intervalStart: 0.0,
          intervalEnd: 0.3,
          child: Text(
            "Progression",
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Main Level (Interview Level)
                    _buildLevelSection(
                      title: "Interview Level",
                      level: interviewLevelInfo.level,
                      currentExp: interviewLevelInfo.currentLevelExp,
                      requiredExp: interviewLevelInfo.expToNextLevel + interviewLevelInfo.currentLevelExp,
                      progress: interviewLevelInfo.progressPercentage,
                      isLevelUp: isInterviewUp,
                      gainedExp: widget.gainedInterviewExp,
                      color: widget.primaryPurple,
                      icon: Icons.mic_external_on,
                    ),

                    const SizedBox(height: 32),
                    const Divider(),
                    const SizedBox(height: 32),

                    // 2. Sub Levels
                    Text(
                      "Skill Breakdown",
                      style: TextStyle(
                        color: widget.primaryPurple.withValues(alpha: 0.8),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _buildLevelSection(
                      title: "Pace Control",
                      level: paceLevelInfo.level,
                      currentExp: paceLevelInfo.currentLevelExp,
                      requiredExp: paceLevelInfo.expToNextLevel + paceLevelInfo.currentLevelExp,
                      progress: paceLevelInfo.progressPercentage,
                      isLevelUp: isPaceUp,
                      gainedExp: widget.gainedPaceExp,
                      color: Colors.teal,
                      icon: Icons.speed,
                      isSmall: true,
                    ),

                    const SizedBox(height: 20),

                    _buildLevelSection(
                      title: "Filler Word Control",
                      level: fillerLevelInfo.level,
                      currentExp: fillerLevelInfo.currentLevelExp,
                      requiredExp: fillerLevelInfo.expToNextLevel + fillerLevelInfo.currentLevelExp,
                      progress: fillerLevelInfo.progressPercentage,
                      isLevelUp: isFillerUp,
                      gainedExp: widget.gainedFillerExp,
                      color: Colors.orange,
                      icon: Icons.graphic_eq,
                      isSmall: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLevelSection({
    required String title,
    required int level,
    required int currentExp,
    required int requiredExp,
    required double progress,
    required bool isLevelUp,
    required int gainedExp,
    required Color color,
    required IconData icon,
    bool isSmall = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(isSmall ? 8 : 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isSmall ? 20 : 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: isSmall ? 16 : 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isLevelUp)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "LEVEL UP!",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Lvl $level",
                        style: TextStyle(
                          color: color,
                          fontSize: isSmall ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "+$gainedExp XP",
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: isSmall ? 12 : 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade200,
            color: color,
            minHeight: isSmall ? 8 : 12,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "$currentExp / $requiredExp XP",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
      ],
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
