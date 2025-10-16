import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/widgets/Profile/profile_edit_sheet.dart';
import 'package:voquadro/widgets/Profile/profile_template.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';

/// PublicSpeakingProfileStage
/// Screen tailored for the Public Speaking mode.
///
/// It composes the reusable `ProfileTemplate` and injects Public Speaking
/// specific stats via `stats` (e.g., Public Speaking Level, Highest Streak).
/// 
/// 
class PublicSpeakingProfileStage extends StatefulWidget {
  const PublicSpeakingProfileStage({super.key});

  @override
  State<PublicSpeakingProfileStage> createState() =>
      _PublicSpeakingProfileStageState();
}

class _PublicSpeakingProfileStageState
    extends State<PublicSpeakingProfileStage> {
  // Local-only values; will be replaced by DB values later
  String username = 'Player';
  int level = 1;
  int masteryLevel = 1;
  int publicSpeakingLevel = 1;
  int highestStreak = 0;

  String bio = 'Write your bio here...';

  // Banner uses default background image from ProfileTemplate when null
  ImageProvider avatarImage = const AssetImage(
    'assets/images/tempCharacter.png',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final flow = Provider.of<AppFlowController>(context, listen: false);
      final u = flow.currentUser;
      if (u != null && u.username.isNotEmpty) {
        setState(() {
          username = u.username;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
// FIX: The FutureBuilder now correctly expects ProfileData.
return FutureBuilder<ProfileData>(
  future: _profileDataFuture,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (snapshot.hasError) {
      return Scaffold(
        body: Center(child: Text('Error: ${snapshot.error}')),
      );
    }

    if (snapshot.hasData) {
      // FIX: The variable name is now consistent.
      final profileData = snapshot.data!;

      // cleanup hardcoded data
      final stats = [
        StatTileData(
          icon: Icons.school,
          label: 'Mastery Level',
          value: 'lvl${profileData.masteryLevel}',
        ),
        StatTileData(
          icon: Icons.spatial_audio_off,
          label: 'Public Speaking Level',
          value: 'lvl${profileData.publicSpeakingLevel}',
        ),
        StatTileData(
          icon: Icons.local_fire_department,
          label: 'Highest Streak',
          value: '${profileData.highestStreak}',
        ),
      ];

      final avatarImage =
          _localAvatarImage ??
          (profileData.avatarUrl != null
                  ? NetworkImage(profileData.avatarUrl!)
                  : const AssetImage('assets/images/tempCharacter.png'))
              as ImageProvider;

      final bannerImage =
          _localBannerImage ??
          (profileData.bannerUrl != null
                  ? NetworkImage(profileData.bannerUrl!)
                  : const AssetImage('assets/images/defaultbg.png'))
              as ImageProvider;

      return ProfileTemplate(
        username: profileData.username,
        level: profileData.level,
        bio: profileData.bio ?? 'Write your bio here...',
        bannerImage: bannerImage,
        avatarImage: avatarImage,
        stats: stats,
        // *** ADDED from feature/settings-page-ui branch ***
        onTapAvatar: _uploadAvatar,
        onTapBanner: _uploadBanner,
        // *************************************************

        onBack: () => Navigator.of(context).maybePop(),
        // NOTE: Keeping the version that passes `profileData` to `_openEditSheet` from develop.
        onEdit: () => _openEditSheet(profileData),
      );
    }

    return const Scaffold(
      body: Center(child: Text('No profile data found.')),
    );
  },
);
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
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
    );
    if (result == null) return;
    // For now preview locally; persistence to storage can be added later
    setState(() {
      avatarImage = FileImage(File(result.path));
    });
  }

  Future<void> _pickBanner() async {
    final picker = ImagePicker();
    final result = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
    );
    if (result == null) return;
    // Placeholder: when profile storage is implemented, pass picked image to template
  }

  // Placeholder: Upload new avatar to storage once DB schema is ready
  void _uploadAvatar() async {
    // Steps to implement when ready:
    // 1) Use ImagePicker to select an image file
    // 2) Call a UserService.uploadAvatar(file) that uploads to 'profile_assets' bucket
    // 3) Update the user's profile_avatar_url in DB
    // 4) Refresh local state by re-fetching or setting NetworkImage with the new URL
  }

  // Placeholder: Upload new banner to storage once DB schema is ready
  void _uploadBanner() async {
    // Steps to implement when ready:
    // 1) Use ImagePicker to select an image file
    // 2) Call a UserService.uploadBanner(file) that uploads to 'profile_assets' bucket
    // 3) Update the user's profile_banner_url in DB
    // 4) Refresh local state by re-fetching or setting NetworkImage with the new URL
  }
}
