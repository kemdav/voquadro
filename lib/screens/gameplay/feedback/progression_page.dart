import 'package:flutter/material.dart';
import 'package:voquadro/widgets/Widget/customer_progress_bar.dart';
class ProgressionPage extends StatelessWidget {
  const ProgressionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // --------------------------------------------------------------------------
    // --- TODO: SECTION 1 - REPLACE THIS DUMMY DATA ---
    // --------------------------------------------------------------------------
    // When you're ready, delete this entire section and uncomment the
    // provider lines below to get live data.

    // --- Dummy Session Result Data ---
    // This simulates the `sessionResult` from the PublicSpeakingController.
    final dummySessionResult = {
      'practiceEXP': 55.0,
      'masteryEXP': 16.0,
      'paceControlEXP': 12.0,
      'fillerControlEXP': 10.0,
      'modeEXP': 10.0,
    };

    // --- Dummy User Data (Before the session) ---
    // This simulates the data from the UserSessionController.
    final dummyUser = {
      'practiceXp': 69 - 55, // 14
      'masteryXp': 107 - 16, // 91
      'paceControlPTS': 80 - 12, // 68
      'fillerControlPTS': 20 - 10, // 10
      'publicSpeakingXp': 69 - 10, // 59
    };
    
    // --- Dummy Level Calculation ---
    // This simulates the `userLevel` getter from the UserSessionController.
    final int currentTotalPracticeXp = 69;
    final int nextLevelTarget = 200;
    final double practiceProgress = currentTotalPracticeXp / nextLevelTarget;

    // --------------------------------------------------------------------------
    // --- END OF DUMMY DATA SECTION ---
    // --------------------------------------------------------------------------


    // TODO: SECTION 2 - UNCOMMENT TO USE REAL DATA
    // final publicSpeakingController = context.watch<PublicSpeakingController>();
    // final sessionController = context.watch<UserSessionController>();
    //
    // final result = publicSpeakingController.sessionResult;
    // final user = sessionController.currentUser;
    // final levelInfo = sessionController.userLevel;
    //
    // if (result == null || user == null) {
    //   return const Center(child: CircularProgressIndicator());
    // }


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
            // --- Practice Level Bar ---
            CustomProgressBar(
              title: 'Practice lvl',
              // TODO: Replace dummy data with real data
              // valueText: '${levelInfo.currentLevelXp}/${levelInfo.nextLevelXp}',
              // xpGainText: '+${result.practiceEXP.toInt()} PXP',
              // progress: levelInfo.progress,
              valueText: '$currentTotalPracticeXp/$nextLevelTarget',
              xpGainText: '+${dummySessionResult['practiceEXP']!.toInt()} PXP',
              progress: practiceProgress,
              progressColor: progressTeal,
              textColor: primaryPurple,
            ),
            const SizedBox(height: 24),

            // --- Mastery Level Bars ---
            CustomProgressBar(
              title: 'Mastery lvl',
              // TODO: Replace dummy data with real data
              // valueText: '${user.masterXp}/${200}', 
              // xpGainText: '+${result.masteryEXP.toInt()} MXP',
              // progress: user.masterXp / 200,
              valueText: '${dummyUser['masteryXp']! + dummySessionResult['masteryEXP']!.toInt()}/200',
              xpGainText: '+${dummySessionResult['masteryEXP']!.toInt()} MXP',
              progress: (dummyUser['masteryXp']! + dummySessionResult['masteryEXP']!.toInt()) / 200,
              progressColor: progressTeal,
              textColor: primaryPurple,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: CustomProgressBar(
                    title: 'Pace Control',
                    valueText: '',
                    // TODO: Replace dummy data with real data
                    // xpGainText: '+${result.paceControlEXP.toInt()} MXP',
                    // progress: user.paceControlPTS / 100,
                    xpGainText: '+${dummySessionResult['paceControlEXP']!.toInt()} MXP',
                    progress: (dummyUser['paceControlPTS']! + dummySessionResult['paceControlEXP']!.toInt()) / 100,
                    progressColor: progressTeal,
                    textColor: primaryPurple,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomProgressBar(
                    title: 'Filler Word Control',
                    valueText: '',
                    // TODO: Replace dummy data with real data
                    // xpGainText: '+${result.fillerControlEXP.toInt()} MXP',
                    // progress: user.fillerControlPTS / 100,
                    xpGainText: '+${dummySessionResult['fillerControlEXP']!.toInt()} MXP',
                    progress: (dummyUser['fillerControlPTS']! + dummySessionResult['fillerControlEXP']!.toInt()) / 100,
                    progressColor: progressTeal,
                    textColor: primaryPurple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- Public Speaking Level Bar ---
            CustomProgressBar(
              title: 'Public Speaking lvl',
              // TODO: Replace dummy data with real data
              // This will require adding a publicSpeakingLevel getter to your UserSessionController
              // valueText: '${sessionController.publicSpeakingLevel.currentXp}/${sessionController.publicSpeakingLevel.nextLevelXp}',
              // xpGainText: '+${result.modeEXP.toInt()} Public XP',
              // progress: sessionController.publicSpeakingLevel.progress,
              valueText: '${dummyUser['publicSpeakingXp']! + dummySessionResult['modeEXP']!.toInt()}/200',
              xpGainText: '+${dummySessionResult['modeEXP']!.toInt()} Public XP',
              progress: (dummyUser['publicSpeakingXp']! + dummySessionResult['modeEXP']!.toInt()) / 200,
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
                  child: Text('nxt\nrank\nlogo', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 24)),
                ),
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    // TODO: Replace dummy data with real data
                    // value: levelInfo.progress,
                    value: practiceProgress,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey.shade400,
                    valueColor: AlwaysStoppedAnimation<Color>(progressTeal),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Text(
                    // TODO: Replace dummy data with real data
                    // '+${result.practiceEXP.toInt()}',
                    '+${dummySessionResult['practiceEXP']!.toInt()}',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: primaryPurple),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            
            // --- Speaker Level Text ---
            Text(
              'Speaker Level',
              style: TextStyle(color: primaryPurple, fontSize: 48, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}