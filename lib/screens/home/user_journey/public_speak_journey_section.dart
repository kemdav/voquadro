import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/src/models/session_model.dart';
import 'package:voquadro/widgets/Modals/pb_speaking_session.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/services/user_service.dart';
import 'package:voquadro/src/helper-class/progression_conversion_helper.dart';

class PublicSpeakJourneySection extends StatefulWidget {
  final bool isVisible;
  const PublicSpeakJourneySection({super.key, this.isVisible = false});

  @override
  State<PublicSpeakJourneySection> createState() =>
      _PublicSpeakJourneySectionState();
}

class _PublicSpeakJourneySectionState extends State<PublicSpeakJourneySection>
    with SingleTickerProviderStateMixin {
  late Future<List<Session>> _sessionHistoryFuture;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _animationTriggerCount = 0;

  @override
  void initState() {
    super.initState();
    _sessionHistoryFuture = _fetchSessionHistory();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    if (widget.isVisible) {
      _animationController.forward();
      _animationTriggerCount++;
    }
  }

  @override
  void didUpdateWidget(PublicSpeakJourneySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _animationController.reset();
      _animationController.forward();
      setState(() {
        _animationTriggerCount++;
        _sessionHistoryFuture = _fetchSessionHistory();
      });
    }
  }

  Future<List<Session>> _fetchSessionHistory() {
    final user = context.read<AppFlowController>().currentUser;
    if (user == null) {
      return Future.error('User not found.');
    }
    return UserService.getSessionsForUser(user.id);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appFlow = context.watch<AppFlowController>();
    final user = appFlow.currentUser;

    if (user == null) return const Center(child: Text("User not loaded"));

    final username = user.username;
    final currentXP = user.publicSpeakingEXP;

    // Use helper to get level info
    final levelInfo = ProgressionConversionHelper.getLevelProgressInfo(currentXP);
    final currentLevel = levelInfo.level;
    final currentRank = levelInfo.rank;
    final currentLevelExp = levelInfo.currentLevelExp;
    final expToNextLevel = levelInfo.expToNextLevel;

    final Color purpleDark = '49416D'.toColor();
    const Color cardBg = Color(0xFFF0E6F6);
    const Color pageBg = Color(0xFFF7F3FB);

    return Container(
      color: pageBg,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(
            bottom: 100,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Journey',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      color: purpleDark,
                      height: 1.1,
                      letterSpacing: -1.0,
                    ),
                  ),
                  Text(
                    'Track your progress and growth',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: purpleDark.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FutureBuilder<List<Session>>(
                    future: _sessionHistoryFuture,
                    builder: (context, snapshot) {
                      int averageWPM = 0;
                      int averageFillers = 0;

                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final sessions = snapshot.data!;
                        final totalWPM = sessions.fold(
                          0.0,
                          (sum, session) => sum + session.wordsPerMinute,
                        );
                        final totalFillers = sessions.fold(
                          0.0,
                          (sum, session) => sum + session.fillerControl,
                        );
                        averageWPM = (totalWPM / sessions.length).round();
                        averageFillers =
                            (totalFillers / sessions.length).round();
                      }

                      return progressCard(
                        purpleDark,
                        cardBg,
                        username,
                        currentLevelExp,
                        expToNextLevel,
                        currentRank,
                        currentLevel,
                        averageWPM,
                        averageFillers,
                        snapshot,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget progressCard(
    Color titleColor,
    Color cardBg,
    String username,
    int currentLevelExp,
    int expToNextLevel,
    String currentRank,
    int currentLevel,
    int averageWPM,
    int averageFillers,
    AsyncSnapshot<List<Session>> snapshot,
  ) {
    return Container(
      decoration: _buildCardDecoration(cardBg),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressSection(
            titleColor,
            username,
            currentLevelExp,
            expToNextLevel,
            currentRank,
            currentLevel,
          ),
          const SizedBox(height: 32),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 32),
          _buildStatsSection(titleColor, averageWPM, averageFillers),
          const SizedBox(height: 32),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 32),
          _buildFeedbackSection(titleColor, snapshot),
        ],
      ),
    );
  }

  Widget _buildProgressSection(
    Color titleColor,
    String username,
    int currentLevelExp,
    int expToNextLevel,
    String currentRank,
    int currentLevel,
  ) {
    final progress =
        (expToNextLevel > 0) ? currentLevelExp / expToNextLevel : 1.0;

    // Determine emblem asset based on rank
    String emblemAsset = 'assets/rank_emblem_assets/novice.png';
    switch (currentRank.toLowerCase()) {
      case 'novice':
        emblemAsset = 'assets/rank_emblem_assets/novice.png';
        break;
      case 'communicator':
        emblemAsset = 'assets/rank_emblem_assets/communicator.png';
        break;
      case 'adept':
        emblemAsset = 'assets/rank_emblem_assets/adept.png';
        break;
      case 'orator':
        emblemAsset = 'assets/rank_emblem_assets/orator.png';
        break;
      case 'virtuoso':
        emblemAsset = 'assets/rank_emblem_assets/virtuoso.png';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Transform.scale(
              scale: 1.45,
              child: Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    emblemAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.emoji_events,
                        size: 50,
                        color: Colors.amber,
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Level $currentLevel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      TweenAnimationBuilder<int>(
                        key: ValueKey('xp_text_$_animationTriggerCount'),
                        tween: IntTween(begin: 0, end: currentLevelExp),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return Text(
                            '$value/$expToNextLevel XP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 16,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey('xp_bar_$_animationTriggerCount'),
                        tween: Tween<double>(
                            begin: 0, end: progress.clamp(0.0, 1.0)),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOutCubic,
                        builder: (context, value, child) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF00C8C8),
                                    Color(0xFF00E5FF)
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF00C8C8)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: titleColor),
                      children: [
                        const TextSpan(
                          text: 'Current Rank: ',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: currentRank,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsSection(
    Color titleColor,
    int averageWPM,
    int averageFillers,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Performance Stats',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatTile(
                label: 'Pace (WPM)',
                value: averageWPM,
                sublabel: 'Target: 130-150',
                icon: Icons.speed_rounded,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatTile(
                label: 'Filler Words',
                value: averageFillers,
                sublabel: 'Lower is better',
                icon: Icons.graphic_eq_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(
    Color titleColor,
    AsyncSnapshot<List<Session>> snapshot,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Sessions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: titleColor,
              ),
            ),
            if (snapshot.hasData && snapshot.data!.length > 3)
              TextButton(
                onPressed: () {
                  _showAllSessionsModal(context, snapshot.data!, titleColor);
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 20),
        Builder(
          builder: (context) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.hasData) {
              final sessionHistory = snapshot.data!;

              if (sessionHistory.isEmpty) {
                return const Center(
                  child: Text(
                    'No practice sessions recorded yet.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                );
              }

              // Show only top 3
              final recentSessions = sessionHistory.take(3).toList();
              return _buildTimelineList(recentSessions, titleColor,
                  isScrollable: false);
            }

            return const Center(child: Text('No sessions found.'));
          },
        ),
      ],
    );
  }

  void _showAllSessionsModal(
      BuildContext context, List<Session> sessions, Color titleColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F3FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Sessions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: _buildTimelineList(sessions, titleColor, isScrollable: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineList(
    List<Session> sessionHistory,
    Color titleColor, {
    bool isScrollable = true,
  }) {
    return Stack(
      children: [
        Positioned(
          left: 4,
          top: 0,
          bottom: 0,
          child: Container(width: 2, color: titleColor),
        ),
        Row(
          children: [
            const SizedBox(width: 24),
            Expanded(
              child: _buildEnhancedFeedbackList(sessionHistory, isScrollable),
            ),
          ],
        ),
        Positioned(
          left: 0,
          top: 24,
          child: Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF00C8C8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0x6600C8C8),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String label,
    required int value,
    String? sublabel,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF49416D).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Color(0xFFF0E6F6),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF49416D), size: 24),
            ),
            const SizedBox(height: 12),
          ],
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: '6C53A1'.toColor(),
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          TweenAnimationBuilder<int>(
            key: ValueKey('stat_tile_${label}_$_animationTriggerCount'),
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, animatedValue, child) {
              return Text(
                animatedValue.toString(),
                style: TextStyle(
                  color: '6C53A1'.toColor(),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              );
            },
          ),
          if (sublabel != null) ...{
            const SizedBox(height: 4),
            Text(
              sublabel,
              style: TextStyle(
                color: '6C53A1'.toColor().withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          },
        ],
      ),
    );
  }

  Widget _buildEnhancedFeedbackList(
    List<Session> sessionHistory,
    bool isScrollable,
  ) {
    return ListView.separated(
      shrinkWrap: !isScrollable,
      physics: isScrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      itemCount: sessionHistory.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = sessionHistory[index];
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => PublicSpeakingFeedbackModal(
                session: session,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: '49416D'.toColor().withValues(alpha: 0.1), // ~10% opacity
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mic,
                    color: '49416D'.toColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.topic,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: '49416D'.toColor(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, y • h:mm a')
                            .format(session.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: '49416D'.toColor().withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: '49416D'.toColor().withValues(alpha: 0.4),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  BoxDecoration _buildCardDecoration(Color cardBg) {
    return BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 10),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
