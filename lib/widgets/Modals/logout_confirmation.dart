import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';

class LogoutConfirmationModal extends StatelessWidget {
  const LogoutConfirmationModal({super.key});

  @override
  Widget build(BuildContext context) {
    final Color purpleDark = '49416D'.toColor();
    final Color purpleMid = '7962A5'.toColor();
    const Color dialogBg = Color(0xFFF7F3FB);
    const Color noButtonBg = Color(0xFFF0E6F6);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: dialogBg,
          borderRadius: BorderRadius.circular(20.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26),
              spreadRadius: 5,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to log out?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: purpleDark,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                      context.read<AppFlowController>().logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: purpleMid,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: noButtonBg,
                      foregroundColor: purpleMid,
                      side: BorderSide(color: Colors.grey.shade300, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'No',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: purpleDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
