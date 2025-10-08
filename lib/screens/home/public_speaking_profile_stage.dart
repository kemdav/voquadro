import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/widgets/Profile/profile_edit_sheet.dart';
import 'package:voquadro/widgets/Profile/profile_template.dart';

/// PublicSpeakingProfileStage
/// Screen tailored for the Public Speaking mode.
///
/// It composes the reusable `ProfileTemplate` and injects Public Speaking
/// specific stats via `stats` (e.g., Public Speaking Level, Highest Streak).
class PublicSpeakingProfileStage extends StatefulWidget {
  const PublicSpeakingProfileStage({super.key});

  @override
  State<PublicSpeakingProfileStage> createState() => _PublicSpeakingProfileStageState();
}

class _PublicSpeakingProfileStageState extends State<PublicSpeakingProfileStage> {
  // Placeholder/user-provided values; will be wired to DB later.
  String username = 'Adolp';
  int level = 25;
  int masteryLevel = 69; // kept to show cross-mode stat alongside Public Speaking
  int publicSpeakingLevel = 69; // Public Speaking specific stat
  int highestStreak = 23; // Public Speaking specific stat

  String bio = 'Write your bio here...';

  String bannerPath = 'assets/images/bg.jpg';
  String avatarPath = 'assets/images/tempCharacter.png';

  @override
  Widget build(BuildContext context) {
    // Public Speaking specific configuration: customize which stats to show.
    final stats = [
      StatTileData(
        icon: Icons.school,
        label: 'Mastery Level',
        value: 'lvl$masteryLevel',
      ),
      StatTileData(
        icon: Icons.spatial_audio_off,
        label: 'Public Speaking Level', // PS-specific
        value: 'lvl$publicSpeakingLevel',
      ),
      StatTileData(
        icon: Icons.local_fire_department,
        label: 'Highest Streak', // PS-specific
        value: '$highestStreak',
      ),
    ];

    return ProfileTemplate(
      // Using `ProfileTemplate` as a reusable base; only data is PS-specific.
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

  void _openEditSheet() {
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
    final result = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (result == null) return;
    setState(() {
      avatarPath = result.path;
    });
  }

  Future<void> _pickBanner() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(source: ImageSource.gallery, maxWidth: 2048);
    if (result == null) return;
    setState(() {
      bannerPath = result.path;
    });
  }
}


