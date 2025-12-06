import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/theme/voquadro_colors.dart';

class TranscriptPage extends StatefulWidget {
  const TranscriptPage({
    super.key,
    required this.cardBackground,
    required this.primaryPurple,
    this.isVisible = true, // To trigger animations
  });

  final Color cardBackground;
  final Color primaryPurple;
  final bool isVisible;

  @override
  State<TranscriptPage> createState() => _TranscriptPageState();
}

class _TranscriptPageState extends State<TranscriptPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    if (widget.isVisible) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant TranscriptPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access Controllers
    final audioController = context.watch<AudioController>();
    
    // Define an accent color (Teal/Cyan) matching previous screens
    final Color accentCyan = VoquadroColors.accentCyan; 

    return Consumer<PublicSpeakingController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // 1. PAGE TITLE
              FadeSlideTransition(
                controller: _controller,
                intervalStart: 0.0,
                intervalEnd: 0.4,
                child: Center(
                  child: Text(
                    'Your Response',
                    style: TextStyle(
                      color: widget.primaryPurple,
                      fontSize: 28, // Matches other headers
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),

              // 2. AUDIO PLAYER CARD
              FadeSlideTransition(
                controller: _controller,
                intervalStart: 0.2,
                intervalEnd: 0.6,
                child: _buildAudioPlayerCard(audioController, accentCyan),
              ),

              const SizedBox(height: 20),

              // 3. TRANSCRIPT CARD
              Expanded(
                child: FadeSlideTransition(
                  controller: _controller,
                  intervalStart: 0.4,
                  intervalEnd: 0.8,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: widget.cardBackground,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.primaryPurple.withValues(alpha: 0.1),
                          blurRadius: 20,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question Section
                            if (controller.currentQuestion != null) 
                              _buildQuestionBox(controller.currentQuestion!),

                            const SizedBox(height: 20),
                            
                            const Text(
                              "Transcript",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Content Logic
                            _buildTranscriptContent(controller),
                            
                            const SizedBox(height: 40), // Bottom padding
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET: Audio Player Card ---
  Widget _buildAudioPlayerCard(AudioController audioController, Color accentColor) {
    final isPlaying = audioController.audioState == AudioState.playing;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Play/Stop Button
          Container(
            decoration: BoxDecoration(
              color: isPlaying ? Colors.redAccent.shade100 : accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              iconSize: 32,
              color: isPlaying ? Colors.red : accentColor,
              icon: Icon(isPlaying ? Icons.stop_rounded : Icons.play_arrow_rounded),
              onPressed: () {
                if (isPlaying) {
                  audioController.stopPlayback();
                } else {
                  audioController.playRecording();
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          // Text Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isPlaying ? "Playing..." : "Listen Recording",
                style: TextStyle(
                  color: widget.primaryPurple,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                isPlaying ? "Tap to stop" : "Tap to play",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Visual Waveform Icon
          if (isPlaying)
            Icon(Icons.graphic_eq, color: accentColor)
          else
            Icon(Icons.mic_none, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  // --- WIDGET: Question Box ---
  Widget _buildQuestionBox(String question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.primaryPurple.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.primaryPurple.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_outline, size: 20, color: widget.primaryPurple),
              const SizedBox(width: 8),
              Text(
                "QUESTION",
                style: TextStyle(
                  color: widget.primaryPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            question,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.3,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // --- LOGIC: Transcript Content ---
  Widget _buildTranscriptContent(PublicSpeakingController controller) {
    final transcript = controller.userTranscript;

    // 1. Loading
    if (controller.isTranscribing) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              CircularProgressIndicator(color: widget.primaryPurple),
              const SizedBox(height: 12),
              const Text(
                'Transcribing audio...',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    } 
    
    // 2. Error
    else if (controller.transcriptionError != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 30),
            const SizedBox(height: 8),
            Text(
              controller.transcriptionError!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.redAccent),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                context.read<PublicSpeakingController>().onEnterFeedbackFlow();
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } 
    
    // 3. Success
    else if (transcript != null && transcript.isNotEmpty) {
      return Text(
        transcript,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 16,
          height: 1.6, // Better readability
        ),
      );
    } 
    
    // 4. Empty
    else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(Icons.notes, size: 40, color: Colors.grey.shade300),
              const SizedBox(height: 8),
              const Text(
                'No transcript available.',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }
}

// ---------------------------------------------------------
// FADE SLIDE TRANSITION (Reusable Helper)
// ---------------------------------------------------------
class FadeSlideTransition extends StatelessWidget {
  final AnimationController controller;
  final double intervalStart;
  final double intervalEnd;
  final Widget child;

  const FadeSlideTransition({
    super.key,
    required this.controller,
    required this.intervalStart,
    required this.intervalEnd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final animation = CurvedAnimation(
          parent: controller,
          curve: Interval(
            intervalStart,
            intervalEnd,
            curve: Curves.easeOutQuart,
          ),
        );
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}