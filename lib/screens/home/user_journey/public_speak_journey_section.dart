import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/screens/home/user_journey/user_journey_data.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/src/models/session_model.dart';
import 'package:voquadro/widgets/AppBar/general_app_bar.dart';
import 'package:voquadro/widgets/AppBar/default_actions.dart';
import 'package:voquadro/widgets/BottomBar/general_navigation_bar.dart';
import 'package:voquadro/widgets/BottomBar/empty_actions.dart';
import 'package:voquadro/widgets/Modals/pb_speaking_session.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/services/user_service.dart';

class PublicSpeakJourneySection extends StatefulWidget {
  final String username;
  final int currentXP;
  final int maxXP;
  final String currentLevel;
  final int averageWPM;
  final int averageFillers;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSettingsPressed;

  const PublicSpeakJourneySection({
    super.key,
    required this.username,
    required this.currentXP,
    required this.maxXP,
    required this.currentLevel,
    required this.averageWPM,
    required this.averageFillers,
    this.onBackPressed,
    this.onProfilePressed,
    this.onSettingsPressed,
  });

  @override
  State<PublicSpeakJourneySection> createState() =>
      _PublicSpeakJourneySectionState();
}

class _PublicSpeakJourneySectionState extends State<PublicSpeakJourneySection> {
  final ScrollController _feedbackScrollController = ScrollController();
  late Future<List<Session>> _sessionHistoryFuture;

  @override
  void initState() {
    super.initState();
    _sessionHistoryFuture = _fetchSessionHistory();
  }

  Future<List<Session>> _fetchSessionHistory() {
    final user = context.read<AppFlowController>().currentUser;
    if (user == null) {
      return Future.error('User not found. Cannot fetch session history.');
    }
    return UserService.getSessionsForUser(user.id);
  }

  @override
  void dispose() {
    _feedbackScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color purpleDark = '49416D'.toColor();
    const Color cardBg = Color(0xFFF0E6F6);
    const Color pageBg = Color(0xFFF7F3FB);

    return Scaffold(
      backgroundColor: pageBg,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                bottom: 55,
              ), // Change from 80 to match navBarVisualHeight
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBarGeneral(
                      actionButtons: DefaultActions(
                        onBackPressed: widget.onBackPressed,
                        onProfilePressed: widget.onProfilePressed,
                        onSettingsPressed: widget.onSettingsPressed,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
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
                            ),
                          ),
                          const SizedBox(height: 24),
                          progressCard(purpleDark, cardBg),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom navigation bar
          Align(
            alignment: Alignment.bottomCenter,
            child: GeneralNavigationBar(
              actions:
                  null, // Don't pass EmptyNavigationActions, just pass null
              navBarVisualHeight: 80,
              totalHitTestHeight: 80,
            ),
          ),
        ],
      ),
    );
  }

  // ... rest of your existing methods remain the same ...

  Widget progressCard(Color titleColor, Color cardBg) {
    return Container(
      decoration: _buildCardDecoration(cardBg),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressSection(titleColor),
          const SizedBox(height: 32),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 32),
          _buildStatsSection(titleColor),
          const SizedBox(height: 32),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 32),
          _buildFeedbackSection(titleColor),
        ],
      ),
    );
  }

  Widget _buildProgressSection(Color titleColor) {
    final progress = widget.currentXP / widget.maxXP;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFE53935),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'Rank\nEmblem',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.username,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${widget.currentXP}/${widget.maxXP}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 16,
                      decoration: const BoxDecoration(color: Colors.white),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C8C8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 16, color: titleColor),
                      children: [
                        const TextSpan(
                          text: 'Current Level: ',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        TextSpan(
                          text: widget.currentLevel.toUpperCase(),
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

  Widget _buildStatsSection(Color titleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average pacing and filler usage',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _buildStatTile(
                label: 'WPM',
                value: widget.averageWPM.toString(),
                sublabel: 'Pace Control',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatTile(
                label: 'Avg. Fillers',
                value: widget.averageFillers.toString(),
                sublabel: 'Filler Word Control',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeedbackSection(Color titleColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Session Feedbacks',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: FutureBuilder<List<Session>>(
            future: _sessionHistoryFuture,
            builder: (context, snapshot) {
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

                return _buildTimelineList(sessionHistory, titleColor);
              }

              return const Center(child: Text('No sessions found.'));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineList(List<Session> sessionHistory, Color titleColor) {
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
            Expanded(child: _buildEnhancedFeedbackList(sessionHistory)),
            Container(
              width: 8,
              margin: const EdgeInsets.only(left: 12),
              decoration: BoxDecoration(
                color: titleColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Scrollbar(
                controller: _feedbackScrollController,
                thumbVisibility: true,
                radius: const Radius.circular(4),
                thickness: 8,
                child: Container(),
              ),
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
              color: Color(0xFFE53935),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    String? sublabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 230),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
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
          Text(
            value,
            style: TextStyle(
              color: '6C53A1'.toColor(),
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (sublabel != null) ...{
            const SizedBox(height: 4),
            Text(
              sublabel,
              style: TextStyle(
                color: '6C53A1'.toColor().withValues(alpha: 179),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          },
        ],
      ),
    );
  }

  Widget _buildEnhancedFeedbackList(List<Session> sessionHistory) {
    return ListView.separated(
      controller: _feedbackScrollController,
      itemCount: sessionHistory.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = sessionHistory[index];
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => PublicSpeakingFeedbackModal(
                sessionDate: DateFormat('MMMM d, y').format(session.timestamp),
                paceWPM: session.wordsPerMinute.toInt(),
                fillerCount: session.fillerControl.toInt(),
                qualitativeFeedback: session.feedback,
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 230),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Session on ${session.topic}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: '49416D'.toColor(),
                      ),
                    ),
                    Text(
                      DateFormat('MMMM d, y').format(session.timestamp),
                      style: TextStyle(
                        fontSize: 14,
                        color: '49416D'.toColor().withValues(alpha: 204),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to view detailed feedback',
                  style: TextStyle(
                    fontSize: 14,
                    color: '49416D'.toColor().withValues(alpha: 179),
                  ),
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
