import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/widgets/Profile/profile_edit_sheet.dart';
import 'package:voquadro/widgets/Profile/profile_template.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/services/user_service.dart'; // CHANGE: Import the user service

class PublicSpeakingProfileStage extends StatefulWidget {
  const PublicSpeakingProfileStage({super.key});

  @override
  State<PublicSpeakingProfileStage> createState() =>
      _PublicSpeakingProfileStageState();
}

class _PublicSpeakingProfileStageState
    extends State<PublicSpeakingProfileStage> {
  // CHANGE: Instead of individual variables, we use a Future to hold our user data.
  late Future<User> _profileDataFuture;
  final ImagePicker _picker = ImagePicker();

  // CHANGE: These will hold temporary local images for instant preview after picking.
  ImageProvider? _localAvatarImage;
  ImageProvider? _localBannerImage;

  @override
  void initState() {
    super.initState();
    // CHANGE: When the widget is created, start fetching the profile data.
    _profileDataFuture = _fetchProfileData();
  }

  /// Fetches the user's profile data from the UserService.
  Future<User> _fetchProfileData() {
    final user = context.read<AppFlowController>().currentUser;
    if (user == null) {
      // This case should be rare if your app flow is correct.
      return Future.error('User not logged in. Cannot fetch profile.');
    }
    return UserService.getFullUserProfile(user.id);
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
    // CHANGE: We wrap the entire screen in a FutureBuilder.
    return FutureBuilder<User>(
      future: _profileDataFuture,
      builder: (context, snapshot) {
        // STATE 1: Data is still loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // STATE 2: An error occurred
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        // STATE 3: Data has been successfully loaded
        if (snapshot.hasData) {
          final userProfile = snapshot.data!;

          // For now, they can stay as placeholders.
          final int level = 1;
          final int masteryLevel = 5;
          final int publicSpeakingLevel = 1;
          final int highestStreak = 0;

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

          // Determine which image to show: a local preview, the network image, or the default.
          final avatarImage =
              _localAvatarImage ??
              (userProfile.profileAvatarUrl != null
                      ? NetworkImage(userProfile.profileAvatarUrl!)
                      : const AssetImage('assets/images/tempCharacter.png'))
                  as ImageProvider;

          final bannerImage =
              _localBannerImage ??
              (userProfile.profileBannerUrl != null
                      ? NetworkImage(userProfile.profileBannerUrl!)
                      : const AssetImage('assets/images/defaultbg.png'))
                  as ImageProvider;

          return ProfileTemplate(
            username: userProfile.username,
            level: level, // Using placeholder level
            bio: userProfile.bio ?? 'Write your bio here...',
            bannerImage: bannerImage,
            avatarImage: avatarImage,
            stats: stats,
            onBack: () => Navigator.of(context).maybePop(),
            onEdit: () => _openEditSheet(userProfile.bio ?? ''),
            // onTapAvatar and onTapBanner are now handled by the edit sheet
          );
        }

        // Fallback state
        return const Scaffold(
          body: Center(child: Text('No profile data found.')),
        );
      },
    );
  }

  void _openEditSheet(String currentBio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: 'F0E6F6'.toColor(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ProfileEditSheet(
          initialBio: currentBio,
          // CHANGE: Connect buttons to the new handler methods
          onPickAvatar: () => _handleImagePickAndUpload(isAvatar: true),
          onPickBanner: () => _handleImagePickAndUpload(isAvatar: false),
          onSaveBio: _handleBioSave,
        );
      },
    );
  }

  /// Handles saving the new bio to the database.
  Future<void> _handleBioSave(String newBio) async {
    final user = context.read<AppFlowController>().currentUser;
    if (user == null) return;

    // Close the bottom sheet
    Navigator.of(context).pop();

    try {
      await UserService.updateBio(user.id, newBio);
      _refreshProfile(); // Refetch data to show the update
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update bio: $e')));
    }
  }

  /// Handles picking an image from the gallery and uploading it.
  Future<void> _handleImagePickAndUpload({required bool isAvatar}) async {
    final user = context.read<AppFlowController>().currentUser;
    if (user == null) {
      print('DEBUG: FAILED! User is null, cannot upload image.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: You are not logged in!')),
      );
      return;
    }
    print('DEBUG: User ID is: ${user.id}');

    // 1. Pick the image
    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: isAvatar ? 1024 : 2048,
    );
    if (result == null) return;

    final imageFile = File(result.path);
    final imageType = isAvatar ? 'avatar' : 'banner';

    // Close the bottom sheet
    Navigator.of(context).pop();

    // 2. Set local state for an instant preview
    setState(() {
      if (isAvatar) {
        _localAvatarImage = FileImage(imageFile);
      } else {
        _localBannerImage = FileImage(imageFile);
      }
    });

    try {
      // 3. Upload image and get URL
      final imageUrl = await UserService.uploadProfileImage(
        user.id,
        imageFile,
        imageType,
      );

      // 4. Save the new URL to the user's record in the database
      await UserService.updateProfileImageUrl(user.id, imageUrl, imageType);

      // 5. Refresh the entire profile to confirm the change from the server
      _refreshProfile();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to upload image: $e')));
    }
  }
}
