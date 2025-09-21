import 'package:flutter/material.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/mode_page.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/status_page.dart';
import 'package:voquadro/views/widgets/appbar_mode.dart';
import 'package:voquadro/views/widgets/navbar_mode.dart';

List<Widget> pages = [PublicSpeakingModePage(), PublicSpeakingStatusPage()];

class PublicSpeakingSelectionPage extends StatefulWidget {
  const PublicSpeakingSelectionPage({super.key});

  @override
  State<PublicSpeakingSelectionPage> createState() =>
      _PublicSpeakingSelectionPageState();
}

class _PublicSpeakingSelectionPageState
    extends State<PublicSpeakingSelectionPage> {
  @override
  Widget build(BuildContext context) {
    const double customAppBarHeight = 80.0;
    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: customAppBarHeight),
            child: PublicSpeakingModePage(),
          ),
           Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBarMode(),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: NavbarMode(statusPage: PublicSpeakingStatusPage()),
          ),
        ],
      ),
    );
  }
}
