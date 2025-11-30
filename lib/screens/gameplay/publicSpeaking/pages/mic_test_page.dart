import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/main.dart';

class MicTestPage extends StatefulWidget {
  const MicTestPage({super.key});

  @override
  State<MicTestPage> createState() => _MicTestPageState();
}

// 1. Add RouteAware Mixin
class _MicTestPageState extends State<MicTestPage> with RouteAware {
  bool _isNavigating = false;
  bool _successDetected = false;
  bool _isReadyToListen = false;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _startWarmupSequence();
  }

  // 2. Subscribe to the RouteObserver
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    // 3. Unsubscribe and clean up
    routeObserver.unsubscribe(this);
    _navigationTimer?.cancel();
    // Use read, not watch, in dispose
    context.read<AudioController>().stopAmplitudeStream();
    super.dispose();
  }

  // 4. Called when you push the Game Page (leaving this screen)
  @override
  void didPushNext() {
    // Stop listening immediately so we don't process background noise
    context.read<AudioController>().stopAmplitudeStream();
  }

  // 5. Called when you come BACK from the Game (returning to this screen)
  @override
  void didPopNext() {
    debugPrint("Returned to Mic Page. Resetting...");
    _startWarmupSequence();
  }

  /// Completely resets UI and Hardware state
  Future<void> _startWarmupSequence() async {
    if (!mounted) return;

    // A. Reset UI State
    setState(() {
      _isNavigating = false;
      _successDetected = false;
      _isReadyToListen = false;
    });

    final audioController = context.read<AudioController>();

    // B. Hardware Reset Cycle
    // Stop whatever might be running
    await audioController.stopAmplitudeStream();

    // Critical: Wait for OS audio layer to release lock
    await Future.delayed(const Duration(milliseconds: 200));

    // Only restart if this page is still the active one
    if (mounted && ModalRoute.of(context)?.isCurrent == true) {
      audioController.startAmplitudeStream();
    }

    // C. Visual Warmup Timer (1.5s)
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
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
    if (_isNavigating) return;

    setState(() {
      _isNavigating = true;
      _successDetected = true;
    });

    _navigationTimer = Timer(const Duration(milliseconds: 1500), () async {
      // Stop stream before pushing new route
      await audioController.stopAmplitudeStream();

      try {
        if (!mounted) return;

        // Start the game
        // Note: We do NOT need to await this anymore because 'didPopNext'
        // will handle the return logic automatically.
        psController.generateRandomQuestionAndStart(context);
      } catch (e) {
        debugPrint("Error starting session: $e");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error: $e")));
          _startWarmupSequence();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final audioController = context.watch<AudioController>();
    final publicSpeakingController = context.read<PublicSpeakingController>();

    final double amplitude = audioController.currentAmplitude;

    // Safety check: Don't trigger if we aren't the top page
    final bool isCurrentPage = ModalRoute.of(context)?.isCurrent ?? false;

    // Thresholds
    final bool isTooQuiet = amplitude < 0.2;
    // Only "Good" if loud enough, warmed up, AND currently visible
    final bool isGood = amplitude >= 0.2 && _isReadyToListen && isCurrentPage;

    // Colors
    final Color primaryPurple = "49416D".toColor();
    final Color accentCyan = "23B5D3".toColor();
    final Color activeColor = _successDetected
        ? accentCyan
        : (isGood ? accentCyan : Colors.grey.shade300);

    // Auto-trigger success
    if (isGood && !_isNavigating && !_successDetected) {
      Future.microtask(
        () => _handleSuccess(publicSpeakingController, audioController),
      );
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
                  : (!_isReadyToListen
                        ? "Calibrating..."
                        : "We need to check your microphone."),
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 60),

            // 2. PULSING MIC ANIMATION
            SizedBox(
              height: 250,
              width: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow
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
                  // Middle Glow
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
                  // Icon Container
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
                              color: primaryPurple,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "Starting Session...",
                            style: TextStyle(
                              color: primaryPurple,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            else
              Text(
                !_isReadyToListen
                    ? "Please wait..."
                    : (isTooQuiet ? "Louder..." : "Listening..."),
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
