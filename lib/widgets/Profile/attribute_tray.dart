import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:voquadro/src/models/attribute_stat_option.dart';

class AttributeTray extends StatelessWidget {
  final List<AttributeStatOption> stats;
  final int maxSlots;
  final VoidCallback? onAddPressed;

  const AttributeTray({
    super.key,
    required this.stats,
    this.maxSlots = 3, // Default to 3 slots as per typical UI patterns
    this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Generate the list of items to display (Stats + Empty Slots)
    List<Widget> cards = [];

    for (int i = 0; i < maxSlots; i++) {
      if (i < stats.length) {
        // Render Filled Card
        cards.add(
          Expanded(child: _AttributeCard(stat: stats[i], isEmpty: false)),
        );
      } else {
        // Render Empty Placeholder
        cards.add(
          Expanded(child: _AttributeCard(isEmpty: true, onTap: onAddPressed)),
        );
      }

      // Add spacing between cards, but not after the last one
      if (i < maxSlots - 1) {
        cards.add(const SizedBox(width: 12));
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: cards,
      ),
    );
  }
}

// ignore: must_be_immutable
class _AttributeCard extends StatelessWidget {
  final AttributeStatOption? stat;
  final bool isEmpty;
  final VoidCallback? onTap;

  _AttributeCard({this.stat, required this.isEmpty, this.onTap});

  @override
  Widget build(BuildContext context) {
    // Design System constants (mimicking profile_template.dart style)
    final borderRadius = BorderRadius.circular(16);
    // Light grey background for the card
    const Color cardColor = Color(0xFFF5F5F5);
    const Color borderColor = Color(0xFFE0E0E0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110, // Fixed height for consistency
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: borderRadius,
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isEmpty ? _buildEmptyState() : _buildFilledState(),
      ),
    );
  }

  Color emptyCardColor = Color.fromARGB(255, 35, 2, 44);

  Widget _buildEmptyState() {
    return Center(
      child: SvgPicture.asset(
        'assets/profile_assets/plus.svg', //
        width: 32,
        height: 32,
        colorFilter: ColorFilter.mode(emptyCardColor, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildFilledState() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          if (stat != null)
            SvgPicture.asset(stat!.assetPath, width: 28, height: 28),
          const SizedBox(height: 8),

          // Value
          Text(
            stat!.value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 4),

          // Label
          Text(
            stat!.name,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
