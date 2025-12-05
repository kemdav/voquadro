import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/screens/gameplay/feedback/feedback_flow_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/public_speaking_home_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/mic_test_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/mic_test_only.dart'; // Ensure this matches your file creation
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/readying_prompt_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/speaking_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/status_page.dart';
import 'package:voquadro/screens/home/public_speaking_profile_stage.dart';
import 'package:voquadro/screens/home/user_journey/public_speak_journey_section.dart';
import 'package:voquadro/widgets/AppBar/empty_actions.dart';
import 'package:voquadro/widgets/AppBar/general_app_bar.dart';
import 'package:voquadro/widgets/AppBar/default_actions.dart';
import 'package:voquadro/widgets/BottomBar/empty_actions.dart';
import 'package:voquadro/widgets/BottomBar/gameplay_actions.dart';
import 'package:voquadro/widgets/BottomBar/general_navigation_bar.dart';
import 'package:voquadro/widgets/BottomBar/start_speaking_actions.dart';
import 'package:voquadro/screens/misc/under_construction.dart';
import 'package:voquadro/services/sound_service.dart';

class PublicSpeakingHub extends StatelessWidget {
  const PublicSpeakingHub({super.key});

  /// Build the actions widget based on current state
  Widget _buildBottomActions(PublicSpeakingState state) {
    switch (state) {
      case PublicSpeakingState.home:
      case PublicSpeakingState.status:
        return const StartSpeakingActions();

      case PublicSpeakingState.profile:
      case PublicSpeakingState.journey:
      case PublicSpeakingState.underConstruction:
        return const EmptyNavigationActions();

      case PublicSpeakingState.micTest:
      case PublicSpeakingState.micTestOnly:
        return EmptyNavigationActions();

      case PublicSpeakingState.readying:
        return const EmptyActions();
      case PublicSpeakingState.speaking:
        return GameplayActions();
      case PublicSpeakingState.inFeedback:
        return const EmptyNavigationActions();
    }
  }

  /// Build the upper app bar actions based on current state
  Widget _buildUpperActions(PublicSpeakingState state) {
    switch (state) {
      case PublicSpeakingState.home:
      case PublicSpeakingState.status:
      case PublicSpeakingState.profile:
      case PublicSpeakingState.underConstruction:
        return const DefaultActions();

      case PublicSpeakingState.journey:
      case PublicSpeakingState.micTest:
      case PublicSpeakingState.micTestOnly:
      case PublicSpeakingState.readying:
        return const EmptyActions();

      case PublicSpeakingState.speaking:
      case PublicSpeakingState.inFeedback:
        return const EmptyActions();
    }
  }

  /// Determine if the bottom navigation bar should be visible
  bool _shouldShowBottomBar(PublicSpeakingState state) {
    switch (state) {
      case PublicSpeakingState.home:
      case PublicSpeakingState.status:
      case PublicSpeakingState.profile:
      case PublicSpeakingState.journey:
      case PublicSpeakingState.underConstruction:
      case PublicSpeakingState.speaking:
        return true;

      case PublicSpeakingState.micTest:
      case PublicSpeakingState.micTestOnly:
      case PublicSpeakingState.readying:
      case PublicSpeakingState.inFeedback:
        return false;
    }
  }

  /// Determine if the navigation icons should be visible
  bool _shouldShowNavigationIcons(PublicSpeakingState state) {
    switch (state) {
      case PublicSpeakingState.home:
      case PublicSpeakingState.status:
      case PublicSpeakingState.profile:
      case PublicSpeakingState.journey:
      case PublicSpeakingState.underConstruction:
        return true;

      case PublicSpeakingState.micTest:
      case PublicSpeakingState.micTestOnly:
      case PublicSpeakingState.readying:
      case PublicSpeakingState.speaking:
      case PublicSpeakingState.inFeedback:
        return false;
    }
  }

  /// Get the bottom navigation bar dimensions based on state
  List<double> _bottomNavigationBarDimensions(PublicSpeakingState state) {
    switch (state) {
      case PublicSpeakingState.home:
      case PublicSpeakingState.status:
      case PublicSpeakingState.profile:
      case PublicSpeakingState.journey:
      case PublicSpeakingState.underConstruction:
        return [70, 160];

      case PublicSpeakingState.micTest:
      case PublicSpeakingState.micTestOnly:
        return [140, 40];

      case PublicSpeakingState.readying:
        return [120, 40];
      case PublicSpeakingState.speaking:
        return [40, 150];
      case PublicSpeakingState.inFeedback:
        return [0, 0];
    }
  }

  @override
  Widget build(BuildContext context) {
    const double customAppBarHeight = 80.0;

    return ChangeNotifierProxyProvider3<
      AppFlowController,
      AudioController,
      SoundService,
      PublicSpeakingController
    >(
      create: (context) => PublicSpeakingController(
        audioController: context.read<AudioController>(),
        appFlowController: context.read<AppFlowController>(),
        soundService: context.read<SoundService>(),
      ),
      update:
          (
            context,
            appFlowController,
            audioController,
            soundService,
            previous,
          ) {
            if (previous == null) {
              return PublicSpeakingController(
                audioController: audioController,
                appFlowController: appFlowController,
                soundService: soundService,
              );
            }
            previous.update(appFlowController);
            return previous;
          },
      child: Scaffold(
        body: Stack(
          children: [
            Consumer<PublicSpeakingController>(
              builder: (context, controller, child) {
                final showBottomBar = _shouldShowBottomBar(
                  controller.currentState,
                );
                final showIcons = _shouldShowNavigationIcons(
                  controller.currentState,
                );
                final dimensions = _bottomNavigationBarDimensions(
                  controller.currentState,
                );

                return Stack(
                  children: [
                    // Main content area
                    Padding(
                      padding: const EdgeInsets.only(top: customAppBarHeight),
                      child: IndexedStack(
                        index: controller.currentState.index,
                        children: [
                          const PublicSpeakingHomePage(),
                          const PublicSpeakingProfileStage(),
                          const PublicSpeakingStatusPage(),
                          PublicSpeakJourneySection(
                            isVisible:
                                controller.currentState ==
                                PublicSpeakingState.journey,
                          ),
                          const MicTestPage(),

                          const MicTestOnlyPage(),

                          const ReadyingPromptPage(),
                          const SpeakingPage(),
                          const FeedbackFlowPage(),
                          const UnderConstructionPage(),
                        ],
                      ),
                    ),
                    // Bottom navigation bar
                    if (showBottomBar)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: GeneralNavigationBar(
                          actions: _buildBottomActions(controller.currentState),
                          navBarVisualHeight: dimensions[0],
                          totalHitTestHeight: dimensions[1],
                          showIcons: showIcons,
                        ),
                      ),
                    // Top app bar
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: AppBarGeneral(
                        actionButtons: _buildUpperActions(
                          controller.currentState,
                        ),
                      ),
                    ),

                    // Tutorial Overlay (Covers everything including bars)
                    if (controller.isTutorialActive)
                      _buildTutorialOverlay(context, controller),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialOverlay(
    BuildContext context,
    PublicSpeakingController controller,
  ) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned.fill(
      child: Stack(
        children: [
          // Dimmer
          GestureDetector(
            onTap: controller.nextTutorialStep,
            child: Container(color: Colors.black.withValues(alpha: 0.7)),
          ),

          // Dolph (Tutorial Version)
          Positioned(
            bottom: 260,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: controller.nextTutorialStep,
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Center(
                  child: Image.asset(
                    controller.currentTutorialImage,
                    width: screenWidth * 1.5,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          // Bubble (Tutorial Version)
          Positioned(
            bottom: screenHeight * 0.60,
            left: 0,
            right: 0,
            child: Center(
              child: CustomPaint(
                painter: _BubblePainter(),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                  width: 280,
                  child: Text(
                    controller.currentTutorialMessage,
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

          // Arrow pointing to Start button (Last step)
          if (controller.tutorialIndex ==
              controller.tutorialMessages.length - 1)
            Positioned(
              bottom: 180,
              left: 0,
              right: 0,
              child: const Center(
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.white,
                  size: 48,
                  shadows: [
                    Shadow(
                      blurRadius: 8,
                      color: Colors.black,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),

          // Tutorial Hint
          Positioned(
            bottom: screenHeight * 0.60 + 120,
            left: 0,
            right: 0,
            child: const Center(
              child: Text(
                "Tap anywhere to continue",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
