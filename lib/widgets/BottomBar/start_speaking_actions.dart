import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/interview-controller/interview_controller.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/services/sound_service.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:voquadro/widgets/Modals/mode_selection_modal.dart';
import 'package:voquadro/theme/voquadro_colors.dart';

class StartSpeakingActions extends StatefulWidget {
  const StartSpeakingActions({super.key});

  @override
  State<StartSpeakingActions> createState() => _StartSpeakingActionsState();
}

class _StartSpeakingActionsState extends State<StartSpeakingActions>
    with SingleTickerProviderStateMixin {
  final Logger _logger = Logger();
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
                    _logger.d('Start Speaking button pressed!');
                    context.read<SoundService>().playSfx(
                      'assets/audio/button_click.mp3',
                    );
                    final appFlow = context.read<AppFlowController>();
                    if (appFlow.currentMode == AppMode.interviewMode) {
                      context.read<InterviewController>().startMicTest();
                    } else {
                      context.read<PublicSpeakingController>().startMicTest();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.read<AppFlowController>().currentMode == AppMode.interviewMode
                        ? VoquadroColors.interviewPrimary
                        : VoquadroColors.primaryAction,
                    foregroundColor: VoquadroColors.white,
                    elevation: 3.0,
                    shadowColor: VoquadroColors.shadowColorStrong,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: Text(
                    context.read<AppFlowController>().currentMode == AppMode.interviewMode
                        ? 'Start Interview!'
                        : 'Start Speaking!',
                    style: const TextStyle(
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
                  _logger.d('Mode switcher button pressed!');
                  context.read<SoundService>().playSfx(
                    'assets/audio/button_click.mp3',
                  );
                  
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => const ModeSelectionModal(),
                  );
                },
                style: FilledButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: VoquadroColors.primaryAction,
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
