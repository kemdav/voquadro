import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';

/// ProfileTemplate
/// Reusable, presentational widget that renders the profile UI used across
/// modes. This widget is intentionally dumb: it receives already-prepared
/// values and images (AssetImage/NetworkImage/FileImage) and renders them.
///
/// Extend by:
/// - Passing different `stats` per mode via [StatTileData]
/// - Supplying different [ImageProvider] types as data sources change
/// - Wiring [onEdit] to open a profile editor or a route

/// Simple value object for a single stat tile on the header card.

class ProfileActions extends StatelessWidget {
  const ProfileActions({super.key, this.onBack, this.onEdit});

  final VoidCallback? onBack;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 60.0;
    const double topMargin = 16.0;

    return Positioned(
      top: topMargin,
      left: 20,
      right: 20,
      height: buttonSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Back Button
          IconButton.filled(
            onPressed:
                onBack ??
                () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
            icon: const Icon(Icons.arrow_back),
            iconSize: 40,
            style: IconButton.styleFrom(
              backgroundColor: "7962A5".toColor(),
              foregroundColor: Colors.white,
            ),
          ),

          // Edit Button
          IconButton.filled(
            onPressed: onEdit,
            icon: const Icon(Icons.edit),
            iconSize: 40,
            style: IconButton.styleFrom(
              backgroundColor: "7962A5".toColor(),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class StatTileData {
  const StatTileData({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;
}

class ProfileTemplate extends StatelessWidget {
  const ProfileTemplate({
    super.key,
    required this.username,
    required this.level,
    required this.bio,
    this.bannerImage,
    required this.avatarImage,
    this.badge,
    this.onTapAvatar,
    this.onTapBanner,
    this.onEdit,
    this.onBack,
    this.stats,
  });

  /// Display name of the user
  final String username;

  /// Overall user level (displayed next to the name)
  final int level;

  /// Bio text rendered in the lower card
  final String bio;

  /// Banner and avatar accept any ImageProvider (Asset/Network/File)
  /// If [bannerImage] is null, a default app background is used.
  final ImageProvider? bannerImage;
  final ImageProvider avatarImage;

  /// Optional badge widget shown on the avatar (e.g., rank/emblem)
  final Widget? badge;

  /// Optional tap handlers for avatar and banner
  final VoidCallback? onTapAvatar;
  final VoidCallback? onTapBanner;

  final VoidCallback? onEdit;
  final VoidCallback? onBack;

  /// Optional list of stats. If null/empty, a default placeholder set is used.
  final List<StatTileData>? stats; // if null, a default set will be built

  @override
  Widget build(BuildContext context) {
    final Color purpleDark = '49416D'.toColor();
    final Color purpleMid = '7962A5'.toColor();
    const Color cardBg = Color(0xFFF0E6F6);
    const Color pageBg = Color(0xFFF7F3FB);

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              top: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: InkWell(
                  onTap: onTapBanner,
                  child: Container(
                    height: 220,
                    decoration: BoxDecoration(
                      color: purpleMid,
                      image: DecorationImage(
                        image:
                            bannerImage ??
                            const AssetImage('assets/images/defaultbg.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 140, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _ProfileHeaderCard(
                        username: username,
                        level: level,
                        stats: stats,
                        titleColor: purpleDark,
                        cardBg: cardBg,
                        avatarImage: avatarImage,
                        badge: badge,
                        onTapAvatar: onTapAvatar,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _BioCard(
                        bio: bio,
                        titleColor: purpleDark,
                        cardBg: cardBg,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ProfileActions(onBack: onBack, onEdit: onEdit),
          ],
        ),
      ),
    );
  }
}

/// Internal header card: avatar, name/level, and stat tiles.
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.username,
    required this.level,
    this.stats,
    required this.titleColor,
    required this.cardBg,
    required this.avatarImage,
    this.badge,
    this.onTapAvatar,
  });

  final String username;
  final int level;
  final List<StatTileData>? stats;
  final Color titleColor;
  final Color cardBg;
  final ImageProvider avatarImage;
  final Widget? badge;
  final VoidCallback? onTapAvatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 70, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        height: 1.0,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 8, height: 30),
                    Text(
                      'lvl$level',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    for (int i = 0; i < _effectiveStats.length; i++) ...[
                      Expanded(
                        child: _StatTile(
                          icon: _effectiveStats[i].icon,
                          label: _effectiveStats[i].label,
                          value: _effectiveStats[i].value,
                        ),
                      ),
                      if (i != _effectiveStats.length - 1)
                        const SizedBox(width: 10),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          Positioned(
            top: -56,
            left: 0,
            right: 0,
            child: Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  InkWell(
                    onTap: onTapAvatar,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        image: DecorationImage(
                          image: avatarImage,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  if (badge != null)
                    Positioned(right: -2, bottom: 8, child: badge!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// If no stats were provided, return a default placeholder set.
  List<StatTileData> get _effectiveStats {
    if (stats != null && stats!.isNotEmpty) return stats!;
    return const [
      StatTileData(icon: Icons.school, label: 'Mastery Level', value: 'lvl—'),
      StatTileData(
        icon: Icons.spatial_audio_off,
        label: 'Public Speaking Level',
        value: 'lvl—',
      ),
      StatTileData(
        icon: Icons.local_fire_department,
        label: 'Highest Streak',
        value: '—',
      ),
    ];
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: '6C53A1'.toColor(), size: 30),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: '6C53A1'.toColor(),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: '6C53A1'.toColor(),
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BioCard extends StatelessWidget {
  const _BioCard({
    required this.bio,
    required this.titleColor,
    required this.cardBg,
  });

  final String bio;
  final Color titleColor;
  final Color cardBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Bio:',
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.015),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.transparent),
              ),
              child: Text(
                bio,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.4,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
/*
HOW TO USE THIS WIDGET ELSEWHERE (configurable stats per mode):

final stats = [
  StatTileData(icon: Icons.school, label: 'Mastery Level', value: 'lvl${user.masteryLevel}'),
  StatTileData(icon: Icons.spatial_audio_off, label: 'Public Speaking Level', value: 'lvl${user.psLevel}'),
  StatTileData(icon: Icons.local_fire_department, label: 'Highest Streak', value: '${user.highestStreak}'),
];

return ProfileTemplate(
  username: user.username,
  level: user.level,
  bio: user.bio,
  bannerImage: NetworkImage(user.bannerUrl),  // swap in once DB ready
  avatarImage: NetworkImage(user.avatarUrl),  // swap in once DB ready
  badge: YourBadgeWidget(), // optional, pass only if you want to show a badge
  stats: stats, // pass any set of StatTileData for the current mode
  onBack: () => Navigator.of(context).maybePop(),
  onEdit: () { /* open edit UI or navigate to profile editor */ },
);
*/