import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/data/notifiers.dart';
import 'package:voquadro/theme/voquadro_colors.dart';

class ModeSelectionModal extends StatelessWidget {
  const ModeSelectionModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: VoquadroColors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: VoquadroColors.grey300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Select Mode',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
            ),
          ),
          const SizedBox(height: 16),
          ValueListenableBuilder<int>(
            valueListenable: publicModeSelectedNotifier,
            builder: (context, selectedMode, _) {
              return Column(
                children: [
                  _buildModeTile(
                    context,
                    index: 0,
                    title: 'Public Speaking',
                    description: 'Practice your speech with Dolph',
                    icon: Icons.record_voice_over_rounded,
                    isSelected: selectedMode == 0,
                    color: VoquadroColors.primaryAction,
                  ),
                  const SizedBox(height: 12),
                  _buildModeTile(
                    context,
                    index: 1,
                    title: 'Interview Mode',
                    description: 'Prepare for your next job interview',
                    icon: Icons.business_center_rounded,
                    isSelected: selectedMode == 1,
                    color: VoquadroColors.interviewSecondary,
                  ),
                  // Add more modes here in the future
                ],
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildModeTile(
    BuildContext context, {
    required int index,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        publicModeSelectedNotifier.value = index;
        
        final appFlow = context.read<AppFlowController>();
        if (index == 0) {
          appFlow.selectMode(AppMode.publicSpeaking);
        } else if (index == 1) {
          appFlow.selectMode(AppMode.interviewMode);
        }
        
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? color.withValues(alpha: 0.1)
                  : VoquadroColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : VoquadroColors.grey300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? color : color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? VoquadroColors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : VoquadroColors.black,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: VoquadroColors.grey600,
                      fontFamily: 'Nunito',
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
