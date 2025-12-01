import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/src/ai-integration/interview_mode_service.dart';

class InterviewSessionPage extends StatefulWidget {
  const InterviewSessionPage({super.key});

  @override
  State<InterviewSessionPage> createState() => _InterviewSessionPageState();
}

class _InterviewSessionPageState extends State<InterviewSessionPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _submitAnswer() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });
    _textController.clear();

    try {
      await Provider.of<InterviewModeService>(
        context,
        listen: false,
      ).submitAnswer(text);
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _endSession() async {
    setState(() {
      _isProcessing = true;
    });

    try {
      final feedback = await Provider.of<InterviewModeService>(
        context,
        listen: false,
      ).endSession();

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => InterviewFeedbackPage(feedback: feedback),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error ending session: $e')));
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<InterviewModeService>(
      builder: (context, service, child) {
        final session = service.currentSession;
        if (session == null) {
          return const Scaffold(body: Center(child: Text('No active session')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(session.category.toString().split('.').last),
            actions: [
              IconButton(
                icon: const Icon(Icons.stop_circle_outlined),
                onPressed: _isProcessing ? null : _endSession,
                tooltip: 'End Session',
              ),
            ],
          ),
          body: Column(
            children: [
              // Scenario Header
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.blue.shade50,
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SCENARIO',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.scenario,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),

              // Chat History
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: session.turns.length,
                  itemBuilder: (context, index) {
                    final turn = session.turns[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // AI Question
                        _buildMessageBubble(turn.question, isUser: false),
                        // User Answer (if exists)
                        if (turn.answer != null)
                          _buildMessageBubble(turn.answer!, isUser: true),
                      ],
                    );
                  },
                ),
              ),

              // Input Area
              if (_isProcessing)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: LinearProgressIndicator(),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: 'Type your answer...',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _submitAnswer,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble(String text, {required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}

class InterviewFeedbackPage extends StatelessWidget {
  final Map<String, dynamic> feedback;

  const InterviewFeedbackPage({super.key, required this.feedback});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Session Feedback')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (feedback['score'] != null)
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Score',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    Text(
                      '${feedback['score']}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            const Text(
              'Feedback',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              feedback['feedback'] ?? 'No feedback provided.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            if (feedback['vocabulary_tips'] != null) ...[
              const Text(
                'Vocabulary Tips',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...(feedback['vocabulary_tips'] as List).map(
                (tip) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(tip.toString())),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Center(child: Text('Back to Menu')),
            ),
          ],
        ),
      ),
    );
  }
}
