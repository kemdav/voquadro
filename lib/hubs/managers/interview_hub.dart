import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/hubs/controllers/interview-controller/interview_controller.dart';
import 'package:voquadro/screens/gameplay/interview/pages/interview_loading_page.dart';
import 'package:voquadro/screens/gameplay/interview/pages/interview_readying_page.dart';
import 'package:voquadro/screens/gameplay/interview/pages/interview_speaking_page.dart';
import 'package:voquadro/screens/gameplay/interview/pages/interview_feedback_page.dart';
import 'package:voquadro/screens/gameplay/shared/character_home_page.dart';
import 'package:voquadro/data/interview_data.dart';
import 'package:voquadro/screens/gameplay/shared/mic_test_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/status_page.dart';
import 'package:voquadro/screens/home/public_speaking_profile_stage.dart';
import 'package:voquadro/screens/home/user_journey/public_speak_journey_section.dart';
import 'package:voquadro/widgets/AppBar/empty_actions.dart';
import 'package:voquadro/widgets/AppBar/general_app_bar.dart';
import 'package:voquadro/widgets/AppBar/default_actions.dart';
import 'package:voquadro/widgets/BottomBar/empty_actions.dart';
import 'package:voquadro/widgets/BottomBar/interview_gameplay_actions.dart';
import 'package:voquadro/widgets/BottomBar/general_navigation_bar.dart';
import 'package:voquadro/widgets/BottomBar/start_speaking_actions.dart';
import 'package:voquadro/screens/misc/under_construction.dart';
import 'package:voquadro/services/sound_service.dart';

class InterviewHub extends StatelessWidget {
  const InterviewHub({super.key});

  /// Build the actions widget based on current state
  Widget _buildBottomActions(InterviewState state) {
    switch (state) {
      case InterviewState.home:
      case InterviewState.status:
        return const StartSpeakingActions();

      case InterviewState.profile:
      case InterviewState.journey:
      case InterviewState.underConstruction:
        return const EmptyNavigationActions();

      case InterviewState.micTest:
        return EmptyNavigationActions();

      case InterviewState.loading:
        return const EmptyActions();

      case InterviewState.readying:
        return const EmptyActions();
      case InterviewState.interviewing:
        return const InterviewGameplayActions();
      case InterviewState.inFeedback:
        return const EmptyNavigationActions();
    }
  }

  /// Build the upper app bar actions based on current state
  Widget _buildUpperActions(InterviewState state) {
    switch (state) {
      case InterviewState.home:
      case InterviewState.status:
      case InterviewState.profile:
      case InterviewState.underConstruction:
        return const DefaultActions();

      case InterviewState.journey:
      case InterviewState.micTest:
      case InterviewState.loading:
      case InterviewState.readying:
        return const EmptyActions();

      case InterviewState.interviewing:
      case InterviewState.inFeedback:
        return const EmptyActions();
    }
  }

  /// Determine if the bottom navigation bar should be visible
  bool _shouldShowBottomBar(InterviewState state) {
    switch (state) {
      case InterviewState.home:
      case InterviewState.status:
      case InterviewState.profile:
      case InterviewState.journey:
      case InterviewState.underConstruction:
      case InterviewState.interviewing:
        return true;

      case InterviewState.micTest:
      case InterviewState.loading:
      case InterviewState.readying:
      case InterviewState.inFeedback:
        return false;
    }
  }

  /// Determine if the navigation icons should be visible
  bool _shouldShowNavigationIcons(InterviewState state) {
    switch (state) {
      case InterviewState.home:
      case InterviewState.status:
      case InterviewState.profile:
      case InterviewState.journey:
      case InterviewState.underConstruction:
        return true;

      case InterviewState.micTest:
      case InterviewState.loading:
      case InterviewState.readying:
      case InterviewState.interviewing:
      case InterviewState.inFeedback:
        return false;
    }
  }

  /// Get the bottom navigation bar dimensions based on state
  List<double> _bottomNavigationBarDimensions(InterviewState state) {
    switch (state) {
      case InterviewState.home:
      case InterviewState.status:
      case InterviewState.profile:
      case InterviewState.journey:
      case InterviewState.underConstruction:
        return [70, 160];

      case InterviewState.micTest:
        return [140, 40];

      case InterviewState.loading:
      case InterviewState.readying:
        return [120, 40];
      case InterviewState.interviewing:
        return [40, 150];
      case InterviewState.inFeedback:
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
      InterviewController
    >(
      create: (context) => InterviewController(
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
              return InterviewController(
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
            Consumer<InterviewController>(
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
                          // 0. Home
                          CharacterHomePage(
                            facts: InterviewData.facts,
                            defaultImage: InterviewData.defaultImage,
                            soundEffectPath: InterviewData.soundEffect,
                            isVisible:
                                controller.currentState ==
                                InterviewState.home,
                            isTutorialActive: false, // TODO: Add tutorial logic
                          ),
                          // 1. Profile
                          const PublicSpeakingProfileStage(), // Reuse or create InterviewProfileStage
                          // 2. Status
                          const PublicSpeakingStatusPage(), // Reuse or create InterviewStatusPage
                          // 3. Journey
                          const PublicSpeakJourneySection(
                            isVisible: true,
                          ), // Reuse or create InterviewJourneySection
                          // 4. Mic Test
                          const MicTestPage(),
                          // 5. Loading
                          const InterviewLoadingPage(),
                          // 6. Readying
                          const InterviewReadyingPage(),
                          // 7. Interviewing
                          const InterviewSpeakingPage(),
                          // 8. Feedback
                          const InterviewFeedbackPage(),
                          // 9. Under Construction
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
