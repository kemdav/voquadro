import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'dart:math' as math;

class SpeakingPage extends StatelessWidget {
  const SpeakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Colors
    final Color primaryPurple = "49416D".toColor();
    final Color accentRed = Colors.redAccent;
    final Color bgGrey = const Color(0xFFF8F9FC);

    final controller = context.watch<PublicSpeakingController>();
    final session = controller.currentSession;
    final progress = controller.speakingProgress; // 0.0 to 1.0

    // Calculate time left (Assuming 60s total, or just use percentage)
    // If you want exact seconds, you'd need to expose the duration from the controller.
    // For now, we visualize the percentage.
    
    return Scaffold(
      backgroundColor: bgGrey,
      body: SafeArea(
        child: Column(
          children: [
            // 1. TOP BAR (Timer & Recording Status)
            _buildTopBar(progress, primaryPurple, accentRed),

            const Spacer(flex: 1),

            // 2. QUESTION CARD (Hero Element)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildQuestionCard(
                session?.generatedQuestion ??
                    controller.currentQuestion ??
                    "Waiting for question...",
                primaryPurple,
              ),
            ),

            const Spacer(flex: 2),

            // 3. VISUALIZER & CHARACTER
            // We stack the character with a visual "sound wave" effect behind/around
            SizedBox(
              height: 250,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Animated Pulse (Simulating voice activity)
                  const Positioned(
                    bottom: 40,
                    child: PulsingWave(),
                  ),
                  // Character Image
                  Positioned(
                    bottom: 0,
                    child: Image.asset(
                      'assets/images/tempCharacter.png',
                      height: 220, 
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- COMPONENT: Top Bar with Timer ---
  Widget _buildTopBar(double progress, Color primary, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Recording Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.fiber_manual_record, color: accent, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "RECORDING",
                      style: TextStyle(
                        color: accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              // Time Label (Optional)
              Text(
                "Time Remaining",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: 1.0 - progress, // Shrinks as time passes
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              // Color changes from Green to Red as time runs out
              valueColor: AlwaysStoppedAnimation<Color>(
                (1.0 - progress) < 0.2 ? Colors.red : const Color(0xFF6CCC51),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPONENT: Question Card ---
  Widget _buildQuestionCard(String text, Color primary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "YOUR TOPIC",
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              color: primary,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// --- ANIMATION: Pulsing Wave Effect ---
class PulsingWave extends StatefulWidget {
  const PulsingWave({super.key});

  @override
  State<PulsingWave> createState() => _PulsingWaveState();
}

class _PulsingWaveState extends State<PulsingWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = "23B5D3".toColor(); // Accent Cyan

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: CirclePulsePainter(_controller.value, color),
          size: const Size(200, 200),
        );
      },
    );
  }
}

class CirclePulsePainter extends CustomPainter {
  final double progress;
  final Color color;

  CirclePulsePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double maxRadius = size.width / 2;

    // Ring 1
    final double r1 = (progress * maxRadius) % maxRadius;
    final double op1 = 1.0 - (r1 / maxRadius);
    final Paint paint1 = Paint()
      ..color = color.withValues(alpha: op1 * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, r1, paint1);

    // Ring 2 (Offset)
    final double r2 = ((progress + 0.5) * maxRadius) % maxRadius;
    final double op2 = 1.0 - (r2 / maxRadius);
    final Paint paint2 = Paint()
      ..color = color.withValues(alpha: op2 * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, r2, paint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}