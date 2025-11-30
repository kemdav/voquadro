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
  // Flags
  bool _isActive = false; // Is this page currently visible to the user?
  bool _successDetected = false;
  bool _isReadyToListen = false;
  bool _isProcessingAI = false;

  Timer? _visualTimer;

  @override
  void initState() {
    super.initState();
    // 1. Listen to the controller immediately
    final controller = context.read<PublicSpeakingController>();
    controller.addListener(_onStateChanged);

    // 2. Run initial check (in case we start on this page)
    _onStateChanged();
  }

  @override
  void dispose() {
    // 3. Clean up listener
    context.read<PublicSpeakingController>().removeListener(_onStateChanged);
    _stopEverything();
    super.dispose();
  }

  /// This function runs every time the App Flow State changes.
  void _onStateChanged() {
    if (!mounted) return;

    final controller = context.read<PublicSpeakingController>();

    // Check if we are the active page in the IndexedStack
    final bool shouldBeActive =
        controller.currentState == PublicSpeakingState.micTest;

    if (shouldBeActive && !_isActive) {
      // CASE A: We just became active (User entered Mic Page)
      _isActive = true;
      _startWarmupSequence();
    } else if (!shouldBeActive && _isActive) {
      // CASE B: We just became inactive (User moved to Ready/Speaking Page)
      _isActive = false;
      _stopEverything();
    }
  }

  /// Kills all mic streams, timers, and resets flags.
  /// This ensures the page is "dead" when hidden in the IndexedStack.
  void _stopEverything() {
    _visualTimer?.cancel();
    // Use read() here to avoid triggering rebuilds during dispose/backgrounding
    context.read<AudioController>().stopAmplitudeStream();

    if (mounted) {
      setState(() {
        _successDetected = false;
        _isReadyToListen = false;
        _isProcessingAI = false;
      });
    }
  }

  Future<void> _startWarmupSequence() async {
    if (!mounted) return;

    // Reset UI
    setState(() {
      _successDetected = false;
      _isReadyToListen = false;
      _isProcessingAI = false;
    });

    final audioController = context.read<AudioController>();

    // Clean Hardware Restart
    await audioController.stopAmplitudeStream();
    // Tiny delay to let hardware release
    await Future.delayed(const Duration(milliseconds: 200));

    // Only start if we are still the active state (user didn't leave immediately)
    if (_isActive && mounted) {
      audioController.startAmplitudeStream();
    }

    // Visual Timer for "Calibrating..."
    _visualTimer?.cancel();
    _visualTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _isActive) {
        setState(() {
          _isReadyToListen = true;
        });
      }
    });
  }

  Future<void> _handleSuccess(
    PublicSpeakingController psController,
    AudioController audioController,
  ) async {
    // Prevent double triggers
    if (_successDetected || _isProcessingAI) return;

    setState(() {
      _successDetected = true;
    });

    // Wait 1.5s for the "Perfect!" animation
    _visualTimer = Timer(const Duration(milliseconds: 1500), () async {
      if (!mounted || !_isActive) return;

      // Stop mic before AI processing starts
      await audioController.stopAmplitudeStream();

      setState(() {
        _isProcessingAI = true;
      });

      try {
        // CALL THE CONTROLLER
        // This will change the state to 'readying' (or similar).
        // Once that happens, '_onStateChanged' will fire, and
        // '_stopEverything()' will run automatically.
        await psController.generateRandomQuestionAndStart();
      } catch (e) {
        debugPrint("Error starting session: $e");
        // If AI fails, restart the sequence so user can try again
        if (mounted && _isActive) {
          _startWarmupSequence();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to values
    final audioController = context.watch<AudioController>();
    final publicSpeakingController = context.read<PublicSpeakingController>();

    final double amplitude = audioController.currentAmplitude;

    // Logic: Only process "Good" signal if we are active, ready, and loud enough
    final bool isGood = amplitude >= 0.2 && _isReadyToListen && _isActive;

    // Colors
    final Color primaryPurple = "49416D".toColor();
    final Color accentCyan = "23B5D3".toColor();
    final Color activeColor = _successDetected
        ? accentCyan
        : (isGood ? accentCyan : Colors.grey.shade300);

    // Auto-trigger (Debounced by flags)
    if (isGood && !_successDetected && !_isProcessingAI) {
      Future.microtask(
        () => _handleSuccess(publicSpeakingController, audioController),
      );
    }

    // Determine UI Text
    String statusText;
    String subText;

    if (_isProcessingAI) {
      statusText = "Preparing Session...";
      subText = "Generating your topic...";
    } else if (_successDetected) {
      statusText = "Perfect!";
      subText = "Microphone is ready.";
    } else {
      statusText = "Say something...";
      subText = !_isReadyToListen
          ? "Calibrating..."
          : "We need to check your microphone.";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. STATUS HEADER
            Text(
              statusText,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: primaryPurple,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 2. SUBTITLE
            Text(
              subText,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 60),

            // 3. VISUALIZER / SPINNER
            SizedBox(
              height: 250,
              width: 250,
              child: _isProcessingAI
                  ? const Center(child: CircularProgressIndicator())
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Ring
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: _successDetected
                              ? 220
                              : 120 + (amplitude * 200),
                          height: _successDetected
                              ? 220
                              : 120 + (amplitude * 200),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeColor.withValues(
                              alpha: _successDetected ? 0.2 : 0.1,
                            ),
                          ),
                        ),
                        // Middle Ring
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 100),
                          width: _successDetected
                              ? 180
                              : 100 + (amplitude * 100),
                          height: _successDetected
                              ? 180
                              : 100 + (amplitude * 100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeColor.withValues(
                              alpha: _successDetected ? 0.3 : 0.2,
                            ),
                          ),
                        ),
                        // Icon Circle
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
                              ),
                            ],
                          ),
                          child: Icon(
                            _successDetected
                                ? Icons.check_rounded
                                : Icons.mic_rounded,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 60),

            // 4. BOTTOM LOADING INDICATOR (Optional)
            if (_successDetected && !_isProcessingAI)
              CircularProgressIndicator(color: primaryPurple)
            else if (!_isProcessingAI)
              Text(
                !_isReadyToListen
                    ? "Please wait..."
                    : (amplitude < 0.2 ? "Louder..." : "Listening..."),
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
