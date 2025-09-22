import 'package:flutter/material.dart';
import 'package:voquadro/data/voquadro_controller.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/gameplay/readying_prompt_page.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/gameplay/speaking_page.dart';

class PublicSpeakingGameplayPage extends StatefulWidget {
  const PublicSpeakingGameplayPage({super.key});

  @override
  State<PublicSpeakingGameplayPage> createState() =>
      _PublicSpeakingGameplayPageState();
}

class _PublicSpeakingGameplayPageState
    extends State<PublicSpeakingGameplayPage> {
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

  int _calculateIndex() {
    switch (voquadroController.voquadroState) {
      case VoquadroState.idle:
      case VoquadroState.ready:
        return 0; // Index for ReadyingPromptPage
      case VoquadroState.speaking:
        return 1; // Index for SpeakingPage
      default:
        return 0; // Default to the first page
    }
  }

  @override
  Widget build(BuildContext context) {
    return IndexedStack(
      index: _calculateIndex(),
      children: const <Widget>[ReadyingPromptPage(), SpeakingPage()],
    );
  }
}
