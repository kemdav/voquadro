import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/screens/home/user_journey/user_journey_data.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/src/models/session_model.dart';
import 'package:voquadro/widgets/AppBar/general_app_bar.dart';
import 'package:voquadro/widgets/AppBar/default_actions.dart';
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
  //final List<SessionFeedback> sessionFeedbacks;
  final VoidCallback? onBackPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSettingsPressed;

  const PublicSpeakJourneySection({
    //change when needed this is only for the ui
    super.key,
    required this.username,
    required this.currentXP,
    required this.maxXP,
    required this.currentLevel,
    required this.averageWPM,
    required this.averageFillers,
    //required this.sessionFeedbacks,
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
      // Return a future that completes with an error if the user is not logged in
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
      body: SafeArea(
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
    );
  }

  Widget progressCard(Color titleColor, Color cardBg) {
    return Container(
      decoration: _buildCardDecoration(cardBg),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Section
          _buildProgressSection(titleColor),
          const SizedBox(height: 32),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 32),
          // Stats Section
          _buildStatsSection(titleColor),
          const SizedBox(height: 32),
          const Divider(height: 1, thickness: 1),
          const SizedBox(height: 32),
          // Feedback Section
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
            // Rank Emblem
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
            // User Info
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
            future: _sessionHistoryFuture, // Use the future from our state
            builder: (context, snapshot) {
              // Case 1: Still loading data from the database
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Case 2: An error occurred during the fetch
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              // Case 3: Data has arrived successfully
              if (snapshot.hasData) {
                final sessionHistory = snapshot.data!;

                // Case 3a: The data is an empty list
                if (sessionHistory.isEmpty) {
                  return const Center(
                    child: Text(
                      'No practice sessions recorded yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                // Case 3b: We have data, so build the list
                return _buildTimelineList(sessionHistory, titleColor);
              }

              // Fallback case
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
        // Timeline line
        Positioned(
          left: 4,
          top: 0,
          bottom: 0,
          child: Container(width: 2, color: titleColor),
        ),
        // Feedback list with custom scrollbar
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
        // Timeline dot for first item
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
                color: '6C53A1'.toColor().withValues(
                  alpha: 179,
                ), // Changed from withOpacity(0.7)
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
    // For exceljos: Replace this with the servie that returns List<Session> for a specific mode
    // Examole: publicMode would query for the session history that belongs to public speaking mode
    // to differentiate, make the id for the sessions begin with like pubmode_[id_number] or interviewmode_[id_number]
    //List<Session> sessionHistory = getModeSessionHistory(mode);

    return ListView.separated(
      controller: _feedbackScrollController,
      itemCount: sessionHistory.length, // Use widget's list directly
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final session = sessionHistory[index]; // Use widget's list directly
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

// Data model for session feedback
class SessionFeedback {
  final String date;

  SessionFeedback({required this.date});
}
