import 'package:flutter/material.dart';
import 'package:voquadro/src/ai-integration/ollama_service.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/views/widgets/AppBar/empty_actions.dart';
import 'package:voquadro/views/widgets/AppBar/general_app_bar.dart';
import 'package:voquadro/views/widgets/BottomBar/gameplay_actions.dart';
import 'package:voquadro/views/widgets/BottomBar/general_navigation_bar.dart';

class SpeakingPage extends StatefulWidget {
  const SpeakingPage({super.key});

  @override
  State<SpeakingPage> createState() => _SpeakingPageState();
}

class _SpeakingPageState extends State<SpeakingPage> {
  final GlobalKey<State<GameplayActions>> _gameplayActionsKey = GlobalKey();
  late final OllamaService _ollamaService;
  late Future<String> _questionFuture;
  bool _ollamaConnected = false;
  String _connectionStatus = 'Checking Ollama connection...';

  @override
  void initState() {
    super.initState();
    _ollamaService = OllamaService();
    _initializeOllama();
  }

  Future<void> _initializeOllama() async {
    try {
      // Attempt to generate a question to verify connection
      setState(() {
        _connectionStatus = 'Connecting to Ollama...';
      });
      final session = await _ollamaService.generateQuestion(
        "About life and current social issues",
      );
      setState(() {
        _ollamaConnected = true;
        _connectionStatus = 'Connected to Ollama';
        _questionFuture = Future.value(session.generatedQuestion);
      });
    } catch (e) {
      setState(() {
        _ollamaConnected = false;
        _connectionStatus =
            'Ollama not reachable. Using fallback question. Error: $e';
        _questionFuture = Future.value(_getFallbackQuestion());
      });
    }
  }

  String _getFallbackQuestion() {
    final fallbackQuestions = [
      "What is a belief you hold that you would be willing to stand up for, even if your voice shook?",
      "When have you felt most understood by another person, and what created that feeling of connection?",
      "What story from your own life has taught you the most about resilience?",
      "How would you explain a complex topic you are passionate about to a curious child?",
    ];
    return fallbackQuestions[DateTime.now().millisecond %
        fallbackQuestions.length];
  }

  Future<void> _retryQuestion() async {
    setState(() {
      _questionFuture = Future.value('Retrying connection...');
      _connectionStatus = 'Retrying connection to Ollama...';
    });
    await _initializeOllama();
  }

  @override
  Widget build(BuildContext context) {
    const double customAppBarHeight = 80.0;
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: customAppBarHeight),
            child: Center(
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: 0.3,
                    minHeight: 10,
                    backgroundColor: Colors.grey[300],
                    color: "6CCC51".toColor(),
                  ),
                  const SizedBox(height: 20),
                  // Connection status indicator
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: _ollamaConnected
                          ? Colors.green[50]
                          : Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _ollamaConnected ? Colors.green : Colors.orange,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _ollamaConnected ? Icons.check_circle : Icons.warning,
                          color: _ollamaConnected
                              ? Colors.green
                              : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _connectionStatus,
                            style: TextStyle(
                              color: _ollamaConnected
                                  ? Colors.green
                                  : Colors.orange,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  //flexible container box for question
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.2,
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: FutureBuilder<String>(
                            future: _questionFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 16),
                                    Text(
                                      _connectionStatus,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              }

                              if (snapshot.hasError) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Error: ${snapshot.error}',
                                      style: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _retryQuestion,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: "6CCC51".toColor(),
                                        foregroundColor: Colors.white,
                                      ),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                );
                              }

                              if (snapshot.hasData) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      snapshot.data!,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        height: 1.4,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    if (!_ollamaConnected)
                                      Padding(
                                        padding: const EdgeInsets.only(
                                          top: 16.0,
                                        ),
                                        child: Text(
                                          'Using fallback question',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              }

                              return const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(
                                    "Generating a question...",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  //a.dolph
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Image.asset(
                        'assets/images/tempCharacter.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBarGeneral(actionButtons: EmptyActions()),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: GeneralNavigationBar(
              actions: GameplayActions(key: _gameplayActionsKey),
              navBarVisualHeight: 70,
              totalHitTestHeight: 130,
            ),
          ),
        ],
      ),
    );
  }
}
