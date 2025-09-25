import 'package:flutter/material.dart';
import 'package:voquadro/data/voquadro_controller.dart';
import 'package:voquadro/views/pages/gameplay/feedback/next_rank_page.dart';
import 'package:voquadro/views/pages/gameplay/feedback/progression_page.dart';
import 'package:voquadro/views/pages/gameplay/feedback/speak_feedback_page.dart';
import 'package:voquadro/views/pages/gameplay/feedback/stat_feedback_page.dart';
import 'package:voquadro/views/pages/gameplay/feedback/transcript_page.dart';

class FeedbackControllerPage extends StatefulWidget {
  const FeedbackControllerPage({
    super.key,
    required this.cardBackground,
    required this.primaryPurple,
  });

  final Color cardBackground;
  final Color primaryPurple;

  @override
  State<FeedbackControllerPage> createState() => _FeedbackControllerPageState();
}

class _FeedbackControllerPageState extends State<FeedbackControllerPage> {
  @override
  Widget build(BuildContext context) {
    return _feedbackPageController(
      cardBackground: widget.cardBackground,
      primaryPurple: widget.primaryPurple,
    );
  }

  final voquadroController = VoquadroController.instance;
  @override
  void initState() {
    super.initState();
    voquadroController.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    voquadroController.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
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
  }) {
    return IndexedStack(
      index: _calculateIndex(),
      children: <Widget>[
        TranscriptPage(
          cardBackground: cardBackground,
          primaryPurple: primaryPurple,
        ),
        SpeakFeedbackPage(
          cardBackground: cardBackground,
          primaryPurple: primaryPurple,
        ),
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
        Text('Invalid'),
      ],
    );
  }
}
