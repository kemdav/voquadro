import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/views/pages/gameplay/feedback/continue_button_widget.dart';
import 'package:voquadro/views/pages/gameplay/feedback/feedback_controller_page.dart';
import 'package:voquadro/views/pages/gameplay/feedback/feedback_progress_widget.dart';
import 'package:voquadro/views/widgets/AppBar/empty_actions.dart';
import 'package:voquadro/views/widgets/AppBar/general_app_bar.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryPurple = "49416D".toColor();
    final Color buttonPurple = "887CAF".toColor();
    final Color lightBackground = "F7F5FF".toColor();
    final Color cardBackground = Colors.white;
    final Color activeIndicator = "44D6D2".toColor();
    const double customAppBarHeight = 80.0;

    return Scaffold(
      backgroundColor: lightBackground,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: customAppBarHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    Expanded(
                      child: FeedbackControllerPage(
                        cardBackground: cardBackground,
                        primaryPurple: primaryPurple,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FeedbackContinueButton(buttonPurple: buttonPurple),
                    const SizedBox(height: 20),
                    FeedbackProgressWidget(activeColor: activeIndicator),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBarGeneral(actionButtons: EmptyActions()),
            ),
          ],
        ),
      ),
    );
  }
}
