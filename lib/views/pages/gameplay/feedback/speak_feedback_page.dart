import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/src/ai-integration/ollama_service.dart';

class SpeakFeedbackPage extends StatefulWidget {
  final Color cardBackground;
  final Color primaryPurple;
  final String transcript;
  final String topic; // Add topic parameter
  final OllamaService ollamaService; // Receive the service

  const SpeakFeedbackPage({
    super.key,
    required this.cardBackground,
    required this.primaryPurple,
    required this.transcript,
    required this.topic,
    required this.ollamaService,
  });

  @override
  State<SpeakFeedbackPage> createState() => _SpeakFeedbackPageState();
}

class _SpeakFeedbackPageState extends State<SpeakFeedbackPage> {
  late Future<String> _feedbackFuture;
  SpeechSession? _currentSession;

  @override
  void initState() {
    super.initState();
    _feedbackFuture = _getFeedback();
  }

  Future<String> _getFeedback() async {
    if (widget.transcript.trim().isEmpty) {
      return 'Please provide a speech transcript to analyze.';
    }

    try {
      // Generate a question first to create a session
      _currentSession = await widget.ollamaService.generateQuestion(
        widget.topic,
      );

      // Now get feedback using the session
      final results = await Future.wait([
        widget.ollamaService.getPublicSpeakingFeedback(
          widget.transcript,
          _currentSession!,
        ),
        Future.delayed(const Duration(milliseconds: 1500)),
      ]);
      return results[0] as String;
    } catch (e) {
      return 'Error fetching feedback: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton.filled(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.close),
          iconSize: 70,
          style: IconButton.styleFrom(
            backgroundColor: "23B5D3".toColor(),
            foregroundColor: Colors.white,
          ),
        ),
        Text(
          'Rating: 69',
          style: TextStyle(
            color: widget.primaryPurple,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: widget.cardBackground,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: FutureBuilder<String>(
                future: _feedbackFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text(
                            'Generating feedback...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _feedbackFuture = _getFeedback();
                              });
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  final feedback = snapshot.data ?? 'No feedback available';

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Speech Feedback',
                          style: TextStyle(
                            color: widget.primaryPurple,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Display the practice question if available
                        // if (_currentSession != null)
                        //   Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Text(
                        //         'Practice Question:',
                        //         style: TextStyle(
                        //           color: widget.primaryPurple,
                        //           fontSize: 18,
                        //           fontWeight: FontWeight.bold,
                        //         ),
                        //       ),
                        //       Text(
                        //         _currentSession!.generatedQuestion,
                        //         style: const TextStyle(
                        //           fontSize: 16,
                        //           fontStyle: FontStyle.italic,
                        //           height: 1.5,
                        //         ),
                        //       ),
                        //       const SizedBox(height: 16),
                        //     ],
                        //   )
                        Text(
                          feedback,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
