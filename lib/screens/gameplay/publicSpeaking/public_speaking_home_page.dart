import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';

class PublicSpeakingHomePage extends StatefulWidget {
  const PublicSpeakingHomePage({super.key});

  @override
  State<PublicSpeakingHomePage> createState() => _ModePageState();
}

class _ModePageState extends State<PublicSpeakingHomePage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: Image.asset('assets/images/dolph.png'),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AppFlowController>().selectMode(AppMode.interview);
            },
            icon: const Icon(Icons.chat),
            label: const Text('Interview Mode'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
