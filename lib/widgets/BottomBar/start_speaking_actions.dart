import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/data/notifiers.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:voquadro/src/hex_color.dart';

class StartSpeakingActions extends StatefulWidget {
  const StartSpeakingActions({super.key});

  @override
  State<StartSpeakingActions> createState() => _StartSpeakingActionsState();
}

class _StartSpeakingActionsState extends State<StartSpeakingActions>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Start animation on load
    _controller.forward();
  }

  static const double _mainButtonHeight = 70.0;
  static const double _mainButtonWidth = 250.0;
  static const double _spacing = 15.0;
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                width: _mainButtonWidth,
                height: _mainButtonHeight,
                child: ElevatedButton(
                  onPressed: () {
                    context
                        .read<PublicSpeakingController>()
                        .generateRandomQuestionAndStart();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: "00A9A5".toColor(),
                    foregroundColor: Colors.white,
                    elevation: 3.0,
                    shadowColor: Colors.black.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Start Speaking!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: _spacing),
            SizedBox(
              height: 64,
              width: 64,
              child: FilledButton(
                onPressed: () {
                  // Toggle logic for mode switcher
                  if (publicModeSelectedNotifier.value == 0) {
                    publicModeSelectedNotifier.value = 1;
                  } else {
                    publicModeSelectedNotifier.value = 0;
                  }
                },
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: "50D8D6".toColor(),
                  shape: const CircleBorder(),
                  elevation: 3.0,
                ),
                child: SvgPicture.asset(
                  'assets/homepage_assets/mode_switcher.svg',
                  width: 25,
                  height: 25,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
