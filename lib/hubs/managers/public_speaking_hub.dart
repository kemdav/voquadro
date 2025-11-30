import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/screens/gameplay/feedback/feedback_flow_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/public_speaking_home_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/mic_test_page.dart';
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
import 'package:voquadro/screens/misc/under_construction.dart'; // [ADDED] Import

class PublicSpeakingHub extends StatelessWidget {
  const PublicSpeakingHub({super.key});

  /// Build the actions widget based on current state
  Widget _buildBottomActions(PublicSpeakingState state) {
    switch (state) {
      case PublicSpeakingState.home:
      case PublicSpeakingState.status:
        return const StartSpeakingActions();

      case PublicSpeakingState.profile:
      case PublicSpeakingState
          .journey: // Journey uses empty bottom actions (nav bar handles it)\
      case PublicSpeakingState.underConstruction:
        return const EmptyNavigationActions();

      case PublicSpeakingState.micTest:
        return EmptyNavigationActions();
      case PublicSpeakingState.readying:
        return const EmptyActions();
      case PublicSpeakingState.speaking:
        // For any gameplay state, show the gameplay-specific buttons.
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
      case PublicSpeakingState.journey: // Standard size
      case PublicSpeakingState.underConstruction:
        return [80, 180];

      case PublicSpeakingState.micTest:
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

    return ChangeNotifierProxyProvider2<
      AppFlowController,
      AudioController,
      PublicSpeakingController
    >(
      create: (context) => PublicSpeakingController(
        audioController: context.read<AudioController>(),
        appFlowController: context.read<AppFlowController>(),
      ),
      update: (context, appFlowController, audioController, previous) {
        if (previous == null) {
          return PublicSpeakingController(
            audioController: audioController,
            appFlowController: appFlowController,
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
                            isVisible: controller.currentState ==
                                PublicSpeakingState.journey,
                          ),
                          const MicTestPage(),
                          const ReadyingPromptPage(),
                          const SpeakingPage(),
                          const FeedbackFlowPage(),
                          const UnderConstructionPage(), // [ADDED] Under Construction Page
                        ],
                      ),
                    ),
                    // Bottom navigation bar (only shown when appropriate)
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
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
