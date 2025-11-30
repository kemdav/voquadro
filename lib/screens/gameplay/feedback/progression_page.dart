import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/src/helper-class/progression_conversion_helper.dart';

class ProgressionPage extends StatefulWidget {
  final bool isVisible;

  const ProgressionPage({super.key, this.isVisible = true});

  @override
  State<ProgressionPage> createState() => _ProgressionPageState();
}

class _ProgressionPageState extends State<ProgressionPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Key _progressAnimationKey = UniqueKey();

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
  void didUpdateWidget(covariant ProgressionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.reset();
      _controller.forward();

      setState(() {
        _progressAnimationKey = UniqueKey();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final publicSpeakingController = context.watch<PublicSpeakingController>();
    final sessionController = context.watch<AppFlowController>();

    final result = publicSpeakingController.sessionResult;
    final user = sessionController.currentUser;

    if (user == null || result == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // 1. Current Stats
    final publicLevelInfo = ProgressionConversionHelper.getLevelProgressInfo(
      user.publicSpeakingEXP,
    );
    final paceControlInfo = ProgressionConversionHelper.getLevelProgressInfo(
      user.paceControlEXP,
    );
    final fillerWordInfo = ProgressionConversionHelper.getLevelProgressInfo(
      user.fillerControlEXP,
    );

    // 2. Calculate Previous Stats
    final prevPublicExp = user.publicSpeakingEXP - result.modeEXP;
    final prevPaceExp = user.paceControlEXP - result.paceControlEXP;
    final prevFillerExp = user.fillerControlEXP - result.fillerControlEXP;

    final prevPublicLevel = ProgressionConversionHelper.getLevelProgressInfo(
      prevPublicExp.toInt(),
    ).level;
    final prevPaceLevel = ProgressionConversionHelper.getLevelProgressInfo(
      prevPaceExp.toInt(),
    ).level;
    final prevFillerLevel = ProgressionConversionHelper.getLevelProgressInfo(
      prevFillerExp.toInt(),
    ).level;

    // 3. Determine if Level Up happened
    final bool isPublicUp = publicLevelInfo.level > prevPublicLevel;
    final bool isPaceUp = paceControlInfo.level > prevPaceLevel;
    final bool isFillerUp = fillerWordInfo.level > prevFillerLevel;

    // --- Colors ---
    final Color primaryPurple = const Color(0xFF322082);
    final Color progressTeal = const Color(0xFF00A9A5);
    final Color pageBackground = const Color(0xFFF0E6F6);

    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        // LAYOUT FIX: Use LayoutBuilder + SingleChildScrollView + IntrinsicHeight.
        // This keeps spacers working but allows scrolling if the screen is physically too small.
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Only scrolls if content is bigger than screen
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 1. PAGE TITLE
                        FadeSlideTransition(
                          controller: _controller,
                          intervalStart: 0.0,
                          intervalEnd: 0.4,
                          child: Text(
                            "Level Mastery",
                            style: TextStyle(
                              color: primaryPurple,
                              // REDUCED SIZE: 32 -> 28 to save space
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),

                        const Spacer(flex: 1),

                        // 2. HERO RANK CIRCLE
                        FadeSlideTransition(
                          controller: _controller,
                          intervalStart: 0.1,
                          intervalEnd: 0.5,
                          child: _buildRankHero(
                            publicLevelInfo,
                            result.modeEXP.toInt(),
                            primaryPurple,
                            progressTeal,
                            isPublicUp,
                          ),
                        ),

                        // REDUCED SIZE: 30 -> 24. Prevents clipping but saves 6px.
                        const SizedBox(height: 24),
                        const Spacer(flex: 1),

                        // 3. PUBLIC SPEAKING MAIN BAR
                        FadeSlideTransition(
                          controller: _controller,
                          intervalStart: 0.3,
                          intervalEnd: 0.7,
                          child: AnimatedProgressBar(
                            key: _progressAnimationKey,
                            title: 'Public Speaking',
                            level: publicLevelInfo.level,
                            currentExp: publicLevelInfo.currentLevelExp,
                            maxExp: publicLevelInfo.cumulativeExpForNextLevel,
                            xpGain: result.modeEXP.toInt(),
                            progress: publicLevelInfo.progressPercentage,
                            progressColor: progressTeal,
                            textColor: primaryPurple,
                            isLarge: true,
                            isLevelUp: isPublicUp,
                          ),
                        ),

                        const Spacer(flex: 1),

                        // 4. SUB-SKILL BARS
                        IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: FadeSlideTransition(
                                  controller: _controller,
                                  intervalStart: 0.5,
                                  intervalEnd: 0.9,
                                  child: AnimatedProgressBar(
                                    key: _progressAnimationKey,
                                    title: 'Pace\nControl',
                                    level: paceControlInfo.level,
                                    currentExp: paceControlInfo.currentLevelExp,
                                    maxExp: paceControlInfo
                                        .cumulativeExpForNextLevel,
                                    xpGain: result.paceControlEXP.toInt(),
                                    progress:
                                        paceControlInfo.progressPercentage,
                                    progressColor: progressTeal,
                                    textColor: primaryPurple,
                                    compact: true,
                                    isLevelUp: isPaceUp,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: FadeSlideTransition(
                                  controller: _controller,
                                  intervalStart: 0.6,
                                  intervalEnd: 1.0,
                                  child: AnimatedProgressBar(
                                    key: _progressAnimationKey,
                                    title: 'Filler\nControl',
                                    level: fillerWordInfo.level,
                                    currentExp: fillerWordInfo.currentLevelExp,
                                    maxExp: fillerWordInfo
                                        .cumulativeExpForNextLevel,
                                    xpGain: result.fillerControlEXP.toInt(),
                                    progress: fillerWordInfo.progressPercentage,
                                    progressColor: progressTeal,
                                    textColor: primaryPurple,
                                    compact: true,
                                    isLevelUp: isFillerUp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRankHero(
    dynamic info,
    int xpGain,
    Color primaryColor,
    Color accentColor,
    bool isLevelUp,
  ) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Background Shadow
        Container(
          // REDUCED SIZE: 160 -> 140
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
        ),
        // Inner Circle
        Container(
          // REDUCED SIZE: 130 -> 110
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200, width: 2),
          ),
          child: Center(
            child: isLevelUp
                // Icons scaled down slightly
                ? Icon(
                    Icons.keyboard_double_arrow_up,
                    size: 50,
                    color: accentColor,
                  )
                : Icon(Icons.shield, size: 50, color: Colors.grey.shade400),
          ),
        ),
        // Ring
        SizedBox(
          // REDUCED SIZE: 160 -> 140
          width: 140,
          height: 140,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: info.progressPercentage),
            duration: const Duration(seconds: 2),
            curve: Curves.easeOutExpo,
            builder: (context, value, _) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 10, // Slightly thinner ring
                backgroundColor: Colors.grey.shade300,
                color: accentColor,
                strokeCap: StrokeCap.round,
              );
            },
          ),
        ),
        // XP Badge
        Positioned(
          top: -10,
          right: 0,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(scale: value, child: child);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '+$xpGain XP',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12, // Smaller font
                ),
              ),
            ),
          ),
        ),
        // Level Up Label
        if (isLevelUp)
          Positioned(
            bottom: -15,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                "LEVEL UP!",
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 10, // Smaller font
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class AnimatedProgressBar extends StatelessWidget {
  final String title;
  final int level;
  final int currentExp;
  final int maxExp;
  final int xpGain;
  final double progress;
  final Color progressColor;
  final Color textColor;
  final bool isLarge;
  final bool compact;
  final bool isLevelUp;

  const AnimatedProgressBar({
    super.key,
    required this.title,
    required this.level,
    required this.currentExp,
    required this.maxExp,
    required this.xpGain,
    required this.progress,
    required this.progressColor,
    required this.textColor,
    this.isLarge = false,
    this.compact = false,
    this.isLevelUp = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2, // Allow 2 lines for "Pace\nControl"
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor,
                        fontSize: isLarge ? 18 : 14,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Lvl $level",
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.6),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (isLevelUp) _buildLevelUpBadge(),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (compact)
                Padding(
                  padding: const EdgeInsets.only(left: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Lvl $level",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      // If isLevelUp, the badge adds height here, causing the unevenness.
                      // IntrinsicHeight in the parent fixes the card height,
                      // Spacer() below fixes the content alignment.
                      if (isLevelUp) _buildLevelUpBadge(),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // PROGRESS BAR
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: progress),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOutQuart,
            builder: (context, value, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: isLarge ? 16 : 10,
                  backgroundColor: Colors.grey.shade200,
                  color: isLevelUp ? const Color(0xFFFFD700) : progressColor,
                ),
              );
            },
          ),

          // FIX: Use Spacer instead of SizedBox(height: 10).
          // This pushes the footer to the bottom of the stretched card.
          if (compact) const Spacer() else const SizedBox(height: 10),

          // FOOTER ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: currentExp.toDouble()),
                    duration: const Duration(seconds: 2),
                    curve: Curves.easeOut,
                    builder: (context, value, _) {
                      return Text(
                        "${value.toInt()} / $maxExp XP",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "+$xpGain",
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelUpBadge() {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0, top: 2.0),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: 1.1),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFFFD700),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            "UP!",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
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
