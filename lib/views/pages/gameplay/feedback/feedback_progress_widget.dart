import 'package:flutter/material.dart';
import 'package:voquadro/data/voquadro_controller.dart';

class FeedbackProgressWidget extends StatefulWidget {
  const FeedbackProgressWidget({super.key, required this.activeColor});

  final Color activeColor;
  @override
  State<FeedbackProgressWidget> createState() => _FeedbackProgressWidgetState();
}

class _FeedbackProgressWidgetState extends State<FeedbackProgressWidget> {
  final voquadroController = VoquadroController.instance;
  @override
  void initState() {
    super.initState();
    voquadroController.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    voquadroController.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        bool isActive = index == voquadroController.feedbackState.index;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 60,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? widget.activeColor : Colors.white,
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
