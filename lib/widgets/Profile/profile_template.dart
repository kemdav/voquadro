import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';

class ProfileTemplate extends StatelessWidget {
  const ProfileTemplate({
    super.key,
    required this.username,
    required this.level,
    required this.masteryLevel,
    required this.publicSpeakingLevel,
    required this.highestStreak,
    required this.bio,
    required this.bannerImage,
    required this.avatarImage,
    this.onEdit,
    this.onBack,
  });

  final String username;
  final int level;
  final int masteryLevel;
  final int publicSpeakingLevel;
  final int highestStreak;
  final String bio;

  /// Supports either AssetImage or NetworkImage in future DB integration
  final ImageProvider bannerImage;
  final ImageProvider avatarImage;

  final VoidCallback? onEdit;
  final VoidCallback? onBack;

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
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: purpleMid,
                    image: DecorationImage(
                      image: bannerImage,
                      fit: BoxFit.cover,
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
                        masteryLevel: masteryLevel,
                        publicSpeakingLevel: publicSpeakingLevel,
                        highestStreak: highestStreak,
                        titleColor: purpleDark,
                        cardBg: cardBg,
                        avatarImage: avatarImage,
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

            Positioned(
              top: 16,
              left: 16,
              child: _RoundIconButton(
                icon: Icons.arrow_back,
                background: purpleMid,
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              ),
            ),

            Positioned(
              top: 16,
              right: 16,
              child: _RoundIconButton(
                icon: Icons.edit,
                background: purpleMid,
                onPressed: onEdit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.username,
    required this.level,
    required this.masteryLevel,
    required this.publicSpeakingLevel,
    required this.highestStreak,
    required this.titleColor,
    required this.cardBg,
    required this.avatarImage,
  });

  final String username;
  final int level;
  final int masteryLevel;
  final int publicSpeakingLevel;
  final int highestStreak;
  final Color titleColor;
  final Color cardBg;
  final ImageProvider avatarImage;

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
                    Expanded(
                      child: _StatTile(
                        icon: Icons.school,
                        label: 'Mastery Level',
                        value: 'lvl$masteryLevel',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.spatial_audio_off,
                        label: 'Public Speaking Level',
                        value: 'lvl$publicSpeakingLevel',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.local_fire_department,
                        label: 'Highest Streak',
                        value: '$highestStreak',
                      ),
                    ),
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
                  Container(
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
                  Positioned(
                    //placeholder btw
                    right: -2,
                    bottom: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Rank\nEmblem',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.background,
    required this.onPressed,
  });

  final IconData icon;
  final Color background;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onPressed,
        child: Ink(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
/*
HOW TO USE THIS WIDGET ELSEWHERE:

return ProfileTemplate(
  username: user.username,
  level: user.level,
  masteryLevel: user.masteryLevel,
  publicSpeakingLevel: user.psLevel,
  highestStreak: user.highestStreak,
  bio: user.bio,
  bannerImage: NetworkImage(user.bannerUrl),  // swap in once DB ready
  avatarImage: NetworkImage(user.avatarUrl),  // swap in once DB ready
  onBack: () => Navigator.of(context).maybePop(),
  onEdit: () { /* open edit UI or navigate to profile editor */ },
);*/