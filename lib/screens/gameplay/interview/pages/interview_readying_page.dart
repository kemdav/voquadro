import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/interview-controller/interview_controller.dart';
import 'package:voquadro/theme/voquadro_colors.dart';

class InterviewReadyingPage extends StatelessWidget {
  const InterviewReadyingPage({super.key});

  String _formatTime(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<InterviewController>(
        builder: (context, controller, child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Prepare for your Interview",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: VoquadroColors.primaryPurple,
                    ),
                  ),
                  const SizedBox(height: 30),
                  
                  // Role Card
                  _buildInfoCard(
                    title: "Your Role",
                    content: controller.role,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 16),
                  
                  // Scenario Card
                  _buildInfoCard(
                    title: "The Scenario",
                    content: controller.scenario,
                    icon: Icons.description_outlined,
                  ),
                  const SizedBox(height: 16),
                  
                  // Interviewer Card
                  _buildInfoCard(
                    title: "The Interviewer",
                    content: controller.interviewerName,
                    icon: Icons.record_voice_over_outlined,
                  ),
                  
                  const Spacer(),
                  
                  // Timer and Button
                  Center(
                    child: Column(
                      children: [
                        Text(
                          "Starting in:",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTime(controller.readyingTimeRemaining),
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: VoquadroColors.primaryPurple,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => controller.enterInterviewRoom(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: VoquadroColors.primaryPurple,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              "I'm Ready (Enter Room)",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: VoquadroColors.primaryPurple, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}