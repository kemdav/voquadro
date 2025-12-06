import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:voquadro/data/notifiers.dart';
import 'package:voquadro/theme/voquadro_colors.dart';

var logger = Logger();

class AppBarGeneral extends StatelessWidget {
  const AppBarGeneral({super.key, required this.actionButtons});

  final Widget actionButtons;

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;
    final double visibleBarHeight = 80.0 + topPadding;
    const double buttonOverflow = 20.0;

    final double totalWidgetHeight = visibleBarHeight + buttonOverflow;

    return SizedBox(
      height: totalWidgetHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: visibleBarHeight,
            child: ValueListenableBuilder<int>(
              valueListenable: publicModeSelectedNotifier,
              builder: (context, mode, _) {
                return Container(
                  decoration: BoxDecoration(
                    color:
                        mode == 1
                            ? VoquadroColors.interviewPrimary
                            : VoquadroColors.publicSpeakingPrimary,
                    boxShadow: [
                      BoxShadow(
                        color: VoquadroColors.shadowColor,
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Mode Indicator (Top Center)
                      Positioned(
                        top: topPadding + 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              mode == 1
                                  ? Icons.business_center_rounded
                                  : Icons.record_voice_over_rounded,
                              color: VoquadroColors.white.withValues(
                                alpha: 0.5,
                              ),
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              mode == 1 ? "INTERVIEW MODE" : "PUBLIC SPEAKING",
                              style: TextStyle(
                                color: VoquadroColors.white.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                fontFamily: 'Nunito',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          actionButtons,
        ],
      ),
    );
  }
}
