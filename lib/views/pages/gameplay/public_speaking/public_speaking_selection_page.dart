import 'package:flutter/material.dart';
import 'package:voquadro/data/notifiers.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/mode_page.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/status_page.dart';
import 'package:voquadro/views/widgets/navbar_mode.dart';

List<Widget> pages = [ModePage(), PublicSpeakingStatusPage()];
class PublicSpeakingSelectionPage extends StatefulWidget {
  const PublicSpeakingSelectionPage({super.key});

  @override
  State<PublicSpeakingSelectionPage> createState() => _PublicSpeakingSelectionPageState();
}
class _PublicSpeakingSelectionPageState extends State<PublicSpeakingSelectionPage> {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Public Speaking Mode'),
        centerTitle: true,
      ),
      bottomNavigationBar: NavbarMode(statusPage: PublicSpeakingStatusPage(),),
      body: ValueListenableBuilder(valueListenable: publicModeSelectedNotifier, builder: (context, value, child) {
        return pages.elementAt(value);
      },),
    );
  }
}
