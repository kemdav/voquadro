import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/src/hex_color.dart'; 

class MicTestPage extends StatefulWidget {
  const MicTestPage({super.key});

  @override
  State<MicTestPage> createState() => _MicTestPageState();
}

class _MicTestPageState extends State<MicTestPage> {
  bool _isNavigating = false;
  bool _successDetected = false;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    // Start listening to the mic immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AudioController>().startAmplitudeStream();
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  void _handleSuccess(PublicSpeakingController psController, AudioController audioController) {
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
      _successDetected = true;
    });

    // Wait 1.5 seconds so user sees the "Success" animation, then proceed
    _navigationTimer = Timer(const Duration(milliseconds: 1500), () async {
      audioController.stopAmplitudeStream();
      await psController.generateRandomQuestionAndStart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();
    final publicSpeakingController = context.read<PublicSpeakingController>();

    final double amplitude = audioController.currentAmplitude;
    
    // Thresholds
    final bool isTooQuiet = amplitude < 0.2;
    final bool isGood = amplitude >= 0.2;

    // Colors
    final Color primaryPurple = "49416D".toColor();
    final Color accentCyan = "23B5D3".toColor();
    final Color activeColor = _successDetected ? accentCyan : (isGood ? accentCyan : Colors.grey.shade300);

    // Auto-trigger success if volume is good and we haven't triggered yet
    if (isGood && !_isNavigating && !_successDetected) {
      Future.microtask(() => _handleSuccess(publicSpeakingController, audioController));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. INSTRUCTION TEXT
            Text(
              _successDetected ? "Perfect!" : "Say something...",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: primaryPurple,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _successDetected 
                  ? "Microphone is ready." 
                  : "We need to check your microphone.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 60),

            // 2. PULSING MIC ANIMATION
            SizedBox(
              height: 250,
              width: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow (Reacts to Volume)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: _successDetected ? 220 : 120 + (amplitude * 200),
                    height: _successDetected ? 220 : 120 + (amplitude * 200),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // UPDATED: Replaced withOpacity with withValues
                      color: activeColor.withValues(alpha: _successDetected ? 0.2 : 0.1),
                    ),
                  ),
                  // Middle Glow
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: _successDetected ? 180 : 100 + (amplitude * 100),
                    height: _successDetected ? 180 : 100 + (amplitude * 100),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // UPDATED: Replaced withOpacity with withValues
                      color: activeColor.withValues(alpha: _successDetected ? 0.3 : 0.2),
                    ),
                  ),
                  // The Mic Icon Container
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: activeColor,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Icon(
                      _successDetected ? Icons.check_rounded : Icons.mic_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // 3. STATUS INDICATOR
            if (_successDetected)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 500),
                builder: (context, value, _) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(
                              strokeWidth: 2, 
                              color: primaryPurple
                            )
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Starting Session...",
                            style: TextStyle(
                              color: primaryPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              )
            else
              // Visual "Volume Bar" substitute text
              Text(
                 isTooQuiet ? "Louder..." : "Listening...",
                 style: TextStyle(
                   color: Colors.grey.shade400,
                   fontWeight: FontWeight.bold,
                   letterSpacing: 1.2,
                 ),
              ),
          ],
        ),
      ),
    );
  }
}