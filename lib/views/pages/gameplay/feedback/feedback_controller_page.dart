import 'package:flutter/material.dart';
import 'package:voquadro/data/voquadro_controller.dart';
import 'package:voquadro/views/pages/gameplay/feedback/next_rank_page.dart';
import 'package:voquadro/views/pages/gameplay/feedback/progression_page.dart';
import 'package:voquadro/views/pages/gameplay/feedback/speak_feedback_page.dart';
import 'package:voquadro/views/pages/gameplay/feedback/stat_feedback_page.dart';
import 'package:voquadro/views/pages/gameplay/feedback/transcript_page.dart';
import 'package:voquadro/src/ai-integration/ollama_service.dart';

class FeedbackControllerPage extends StatefulWidget {
  const FeedbackControllerPage({
    super.key,
    required this.cardBackground,
    required this.primaryPurple,
    this.topic = 'About life and current social issues',
    this.transcript = '''
    Good morning. Look at the person to your left. Now, look to your right. Each of you, and every person in this room, carries with you an invisible birthright. 
    It's not a passport, it's not a bank account—it's something more fundamental. It's a set of inherent rights, simply because you are a human being.
    This idea—that we all possess basic, inalienable rights—is one of the most powerful and revolutionary concepts in human history. But what are these 'human rights'? 
    They aren't physical objects; they are a framework, a promise. A promise of dignity, of fairness, of a life free from fear and want. Today, we're going to explore what that promise really means, why it matters to you, right here, right now, and why it remains a battle we must all fight.
    ''',
  });

  final Color cardBackground;
  final Color primaryPurple;
  final String topic;
  final String transcript;

  @override
  State<FeedbackControllerPage> createState() => _FeedbackControllerPageState();
}

class _FeedbackControllerPageState extends State<FeedbackControllerPage> {
  final voquadroController = VoquadroController.instance;
  final OllamaService _ollamaService = OllamaService();
  bool _isOllamaInitialized = false;

  @override
  void initState() {
    super.initState();
    voquadroController.addListener(_onStateChanged);
    _initializeOllama();
  }

  @override
  void dispose() {
    voquadroController.removeListener(_onStateChanged);
    _ollamaService.clearSession();
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  Future<void> _initializeOllama() async {
    try {
      final isConnected = await _ollamaService.checkOllamaConnection();
      if (!isConnected) {
        debugPrint('Ollama is not running');
        return;
      }

      final modelExists = await _ollamaService.ensureModelExists(
        'qwen2.5:0.5b',
      );
      if (!modelExists) {
        debugPrint('Failed to ensure model exists');
        return;
      }

      setState(() {
        _isOllamaInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing Ollama: $e');
    }
  }

  int _calculateIndex() {
    switch (voquadroController.feedbackState) {
      case FeedbackState.transcript:
        return 0;
      case FeedbackState.speakFeedback:
        return 1;
      case FeedbackState.statFeedback:
        return 2;
      case FeedbackState.progressionDisplay:
        return 3;
      case FeedbackState.nextRankDisplay:
        return 4;
    }
  }

  Widget _feedbackPageController({
    required Color cardBackground,
    required Color primaryPurple,
    required String transcript,
  }) {
    return IndexedStack(
      index: _calculateIndex(),
      children: <Widget>[
        TranscriptPage(
          cardBackground: cardBackground,
          primaryPurple: primaryPurple,
          transcript: widget.transcript,
        ),
        _isOllamaInitialized
            ? SpeakFeedbackPage(
                cardBackground: cardBackground,
                primaryPurple: primaryPurple,
                transcript: widget.transcript,
                topic: widget.topic,
                ollamaService: _ollamaService,
              )
            : _buildOllamaErrorPage(),
        StatFeedbackPage(
          cardBackground: cardBackground,
          primaryPurple: primaryPurple,
        ),
        ProgressionPage(
          cardBackground: cardBackground,
          primaryPurple: primaryPurple,
        ),
        NextRankPage(
          cardBackground: cardBackground,
          primaryPurple: primaryPurple,
        ),
        const Text('Invalid'),
      ],
    );
  }

  Widget _buildOllamaErrorPage() {
    return Container(
      decoration: BoxDecoration(
        color: widget.cardBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'AI Feedback Unavailable',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please ensure Ollama is running\nand the required models are installed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeOllama,
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _feedbackPageController(
      cardBackground: widget.cardBackground,
      primaryPurple: widget.primaryPurple,
      transcript: widget.transcript,
    );
  }
}
