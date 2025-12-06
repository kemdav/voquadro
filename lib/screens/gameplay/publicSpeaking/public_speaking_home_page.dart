import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/services/sound_service.dart';

class PublicSpeakingHomePage extends StatefulWidget {
  const PublicSpeakingHomePage({super.key});

  @override
  State<PublicSpeakingHomePage> createState() => _ModePageState();
}

class _ModePageState extends State<PublicSpeakingHomePage> {
  Timer? _factTimer;
  String _currentFact = "Hi! I'm Dolph.";
  String _currentImage = "assets/images/dolph.png";
  bool _showBubble = false;

  // Random facts list
  final List<Map<String, String>> _dolphFacts = [
    {
      "text": "Did you know? Fear of public speaking is called Glossophobia.",
      "image": "assets/images/dolph_thinking.png"
    },
    {
      "text": "The average person speaks at about 125-150 words per minute.",
      "image": "assets/images/dolph_thinking.png"
    },
    {
      "text": "inom tubig. kaon daghan.",
      "image": "assets/images/dolph_happy.png"
    },
    {
      "text": "dolphins are actually evil, not me tho.",
      "image": "assets/images/dolph_smug.png"
    },
    {
      "text":
          "Your voice sounds different to you than to others because of bone conduction.",
      "image": "assets/images/dolph_thinking.png"
    },
    {
      "text": "Breathing deeply before speaking calms your nervous system.",
      "image": "assets/images/dolph.png"
    },
    {
      "text": "Hatsune Miku is 158 cm tall and 42 kg.",
      "image": "assets/images/dolph_happy.png"
    },
    {
      "text": "Did you know that 1 cm is the same as one centimeter?",
      "image": "assets/images/dolph_smug.png"
    },
    {"text": "6 7", "image": "assets/images/dolph_thinking.png"},
    {
      "text": "We are ..., we carry the flame",
      "image": "assets/images/dolph_sing.png"
    },
    {
      "text": "We'll fight for the Gospel, we'll honor his name",
      "image": "assets/images/dolph_sing.png"
    },
    {
      "text": "We are ..., his courage our own",
      "image": "assets/images/dolph_sing.png"
    },
    {
      "text": "Together unbroken, we'll make Heaven known",
      "image": "assets/images/dolph_sing.png"
    },
  ];

  @override
  void initState() {
    super.initState();
    _startFactTimer();
  }

  @override
  void dispose() {
    _factTimer?.cancel();
    super.dispose();
  }

  void _startFactTimer() {
    _factTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _showNewFact();
    });
  }

  void _showNewFact() {
    if (!mounted) return;

    // Don't show facts if tutorial is active
    final controller = context.read<PublicSpeakingController>();
    if (controller.isTutorialActive) return;

    // Only show facts if we are on the home screen
    if (controller.currentState != PublicSpeakingState.home) return;

    setState(() {
      final randomFact = _dolphFacts[Random().nextInt(_dolphFacts.length)];
      _currentFact = randomFact["text"]!;
      _currentImage = randomFact["image"]!;
      _showBubble = true;
    });

    context.read<SoundService>().playSfx('assets/audio/dolph_sound.wav');

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _showBubble = false;
          // Reset to default image after bubble hides (optional, but keeps it clean)
          // _currentImage = "assets/images/dolph.png";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final controller = context.watch<PublicSpeakingController>();

    // If tutorial is active, we hide the "real" Dolph and Bubble because
    // the Hub will render the tutorial overlay on top of everything.
    if (controller.isTutorialActive) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // 1. DOLPH LAYER
        Positioned(
          bottom: 200,
          left: 0,
          right: 0,
          child: GestureDetector(
            onTap: () {
              _showNewFact();
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Center(
                child: Image.asset(
                  _currentImage,
                  width: screenWidth * 1.5,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // 2. BUBBLE LAYER
        Positioned(
          bottom: screenHeight * 0.60,
          left: 0,
          right: 0,
          child: Center(
            child: AnimatedOpacity(
              opacity: _showBubble ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: CustomPaint(
                painter: _BubblePainter(),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  width: 280,
                  child: Text(
                    _currentFact,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Paint shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    const double tailHeight = 12.0;
    const double tailWidth = 20.0;
    const double radius = 25.0;

    final RRect bubbleBody = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height - tailHeight),
      const Radius.circular(radius),
    );

    final Path path = Path()
      ..addRRect(bubbleBody)
      ..moveTo(size.width / 2 - tailWidth / 2, size.height - tailHeight)
      ..lineTo(size.width / 2, size.height) // The point of the tail
      ..lineTo(size.width / 2 + tailWidth / 2, size.height - tailHeight)
      ..close();

    canvas.drawPath(path.shift(const Offset(0, 4)), shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
