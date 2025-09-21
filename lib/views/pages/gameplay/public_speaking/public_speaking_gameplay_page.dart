import 'package:flutter/material.dart';
import 'package:voquadro/data/voquadro_controller.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/gameplay/readying_prompt_page.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/gameplay/speaking_page.dart';

class PublicSpeakingGameplayPage extends StatefulWidget {
  const PublicSpeakingGameplayPage({super.key});

  @override
  State<PublicSpeakingGameplayPage> createState() => _PublicSpeakingGameplayPageState();
}

class _PublicSpeakingGameplayPageState extends State<PublicSpeakingGameplayPage> {
     final voquadroController = VoquadroController.instance;
  @override
  void initState(){
    super.initState();
    voquadroController.addListener(_onStateChanged);
  }

  @override
  void dispose(){
    voquadroController.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged(){
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    switch (voquadroController.voquadroState){
      case VoquadroState.idle:
        return ReadyingPromptPage();
      case VoquadroState.ready:
        return ReadyingPromptPage();
      case VoquadroState.speaking:
        return SpeakingPage();
    }
  }
}
