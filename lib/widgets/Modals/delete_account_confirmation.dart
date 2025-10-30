import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';

class DeleteConfirmationDialog extends StatefulWidget {
  const DeleteConfirmationDialog({super.key});

  @override
  State<DeleteConfirmationDialog> createState() =>
      _DeleteConfirmationDialogState();
}

class _DeleteConfirmationDialogState extends State<DeleteConfirmationDialog> {
  int _confirmationStep = 1;

  void _showNextConfirmation() {
    if (_confirmationStep < 3) {
      setState(() {
        _confirmationStep++;
      });
    } else {
      _handleFinalDeletion();
    }
  }

  void _handleFinalDeletion() {
    debugPrint('Account deletion requested - implement actual deletion logic');
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Account deletion functionality coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getConfirmationText() {
    switch (_confirmationStep) {
      case 1:
        return 'Are you sure you want to\ndelete your account?';
      case 2:
        return 'This action cannot be\nundone. Continue?';
      case 3:
        return 'Seriously?';
      default:
        return 'Are you sure?';
    }
  }

  String _getConfirmButtonText() {
    switch (_confirmationStep) {
      case 1:
        return 'Yes, Delete';
      case 2:
        return 'Continue';
      case 3:
        return 'YES.';
      default:
        return 'Yes';
    }
  }

  String _getCancelButtonText() {
    switch (_confirmationStep) {
      case 1:
        return 'No, Keep';
      case 2:
        return 'Go Back';
      case 3:
        return 'Cancel';
      default:
        return 'No';
    }
  }

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
              _getConfirmationText(),
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
                    onPressed: _showNextConfirmation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _confirmationStep == 3
                          ? Colors.red
                          : purpleMid,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      _getConfirmButtonText(),
                      style: const TextStyle(
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
                      _getCancelButtonText(),
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
