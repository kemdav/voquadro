import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';

class FeedbackProgressWidget extends StatelessWidget {
  const FeedbackProgressWidget({super.key, required this.activeColor});

  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    // Watch the controller to get the current step
    final controller = context.watch<PublicSpeakingController>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(FeedbackStep.values.length, (index) {
        // The active state is now based on the controller's property
        bool isActive = index == controller.currentFeedbackStep.index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 60,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.white,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(
              color: isActive ? Colors.transparent : Colors.grey.shade300,
            ),
          ),
        );
      }),
    );
  }
}