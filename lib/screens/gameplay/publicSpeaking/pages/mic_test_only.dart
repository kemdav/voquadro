import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/src/hex_color.dart';

class MicTestOnlyPage extends StatefulWidget {
  const MicTestOnlyPage({super.key});

  @override
  State<MicTestOnlyPage> createState() => _MicTestOnlyPageState();
}

class _MicTestOnlyPageState extends State<MicTestOnlyPage> {
  // Flags
  bool _successDetected = false;
  bool _isReadyToListen = false;

  Timer? _visualTimer;
  late AudioController _audioController;

  @override
  void initState() {
    super.initState();
    _audioController = context.read<AudioController>();

    // Start the warmup sequence immediately as this page is accessed directly
    _startWarmupSequence();
  }

  @override
  void dispose() {
    _stopEverything();
    super.dispose();
  }

  /// Kills mic streams and timers.
  void _stopEverything() {
    _visualTimer?.cancel();
    // Stop the stream to release hardware resources
    _audioController.stopAmplitudeStream();
  }

  Future<void> _startWarmupSequence() async {
    if (!mounted) return;

    // Reset UI
    setState(() {
      _successDetected = false;
      _isReadyToListen = false;
    });

    // Clean Hardware Restart
    await _audioController.stopAmplitudeStream();
    // Tiny delay to let hardware release
    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      _audioController.startAmplitudeStream();
    }

    // Visual Timer for "Calibrating..."
    _visualTimer?.cancel();
    _visualTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isReadyToListen = true;
        });
      }
    });
  }

  Future<void> _handleSuccess(AudioController audioController) async {
    // Prevent double triggers
    if (_successDetected) return;

    // Stop mic stream immediately upon success to "lock" the visual state
    await audioController.stopAmplitudeStream();

    if (mounted) {
      setState(() {
        _successDetected = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to values
    final audioController = context.watch<AudioController>();
    final double amplitude = audioController.currentAmplitude;

    // Logic: Only process "Good" signal if we are ready and loud enough
    final bool isGood = amplitude >= 0.2 && _isReadyToListen;

    // Colors
    final Color primaryPurple = "49416D".toColor();
    final Color accentCyan = "23B5D3".toColor();
    final Color activeColor = _successDetected
        ? accentCyan
        : (isGood ? accentCyan : Colors.grey.shade300);

    // Auto-trigger success
    if (isGood && !_successDetected) {
      Future.microtask(() => _handleSuccess(audioController));
    }

    // Determine UI Text
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
          onPressed: () => Navigator.of(context).pop(),
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
            // Replaces the loading indicator with a manual exit button on success
            if (_successDetected)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
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
