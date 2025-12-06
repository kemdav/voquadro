import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/interview-controller/interview_controller.dart';
import 'package:voquadro/theme/voquadro_colors.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voquadro/data/models/interview_response_model.dart';
import 'package:voquadro/screens/gameplay/interview/pages/feedback/interview_stats_page.dart';
import 'package:voquadro/screens/gameplay/interview/pages/feedback/interview_ai_feedback_page.dart';
import 'package:voquadro/screens/gameplay/interview/pages/feedback/interview_audio_player.dart';
import 'package:voquadro/screens/gameplay/interview/pages/feedback/interview_progression_page.dart';
import 'dart:io';

class InterviewFeedbackPage extends StatefulWidget {
  final String? mergedAudioPath;
  final List<String> sessionAudioPaths;
  final List<InterviewResponseModel> sessionResponses;

  const InterviewFeedbackPage({
    super.key,
    this.mergedAudioPath,
    this.sessionAudioPaths = const [],
    this.sessionResponses = const [],
  });

  @override
  State<InterviewFeedbackPage> createState() => _InterviewFeedbackPageState();
}

class _InterviewFeedbackPageState extends State<InterviewFeedbackPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.read<InterviewController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => controller.showHome(),
        ),
        title: const Text(
          "Interview Feedback",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: [
                _buildAudioReviewPage(),
                InterviewStatsPage(
                  sessionResponses: widget.sessionResponses,
                  cardBackground: Colors.grey.shade900,
                  primaryPurple: VoquadroColors.primaryPurple,
                  isVisible: _currentPage == 1,
                ),
                InterviewAiFeedbackPage(
                  feedbackText: controller.aiFeedback,
                  cardBackground: Colors.grey.shade900,
                  primaryPurple: VoquadroColors.primaryPurple,
                  isVisible: _currentPage == 2,
                ),
                InterviewProgressionPage(
                  cardBackground: Colors.grey.shade900,
                  primaryPurple: VoquadroColors.primaryPurple,
                  isVisible: _currentPage == 3,
                  currentInterviewLevel: controller.userInterviewLevel,
                  currentInterviewExp: controller.userInterviewExp,
                  gainedInterviewExp: controller.gainedInterviewExp,
                  currentPaceLevel: controller.userPaceLevel,
                  currentPaceExp: controller.userPaceExp,
                  gainedPaceExp: controller.gainedPaceExp,
                  currentFillerLevel: controller.userFillerLevel,
                  currentFillerExp: controller.userFillerExp,
                  gainedFillerExp: controller.gainedFillerExp,
                ),
              ],
            ),
          ),
          
          // Page Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(4, (index) => _buildDot(index)),
          ),
          
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => controller.exitGameplay(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: VoquadroColors.primaryPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Back to Home",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? VoquadroColors.primaryPurple 
            : Colors.grey.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildAudioReviewPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Session Recording",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Audio Player Card
          InterviewAudioPlayer(
            mergedAudioPath: widget.mergedAudioPath,
            sessionAudioPaths: widget.sessionAudioPaths,
          ),

          const SizedBox(height: 24),
          
          // Debug Info Section
          const Text(
            "Debug: Response Data",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: widget.sessionResponses.length,
              itemBuilder: (context, index) {
                final response = widget.sessionResponses[index];
                return Card(
                  color: Colors.grey.shade900,
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Response #${index + 1}",
                          style: TextStyle(
                            color: VoquadroColors.primaryPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Duration: ${response.duration.inSeconds}.${response.duration.inMilliseconds.remainder(1000)}s",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "Latency: ${response.responseTime.inMilliseconds}ms",
                          style: const TextStyle(color: Colors.white70),
                        ),
                        Text(
                          "Path: ...${response.audioPath.split('/').last}",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
