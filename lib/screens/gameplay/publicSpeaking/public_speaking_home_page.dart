import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

class PublicSpeakingHomePage extends StatefulWidget {
  const PublicSpeakingHomePage({super.key});

  @override
  State<PublicSpeakingHomePage> createState() => _ModePageState();
}

class _ModePageState extends State<PublicSpeakingHomePage> {
  Timer? _factTimer;
  String _currentFact = "Hi! I'm Dolph.";
  bool _showBubble = false;

  // Random facts list
  final List<String> _randomFacts = [
    "Did you know? Fear of public speaking is called Glossophobia.",
    "The average person speaks at about 125-150 words per minute.",
    "inom tubig. kaon daghan.",
    "dolphins are actually evil, not me tho.",
    "Your voice sounds different to you than to others because of bone conduction.",
    "Breathing deeply before speaking calms your nervous system.",
    "Hatsune Miku is 158 cm tall and 42 kg.",
    "Did you know that 1 cm is the same as one centimeter?",
    "6 7",
    "We are Charlie Kirk, we carry the flame",
    "We'll fight for the Gospel, we'll honor his name",
    "We are Charlie Kirk, his courage our own",
    "Together unbroken, we'll make Heaven known",
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

    setState(() {
      _currentFact = _randomFacts[Random().nextInt(_randomFacts.length)];
      _showBubble = true;
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() {
          _showBubble = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                  'assets/images/dolph.png',
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
                  // Added extra bottom padding (16 + 12) to account for the tail
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
