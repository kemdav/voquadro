import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/services/sound_service.dart';

class CharacterHomePage extends StatefulWidget {
  final List<Map<String, String>> facts;
  final String defaultImage;
  final String soundEffectPath;
  final bool isVisible;
  final bool isTutorialActive;

  const CharacterHomePage({
    super.key,
    required this.facts,
    required this.defaultImage,
    required this.soundEffectPath,
    required this.isVisible,
    required this.isTutorialActive,
  });

  @override
  State<CharacterHomePage> createState() => _CharacterHomePageState();
}

class _CharacterHomePageState extends State<CharacterHomePage> {
  Timer? _factTimer;
  late String _currentFact;
  late String _currentImage;
  bool _showBubble = false;

  @override
  void initState() {
    super.initState();
    _currentFact = widget.facts.isNotEmpty ? widget.facts[0]['text']! : "Hello!";
    _currentImage = widget.defaultImage;
    _startFactTimer();
  }

  @override
  void didUpdateWidget(CharacterHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.defaultImage != oldWidget.defaultImage) {
      _currentImage = widget.defaultImage;
    }
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

    // Don't show facts if tutorial is active or page is not visible
    if (widget.isTutorialActive || !widget.isVisible) return;

    setState(() {
      if (widget.facts.isNotEmpty) {
        final randomFact = widget.facts[Random().nextInt(widget.facts.length)];
        _currentFact = randomFact["text"]!;
        _currentImage = randomFact["image"] ?? widget.defaultImage;
        _showBubble = true;
      }
    });

    context.read<SoundService>().playSfx(widget.soundEffectPath);

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

    if (widget.isTutorialActive) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        // 1. CHARACTER LAYER
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
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(
                      height: 200,
                      child: Center(child: Icon(Icons.person, size: 100)),
                    );
                  },
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
