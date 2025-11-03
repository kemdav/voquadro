import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/src/helper-class/progression_conversion_helper.dart';
import 'package:voquadro/widgets/Widget/customer_progress_bar.dart';

class ProgressionPage extends StatelessWidget {
  const ProgressionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final publicSpeakingController = context.watch<PublicSpeakingController>();
    final sessionController = context.watch<AppFlowController>();

    final result = publicSpeakingController.sessionResult;
    final user = sessionController.currentUser;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (result == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final publicLevelInfo = ProggressionConversionHelper.getLevelProgressInfo(user.publicSpeakingEXP);

    final paceControlInfo = ProggressionConversionHelper.getLevelProgressInfo(user.paceControlEXP);

    final fillerWordInfo = ProggressionConversionHelper.getLevelProgressInfo(user.fillerControlEXP);

    // --- Define Colors from the Design ---
    final Color primaryPurple = const Color(0xFF322082);
    final Color progressTeal = const Color(0xFF00A9A5);
    final Color pageBackground = const Color(0xFFF0E6F6);

    return Scaffold(
      backgroundColor: pageBackground,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text("Mastery LVL"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomProgressBar(
                    title: 'Pace Control ${paceControlInfo.level}',
                    valueText: '${paceControlInfo.currentLevelExp}/${paceControlInfo.cumulativeExpForNextLevel}',
                    xpGainText: '+${result.paceControlEXP.toInt()} MXP',
                    progress: paceControlInfo.progressPercentage,
                    progressColor: progressTeal,
                    textColor: primaryPurple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomProgressBar(
                    title: 'Filler Word Control ${fillerWordInfo.level}',
                    valueText: '${fillerWordInfo.currentLevelExp}/${fillerWordInfo.cumulativeExpForNextLevel}',
                    xpGainText: '+${result.fillerControlEXP.toInt()} MXP',
                    progress: fillerWordInfo.progressPercentage,
                    progressColor: progressTeal,
                    textColor: primaryPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Public Speaking Level Bar ---
            CustomProgressBar(
              title: 'Public Speaking lvl ${publicLevelInfo.level}',
              valueText:
                  '${publicLevelInfo.currentLevelExp}/${publicLevelInfo.cumulativeExpForNextLevel}',
              xpGainText: '+${result.modeEXP.toInt()} Public XP',
              progress: publicLevelInfo.progressPercentage,
              progressColor: progressTeal,
              textColor: primaryPurple,
            ),
            const SizedBox(height: 40),

            // --- Rank Logo ---
            Stack(
              alignment: Alignment.center,
              children: [
                const CircleAvatar(
                  radius: 80,
                  backgroundColor: Color(0xFF6C6C6C),
                  child: Text(
                    'nxt\nrank\nlogo',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ),
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: publicLevelInfo.progressPercentage,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade400,
                    valueColor: AlwaysStoppedAnimation<Color>(progressTeal),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Text(
                    '+${result.practiceEXP.toInt()}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- Speaker Level Text ---
            Text(
              'Speaker Level',
              style: TextStyle(
                color: primaryPurple,
                fontSize: 48,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
