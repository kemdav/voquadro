import 'package:flutter/material.dart';

class PublicSpeakJourneySection extends StatefulWidget {
  final String username;
  final int currentXP;
  final int maxXP;
  final String currentLevel;
  final int averageWPM;
  final int averageFillers;
  final List<SessionFeedback> sessionFeedbacks;
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
    required this.sessionFeedbacks,
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

  @override
  void dispose() {
    _feedbackScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F0FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildTitle(),
              const SizedBox(height: 20),
              _buildUserProfileCard(),
              const SizedBox(height: 20),
              _buildAverageStatsCard(),
              const SizedBox(height: 20),
              _buildSessionFeedbacksCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 60,
      decoration: const BoxDecoration(color: Color(0xFF5C3E7E)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildHeaderButton(
            icon: Icons.arrow_back_ios,
            onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
          ),
          Row(
            children: [
              _buildHeaderButton(
                icon: Icons.person,
                onPressed: widget.onProfilePressed ?? () {},
              ),
              const SizedBox(width: 10),
              _buildHeaderButton(
                icon: Icons.settings,
                onPressed: widget.onSettingsPressed ?? () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: const Color(0xFF5C3E7E), size: 20),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          const Text(
            'Your Journey',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C1E40),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD700),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6F6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // FIXED: Replaced withOpacity with withAlpha
            color: Colors.black.withAlpha(26), // 0.1 opacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildRankEmblem(),
          const SizedBox(width: 20),
          Expanded(child: _buildUserInfo()),
        ],
      ),
    );
  }

  Widget _buildRankEmblem() {
    return Container(
      width: 80,
      height: 80,
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
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo() {
    final progress = widget.currentXP / widget.maxXP;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.username,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C1E40),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(),
            Text(
              '${widget.currentXP}/${widget.maxXP}',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2C1E40),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00C8C8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
        RichText(
          text: TextSpan(
            children: [
              const TextSpan(
                text: 'Current Level: ',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C1E40),
                  fontWeight: FontWeight.normal,
                ),
              ),
              TextSpan(
                text: widget.currentLevel,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2C1E40),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAverageStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE6D9EE),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // FIXED: Replaced withOpacity with withAlpha
            color: Colors.black.withAlpha(26), // 0.1 opacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Average pacing and filler usage',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C1E40),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatBox(
                  value: widget.averageWPM.toString(),
                  label: 'WPM / Session',
                  subLabel: 'Pace Control',
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatBox(
                  value: widget.averageFillers.toString(),
                  label: 'Avg. Fillers / Session',
                  subLabel: 'Filler Word Control',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required String value,
    required String label,
    required String subLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // FIXED: Replaced withOpacity with withAlpha
            color: Colors.black.withAlpha(13), // 0.05 opacity
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C1E40),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF2C1E40),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subLabel,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF2C1E40),
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSessionFeedbacksCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0E6F6),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            // FIXED: Replaced withOpacity with withAlpha
            color: Colors.black.withAlpha(26), // 0.1 opacity
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Session Feedbacks',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C1E40),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(height: 300, child: _buildFeedbackList()),
        ],
      ),
    );
  }

  Widget _buildFeedbackList() {
    return Stack(
      children: [
        Row(
          children: [
            // Timeline decoration
            Container(width: 2, height: 300, color: const Color(0xFF2C1E40)),
            const SizedBox(width: 15),
            // Feedback list
            Expanded(
              child: ListView.builder(
                controller: _feedbackScrollController,
                itemCount: widget.sessionFeedbacks.length,
                itemBuilder: (context, index) {
                  final feedback = widget.sessionFeedbacks[index];
                  return _buildFeedbackItem(feedback, index);
                },
              ),
            ),
            const SizedBox(width: 10),
            // Custom scrollbar
            _buildCustomScrollbar(),
          ],
        ),
        // Red circle for first item
        if (widget.sessionFeedbacks.isNotEmpty)
          Positioned(
            left: -4,
            top: 20,
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

  Widget _buildFeedbackItem(SessionFeedback feedback, int index) {
    return GestureDetector(
      onTap: () {
        // FIXED: Removed print statement.
        // TODO: Implement navigation to feedback details screen.
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              // FIXED: Replaced withOpacity with withAlpha
              color: Colors.black.withAlpha(13), // 0.05 opacity
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              feedback.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C1E40),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              feedback.date,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2C1E40),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomScrollbar() {
    return Container(
      width: 8,
      height: 300,
      decoration: BoxDecoration(
        // FIXED: Replaced withOpacity with withAlpha
        color: const Color(0xFF5C3E7E).withAlpha(77), // 0.3 opacity
        borderRadius: BorderRadius.circular(4),
      ),
      child: Scrollbar(
        controller: _feedbackScrollController,
        thumbVisibility: true,
        trackVisibility: false,
        thickness: 8,
        radius: const Radius.circular(4),
        child: Container(),
      ),
    );
  }
}

// Data model for session feedback
class SessionFeedback {
  final String title;
  final String date;

  SessionFeedback({required this.title, required this.date});
}

// Example usage with placeholder data
class PublicSpeakJourneySectionExample extends StatelessWidget {
  const PublicSpeakJourneySectionExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Example data - replace with real data from your app
    final List<SessionFeedback> exampleFeedbacks = [
      SessionFeedback(
        title: "Lorem ipsum dolor sit amet, consectetur adipiscing elit",
        date: "Oct 16, 2025",
      ),
      SessionFeedback(
        title: "Sed do eiusmod tempor incididunt ut labore",
        date: "Oct 15, 2025",
      ),
      SessionFeedback(
        title: "Ut enim ad minim veniam, quis nostrud exercitation",
        date: "Oct 14, 2025",
      ),
      SessionFeedback(
        title: "Duis aute irure dolor in reprehenderit in voluptate",
        date: "Oct 13, 2025",
      ),
      SessionFeedback(
        title: "Excepteur sint occaecat cupidatat non proident",
        date: "Oct 12, 2025",
      ),
    ];

    return PublicSpeakJourneySection(
      username: "Adolp",
      currentXP: 69,
      maxXP: 200,
      currentLevel: "APPRENTICE",
      averageWPM: 120,
      averageFillers: 21,
      sessionFeedbacks: exampleFeedbacks,
      onBackPressed: () => Navigator.pop(context),
      onProfilePressed: () {
        // FIXED: Removed print statement.
        // TODO: Handle profile button tap.
      },
      onSettingsPressed: () {
        // FIXED: Removed print statement.
        // TODO: Handle settings button tap.
      },
    );
  }
}
