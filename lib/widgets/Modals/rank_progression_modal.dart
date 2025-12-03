import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';

class RankProgressionModal extends StatefulWidget {
  final int currentLevel;

  const RankProgressionModal({super.key, required this.currentLevel});

  @override
  State<RankProgressionModal> createState() => _RankProgressionModalState();
}

class _RankProgressionModalState extends State<RankProgressionModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  final List<Map<String, dynamic>> _ranks = const [
    {
      'name': 'Novice',
      'range': 'Lvl 1 - 9',
      'minLevel': 1,
      'asset': 'assets/rank_emblem_assets/novice.png',
      'color': '#8D6E63', // Brownish
    },
    {
      'name': 'Communicator',
      'range': 'Lvl 10 - 24',
      'minLevel': 10,
      'asset': 'assets/rank_emblem_assets/communicator.png',
      'color': '#78909C', // Blue Grey
    },
    {
      'name': 'Adept',
      'range': 'Lvl 25 - 49',
      'minLevel': 25,
      'asset': 'assets/rank_emblem_assets/adept.png',
      'color': '#FFB74D', // Orange/Gold
    },
    {
      'name': 'Orator',
      'range': 'Lvl 50 - 79',
      'minLevel': 50,
      'asset': 'assets/rank_emblem_assets/orator.png',
      'color': '#26A69A', // Teal
    },
    {
      'name': 'Virtuoso',
      'range': 'Lvl 80+',
      'minLevel': 80,
      'asset': 'assets/rank_emblem_assets/virtuoso.png',
      'color': '#AB47BC', // Purple
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color purpleDark = "#49416D".toColor();
    final Color bg = "#F7F3FB".toColor();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.only(top: 16, bottom: 24),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Rank Progression",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: purpleDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Unlock new emblems as you level up!",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: purpleDark.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: purpleDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              itemCount: _ranks.length,
              itemBuilder: (context, index) {
                final rank = _ranks[index];
                final bool isUnlocked = widget.currentLevel >= rank['minLevel'];
                final bool isNext =
                    !isUnlocked &&
                    (index == 0 ||
                        widget.currentLevel >= _ranks[index - 1]['minLevel']);
                
                // Determine if this is the user's CURRENT rank
                // It is current if unlocked AND (it's the last one OR the next one is locked)
                final bool isCurrent = isUnlocked && (index == _ranks.length - 1 || widget.currentLevel < _ranks[index + 1]['minLevel']);

                return AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    final double start = index * 0.1;
                    final double end = start + 0.4;
                    final curve = CurvedAnimation(
                      parent: _controller,
                      curve: Interval(
                        start.clamp(0.0, 1.0),
                        end.clamp(0.0, 1.0),
                        curve: Curves.easeOutBack,
                      ),
                    );

                    return Transform.translate(
                      offset: Offset(0, 50 * (1 - curve.value)),
                      child: Opacity(
                        opacity: curve.value.clamp(0.0, 1.0),
                        child: _buildRankCard(
                          rank,
                          isUnlocked,
                          isCurrent,
                          isNext,
                          purpleDark,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankCard(
    Map<String, dynamic> rank,
    bool isUnlocked,
    bool isCurrent,
    bool isNext,
    Color titleColor,
  ) {
    final Color cardColor = isUnlocked
        ? Colors.white
        : Colors.white.withValues(alpha: 0.5);
    final double elevation = isCurrent ? 8 : 2;
    final Color borderColor = isCurrent
        ? const Color(0xFF00E5FF)
        : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: isCurrent ? 2 : 0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: elevation * 2,
            offset: Offset(0, elevation),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Emblem
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked
                    ? (rank['color'] as String).toColor().withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
              ),
              child: ClipOval(
                child: ColorFiltered(
                  colorFilter: isUnlocked
                      ? const ColorFilter.mode(
                          Colors.transparent,
                          BlendMode.multiply,
                        )
                      : const ColorFilter.mode(
                          Colors.grey,
                          BlendMode.saturation,
                        ),
                  child: Image.asset(
                    rank['asset'],
                    fit: BoxFit.cover,
                    errorBuilder:
                        (c, e, s) => Icon(
                          Icons.shield,
                          size: 30,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        rank['name'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isUnlocked
                              ? titleColor
                              : titleColor.withValues(alpha: 0.5),
                        ),
                      ),
                      if (isCurrent) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00E5FF).withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            "CURRENT",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00B8D4),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    rank['range'],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isUnlocked
                          ? titleColor.withValues(alpha: 0.6)
                          : titleColor.withValues(alpha: 0.3),
                    ),
                  ),
                  if (isNext) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Reach Level ${rank['minLevel']} to unlock",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Lock Icon
            if (!isUnlocked)
              Icon(
                Icons.lock_rounded,
                color: titleColor.withValues(alpha: 0.2),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }
}
