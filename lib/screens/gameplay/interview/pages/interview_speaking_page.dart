import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/interview-controller/interview_controller.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/theme/voquadro_colors.dart';

class InterviewSpeakingPage extends StatelessWidget {
  const InterviewSpeakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AppFlowController>().currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark background for meeting feel
      body: Consumer<InterviewController>(
        builder: (context, controller, child) {
          return Stack(
            children: [
              // 1. Main Interviewer View (Center)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Avatar / Video Placeholder
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey.shade800,
                        border: Border.all(
                          color: VoquadroColors.primaryPurple.withOpacity(0.5),
                          width: 4,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 100,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Interviewer Name
                    Text(
                      controller.interviewerName.isNotEmpty
                          ? controller.interviewerName
                          : "Interviewer",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.mic, color: Colors.white70, size: 16),
                          SizedBox(width: 8),
                          Text(
                            "Speaking...",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Self View (Top Right)
              Positioned(
                top: 40,
                right: 20,
                child: Container(
                  width: 120,
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      children: [
                        // Background Image
                        Positioned.fill(
                          child: user?.profileAvatarUrl != null
                              ? Image.network(
                                  user!.profileAvatarUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.grey.shade900,
                                    child: const Icon(Icons.person,
                                        color: Colors.white54, size: 40),
                                  ),
                                )
                              : Container(
                                  color: Colors.grey.shade900,
                                  child: const Icon(Icons.person,
                                      color: Colors.white54, size: 40),
                                ),
                        ),

                        // Gradient Overlay for Text Readability
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Name Label
                        const Positioned(
                          bottom: 12,
                          left: 12,
                          child: Text(
                            "You",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),

                        // Mute Indicator
                        if (controller.isMicMuted)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.mic_off,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
