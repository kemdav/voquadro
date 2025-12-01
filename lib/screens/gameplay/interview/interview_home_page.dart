import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/src/ai-integration/interview_mode_service.dart';
import 'interview_session_page.dart';

class InterviewHomePage extends StatelessWidget {
  const InterviewHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interview Mode'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.read<AppFlowController>().selectMode(
              AppMode.publicSpeaking,
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Choose a Scenario Deck',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDeckCard(
                    context,
                    'The Career Ladder',
                    'Job Interviews',
                    Icons.work,
                    Colors.blue,
                    InterviewCategory.careerLadder,
                  ),
                  _buildDeckCard(
                    context,
                    'The Traveler',
                    'Survival',
                    Icons.flight,
                    Colors.green,
                    InterviewCategory.traveler,
                  ),
                  _buildDeckCard(
                    context,
                    'The Socialite',
                    'Casual',
                    Icons.people,
                    Colors.orange,
                    InterviewCategory.socialite,
                  ),
                  _buildDeckCard(
                    context,
                    'The Debater',
                    'Logic',
                    Icons.gavel,
                    Colors.purple,
                    InterviewCategory.debater,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeckCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    InterviewCategory category,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          _startSession(context, category);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _startSession(
    BuildContext context,
    InterviewCategory category,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Initialize session
      await Provider.of<InterviewModeService>(
        context,
        listen: false,
      ).startSession(category);

      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const InterviewSessionPage()),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error starting session: $e')));
      }
    }
  }
}
