// [FILE: kemdav/voquadro/voquadro-feature-animation-dolph-and-other-stuff/lib/screens/gameplay/publicSpeaking/pages/mic_test_only.dart]

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart'; // [FIX] Added import
import 'package:voquadro/src/hex_color.dart';

class MicTestOnlyPage extends StatefulWidget {
  const MicTestOnlyPage({super.key});

  @override
  State<MicTestOnlyPage> createState() => _MicTestOnlyPageState();
}

class _MicTestOnlyPageState extends State<MicTestOnlyPage> {
  // Flags
  bool _isActive = false; // [FIX] Track visibility
  bool _successDetected = false;
  bool _isReadyToListen = false;

  Timer? _visualTimer;
  late AudioController _audioController;
  late PublicSpeakingController _psController; // [FIX] Controller reference

  @override
  void initState() {
    super.initState();
    _audioController = context.read<AudioController>();
    _psController = context.read<PublicSpeakingController>();

    // [FIX] Listen to state changes instead of running immediately
    _psController.addListener(_onStateChanged);
    _onStateChanged(); // Initial check
  }

  @override
  void dispose() {
    _psController.removeListener(_onStateChanged); // [FIX] Clean up listener
    _stopEverything(fromDispose: true);
    super.dispose();
  }

  // [FIX] Handle visibility logic
  void _onStateChanged() {
    if (!mounted) return;

    final bool shouldBeActive =
        _psController.currentState == PublicSpeakingState.micTestOnly;

    if (shouldBeActive && !_isActive) {
      // We just became visible
      _isActive = true;
      _startWarmupSequence();
    } else if (!shouldBeActive && _isActive) {
      // We just became hidden
      _isActive = false;
      _stopEverything();
    }
  }

  /// Kills mic streams and timers.
  void _stopEverything({bool fromDispose = false}) {
    _visualTimer?.cancel();
    _audioController.stopAmplitudeStream();

    if (!fromDispose && mounted) {
      setState(() {
        _successDetected = false;
        _isReadyToListen = false;
      });
    }
  }

  Future<void> _startWarmupSequence() async {
    if (!mounted) return;

    // Reset UI
    setState(() {
      _successDetected = false;
      _isReadyToListen = false;
    });

    try {
      // Clean Hardware Restart
      await _audioController.stopAmplitudeStream();
      // Tiny delay to let hardware release
      await Future.delayed(const Duration(milliseconds: 200));

      // [FIX] Only start if active and mounted
      if (_isActive && mounted) {
        await _audioController.startAmplitudeStream();
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
    } catch (e) {
      debugPrint("Error starting mic test: $e");
      // Optionally show a snackbar here if permission is denied
    }
  }

  Future<void> _handleSuccess(AudioController audioController) async {
    if (_successDetected) return;

    // Stop mic stream immediately upon success to "lock" the visual state
    await audioController.stopAmplitudeStream();

    if (mounted) {
      setState(() {
        _successDetected = true;
      });
    }
  }

  // [FIX] Navigation helper
  void _goBack() {
    // Stop the stream before leaving
    _stopEverything();
    // Use controller to navigate back to Home state
    context.read<PublicSpeakingController>().showHome();
  }

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();
    final double amplitude = audioController.currentAmplitude;

    // Logic: Only process "Good" signal if we are ready, loud enough, AND active
    final bool isGood = amplitude >= 0.2 && _isReadyToListen && _isActive;

    final Color primaryPurple = "49416D".toColor();
    final Color accentCyan = "23B5D3".toColor();
    final Color activeColor = _successDetected
        ? accentCyan
        : (isGood ? accentCyan : Colors.grey.shade300);

    if (isGood && !_successDetected) {
      Future.microtask(() => _handleSuccess(audioController));
    }

    String statusText;
    String subText;

    if (_successDetected) {
      statusText = "Microphone Ready";
      subText = "Your audio input is working perfectly.";
    } else {
      statusText = "Say something...";
      subText = !_isReadyToListen
          ? "Calibrating..."
          : "We need to check your microphone.";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryPurple),
          onPressed: _goBack, // [FIX] Use correct navigation method
        ),
      ),
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

            // 3. VISUALIZER
            SizedBox(
              height: 250,
              width: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Ring
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    width: _successDetected ? 220 : 120 + (amplitude * 200),
                    height: _successDetected ? 220 : 120 + (amplitude * 200),
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
                    width: _successDetected ? 180 : 100 + (amplitude * 100),
                    height: _successDetected ? 180 : 100 + (amplitude * 100),
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

            // 4. BOTTOM ACTION BUTTON
            if (_successDetected)
              ElevatedButton(
                onPressed: _goBack, // [FIX] Use correct navigation method
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            else
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
