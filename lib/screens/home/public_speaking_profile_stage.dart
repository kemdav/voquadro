import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/widgets/Profile/profile_edit_sheet.dart';
import 'package:voquadro/widgets/Profile/profile_template.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/services/user_service.dart';

class PublicSpeakingProfileStage extends StatefulWidget {
  const PublicSpeakingProfileStage({super.key});

  @override
  State<PublicSpeakingProfileStage> createState() =>
      _PublicSpeakingProfileStageState();
}

class _PublicSpeakingProfileStageState
    extends State<PublicSpeakingProfileStage> {
  // FIX: This now correctly expects a Future of ProfileData.
  late Future<ProfileData> _profileDataFuture;
  final ImagePicker _picker = ImagePicker();

  ImageProvider? _localAvatarImage;
  ImageProvider? _localBannerImage;

  @override
  void initState() {
    super.initState();
    _profileDataFuture = _fetchProfileData();
  }

  /// Fetches the user's profile data from the UserService.
  // FIX: The return type is now Future<ProfileData> and it calls the correct service method.
  Future<ProfileData> _fetchProfileData() {
    final user = context.read<AppFlowController>().currentUser;
    if (user == null) {
      return Future.error('User not logged in. Cannot fetch profile.');
    }
    return UserService.getProfileData(user.id);
  }

  /// Call this to refetch all data from the server and rebuild the widget.
  void _refreshProfile() {
    setState(() {
      _localAvatarImage = null;
      _localBannerImage = null;
      _profileDataFuture = _fetchProfileData();
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

          // cleanup hardcoded datas
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
            onBack: () => Navigator.of(context).maybePop(),
            onEdit: () => _openEditSheet(profileData),
          );
        }

        return const Scaffold(
          body: Center(child: Text('No profile data found.')),
        );
      },
    );
  }

  /// Opens the bottom sheet for editing the profile.
  void _openEditSheet(ProfileData profileData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: 'F0E6F6'.toColor(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ProfileEditSheet(
          initialBio: profileData.bio ?? '',
          onPickAvatar: () => _handleImagePickAndUpload(
            profileData: profileData,
            isAvatar: true,
          ),
          onPickBanner: () => _handleImagePickAndUpload(
            profileData: profileData,
            isAvatar: false,
          ),
          onSaveBio: _handleBioSave,
        );
      },
    );
  }

  /// Handles saving the new bio to the database.
  Future<void> _handleBioSave(String newBio) async {
    final user = context.read<AppFlowController>().currentUser;
    if (user == null) return;

    Navigator.of(context).pop();

    try {
      await UserService.updateBio(user.id, newBio);
      _refreshProfile();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update bio: $e')));
    }
  }

  /// Handles picking an image, showing a preview, and calling the replacement service.
  Future<void> _handleImagePickAndUpload({
    required ProfileData profileData,
    required bool isAvatar,
  }) async {
    final user = context.read<AppFlowController>().currentUser;
    if (user == null) return;

    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: isAvatar ? 1024 : 2048,
    );
    if (result == null) return;

    final imageFile = File(result.path);
    final imageType = isAvatar ? 'avatar' : 'banner';
    final oldImageUrl = isAvatar
        ? profileData.avatarUrl
        : profileData.bannerUrl;

    Navigator.of(context).pop();

    setState(() {
      if (isAvatar) {
        _localAvatarImage = FileImage(imageFile);
      } else {
        _localBannerImage = FileImage(imageFile);
      }
    });

    try {
      await UserService.replaceProfileImage(
        userId: user.id,
        newImageFile: imageFile,
        imageType: imageType,
        oldImageUrl: oldImageUrl,
      );
      _refreshProfile();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update image: $e')));
      _refreshProfile();
    }
  }
}
