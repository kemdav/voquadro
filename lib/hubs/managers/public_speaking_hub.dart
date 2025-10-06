import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/audio_controller.dart';
import 'package:voquadro/hubs/controllers/public_speaking_controller.dart'; // 1. Import the controller
import 'package:voquadro/screens/gameplay/feedback/feedback_flow_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/public_speaking_home_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/mic_test_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/readying_prompt_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/speaking_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/status_page.dart';
import 'package:voquadro/widgets/AppBar/empty_actions.dart';
import 'package:voquadro/widgets/AppBar/general_app_bar.dart';
import 'package:voquadro/widgets/AppBar/default_actions.dart';
import 'package:voquadro/widgets/BottomBar/feedback_progress_actions.dart';
import 'package:voquadro/widgets/BottomBar/gameplay_actions.dart';
import 'package:voquadro/widgets/BottomBar/general_navigation_bar.dart';
import 'package:voquadro/widgets/BottomBar/main_hub_actions.dart';

class PublicSpeakingHub extends StatelessWidget {
  const PublicSpeakingHub({super.key});

  Widget _buildBottomActions(PublicSpeakingState state) {
    switch (state) {
      case PublicSpeakingState.home:
      case PublicSpeakingState.status:
        // For home and status, show the main navigation buttons.
        return const MainHubActions();

      case PublicSpeakingState.micTest:
      case PublicSpeakingState.readying:
      case PublicSpeakingState.speaking:
        // For any gameplay state, show the gameplay-specific buttons.
        return const GameplayActions();
      case PublicSpeakingState.inFeedback:
        return FeedbackProgressActions();
    }
  }

  Widget _buildUpperActions(PublicSpeakingState state) {
    switch (state) {
      case PublicSpeakingState.home:
      case PublicSpeakingState.status:
        // For home and status, show the main navigation buttons.
        return const DefaultActions();

      case PublicSpeakingState.micTest:
      case PublicSpeakingState.readying:
      case PublicSpeakingState.speaking:
        // For any gameplay state, show the gameplay-specific buttons.
        return const EmptyActions(); // The NEW, dumb version]
      case PublicSpeakingState.inFeedback:
        return const EmptyActions();
    }
  }

  List<double> _bottomNavigationBarDimensions(PublicSpeakingState state){
    switch (state) {
          case PublicSpeakingState.home:
          case PublicSpeakingState.status:
            return [140, 180];

          case PublicSpeakingState.micTest:
          case PublicSpeakingState.readying:
          case PublicSpeakingState.speaking:
            return [140, 180];
          case PublicSpeakingState.inFeedback:
            return [0, 180];
        }
      }

  @override
  Widget build(BuildContext context) {
    const double customAppBarHeight = 80.0;

    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (_) => PublicSpeakingController()),
        ChangeNotifierProvider(create: (_) => AudioController()),
    ],
    child: Scaffold(
        body: Stack(
          children: [
            // This Consumer will manage both the main content AND the bottom bar
            Consumer<PublicSpeakingController>(
              builder: (context, controller, child) {
                return Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: customAppBarHeight),
                      child: IndexedStack(
                        index: controller.currentState.index,
                        children: const [
                          PublicSpeakingHomePage(),
                          PublicSpeakingStatusPage(),
                          MicTestPage(),
                          ReadyingPromptPage(),
                          SpeakingPage(),
                          FeedbackFlowPage(),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: GeneralNavigationBar(
                        // The actions are now dynamically chosen by our helper method
                        actions: _buildBottomActions(controller.currentState),
                        navBarVisualHeight: _bottomNavigationBarDimensions(controller.currentState)[0],
                        totalHitTestHeight: _bottomNavigationBarDimensions(controller.currentState)[1],
                      ),
                    ),
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
