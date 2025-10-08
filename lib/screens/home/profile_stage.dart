import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voquadro/widgets/Profile/profile_edit_sheet.dart';
import 'package:voquadro/widgets/Profile/profile_template.dart';

class ProfileStage extends StatefulWidget {
  const ProfileStage({super.key});

  @override
  State<ProfileStage> createState() => _ProfileStageState();
}

class _ProfileStageState extends State<ProfileStage> {
  String username = 'Adolp';
  int level = 25;
  int masteryLevel = 69;
  int publicSpeakingLevel = 69;
  int highestStreak = 23;

  String bio = 'Write your bio here...';

  String bannerPath = 'assets/images/bg.jpg';
  String avatarPath = 'assets/images/tempCharacter.png';

  @override
  Widget build(BuildContext context) {
    final stats = [
      StatTileData(
        icon: Icons.school,
        label: 'Mastery Level',
        value: 'lvl$masteryLevel',
      ),
      StatTileData(
        icon: Icons.spatial_audio_off,
        label: 'Public Speaking Level',
        value: 'lvl$publicSpeakingLevel',
      ),
      StatTileData(
        icon: Icons.local_fire_department,
        label: 'Highest Streak',
        value: '$highestStreak',
      ),
    ];

    return ProfileTemplate(
      username: username,
      level: level,
      bio: bio,
      bannerImage: AssetImage(bannerPath),
      avatarImage: AssetImage(avatarPath),
      stats: stats,
      onBack: () => Navigator.of(context).maybePop(),
      onEdit: _openEditSheet,
    );
  }

  Widget _buildProfileCard(
    BuildContext context,
    Color cardBg,
    Color titleColor,
  ) {
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
                const SizedBox(height: 10),
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
                      child: _statTile(
                        icon: Icons.school,
                        label: 'Mastery Level',
                        value: 'lvl$masteryLevel',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statTile(
                        icon: Icons.spatial_audio_off,
                        label: 'Public Speaking Level',
                        value: 'lvl$publicSpeakingLevel',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statTile(
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

          // Avatar
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
                        image: AssetImage(avatarPath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Rank emblem placeholder
                  Positioned(
                    right: -10,
                    bottom: 2,
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

  Widget _statTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
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

  Widget _buildBioCard(Color cardBg, Color titleColor) {
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
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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

  Widget _roundIconButton({
    required IconData icon,
    required Color background,
    required VoidCallback onPressed,
  }) {
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

  void _openEditSheet() {
    final TextEditingController bioController = TextEditingController(
      text: bio,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: 'F0E6F6'.toColor(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ProfileEditSheet(
          initialBio: bio,
          onPickAvatar: _pickAvatar,
          onPickBanner: _pickBanner,
          onSaveBio: (newBio) {
            setState(() {
              bio = newBio.isEmpty ? 'Write your bio here...' : newBio;
            });
          },
        );
      },
    );
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
    );
    if (result == null) return;
    setState(() {
      avatarPath = result.path;
    });
  }

  Future<void> _pickBanner() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
    );
    if (result == null) return;
    setState(() {
      bannerPath = result.path;
    });
  }
}
