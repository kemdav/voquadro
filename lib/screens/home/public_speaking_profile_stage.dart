import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:voquadro/theme/voquadro_colors.dart';
import 'package:voquadro/widgets/Profile/profile_edit_sheet.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/services/user_service.dart';
import 'package:voquadro/src/models/attribute_stat_option.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PublicSpeakingProfileStage extends StatefulWidget {
  const PublicSpeakingProfileStage({super.key});

  @override
  State<PublicSpeakingProfileStage> createState() =>
      _PublicSpeakingProfileStageState();
}

class _PublicSpeakingProfileStageState
    extends State<PublicSpeakingProfileStage> {
  late Future<ProfileData> _profileDataFuture;
  
  // Stats & Persistence
  List<AttributeStatOption> _allStats = [];
  bool _isLoadingStats = true;

  final ImagePicker _picker = ImagePicker();

  ImageProvider? _localAvatarImage;
  ImageProvider? _localBannerImage;
  User? _user;

  // --- State for Interactive Slots ---
  final List<AttributeStatOption?> _selectedSlots = [null, null, null];

  @override
  void initState() {
    super.initState();
    _user = context.read<AppFlowController>().currentUser;
    _profileDataFuture = _fetchProfileData();
    _loadStatsAndPrefs();
  }

  Future<void> _loadStatsAndPrefs() async {
    try {
      // 1. Fetch stats from DB
      final stats = await UserService().getUserAttributeStats();
      
      // 2. Fetch saved slots from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedId0 = prefs.getString('profile_stat_0');
      final savedId1 = prefs.getString('profile_stat_1');
      final savedId2 = prefs.getString('profile_stat_2');

      // 3. Map saved IDs to actual stat objects
      AttributeStatOption? findStat(String? id) {
        if (id == null) return null;
        try {
          return stats.firstWhere((s) => s.id == id);
        } catch (_) {
          return null;
        }
      }

      if (mounted) {
        setState(() {
          _allStats = stats;
          _selectedSlots[0] = findStat(savedId0);
          _selectedSlots[1] = findStat(savedId1);
          _selectedSlots[2] = findStat(savedId2);
          _isLoadingStats = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading stats/prefs: $e');
      if (mounted) {
        setState(() {
          _isLoadingStats = false;
        });
      }
    }
  }

  Future<ProfileData> _fetchProfileData() {
    if (_user == null) {
      return Future.error('User not logged in. Cannot fetch profile.');
    }
    return UserService.getProfileData(_user!.id);
  }

  void _refreshProfile() {
    setState(() {
      _localAvatarImage = null;
      _localBannerImage = null;
      _profileDataFuture = _fetchProfileData();
      _isLoadingStats = true;
    });
    _loadStatsAndPrefs();
  }

  // --- Bottom Sheet Logic ---
  void _openAttributePicker(int slotIndex, List<AttributeStatOption> allStats) {
    // Filter out stats that are already selected in other slots
    final currentlySelectedIds = _selectedSlots
        .where((slot) => slot != null)
        .map((slot) => slot!.id)
        .toSet();

    final List<AttributeStatOption> availableForSelection = allStats
        .where((stat) => !currentlySelectedIds.contains(stat.id))
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2C2C3E), // Dark tray background
      isScrollControlled: true, // Allows the sheet to be dragged up
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          height: 350, // Height of the tray
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- DRAG HANDLE (The "little thing" at the top) ---
              Center(
                child: Container(
                  width: 50, // Wider for better visibility
                  height: 5, // Thicker
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(
                      alpha: 0.4,
                    ), // Higher contrast
                    borderRadius: BorderRadius.circular(10), // Pill shape
                  ),
                ),
              ),

              const Center(
                child: Text(
                  "Select Attribute",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Grid of Options
              Expanded(
                child: availableForSelection.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.query_stats,
                              color: Colors.white.withValues(alpha: 0.5),
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              allStats.isEmpty
                                  ? "Complete a session to unlock stats!"
                                  : "All available stats selected.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                        itemCount: availableForSelection.length,
                        itemBuilder: (context, index) {
                          final option = availableForSelection[index];
                          return GestureDetector(
                            onTap: () async {
                              setState(() {
                                _selectedSlots[slotIndex] = option;
                              });
                              
                              // Save to SharedPreferences
                              final prefs = await SharedPreferences.getInstance();
                              await prefs.setString('profile_stat_$slotIndex', option.id);

                              if (context.mounted) {
                                Navigator.pop(context); // Close sheet
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    option.assetPath,
                                    width: 32,
                                    height: 32,
                                    // Fallback icon just in case path is wrong
                                    placeholderBuilder: (context) => const Icon(
                                      Icons.broken_image,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    option.name,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option.value,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color purpleDark = VoquadroColors.primaryPurple;
    final Color purpleMid = VoquadroColors.publicSpeakingSecondary;
    final Color cardBg = const Color(0xFFF0E6F6); // Keeping as literal if not in VoquadroColors, or add it.
    final Color pageBg = const Color(0xFFF7F3FB);
    return FutureBuilder<ProfileData>(
      future: _profileDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          final profileData = snapshot.data!;

          final avatarImage =
              _localAvatarImage ??
              (profileData.avatarUrl != null
                      ? NetworkImage(profileData.avatarUrl!)
                      : const AssetImage('assets/images/dolph.png'))
                  as ImageProvider;

          final bannerImage =
              _localBannerImage ??
              (profileData.bannerUrl != null
                      ? NetworkImage(profileData.bannerUrl!)
                      : const AssetImage('assets/images/defaultbg.png'))
                  as ImageProvider;

          return Scaffold(
            backgroundColor: pageBg,
            body: SafeArea(
              child: Stack(
                children: [
                  // 1. Banner
                  Positioned.fill(
                    top: 0,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: InkWell(
                        onTap: () => _handleImagePickAndUpload(
                          profileData: profileData,
                          isAvatar: false,
                        ),
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
                  ),

                  // 2. Scrollable Content
                  Positioned.fill(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(top: 140, bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _buildInteractiveHeaderCard(
                              context,
                              profileData,
                              avatarImage,
                              purpleDark,
                              cardBg,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: _BioCard(
                              bio: profileData.bio ?? 'Write your bio here...',
                              titleColor: purpleDark,
                              cardBg: cardBg,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 3. Top Actions
                  _buildProfileActions(context, profileData),
                ],
              ),
            ),
          );
        }
        return const Scaffold(
          body: Center(child: Text('No profile data found.')),
        );
      },
    );
  }

  Widget _buildProfileActions(BuildContext context, ProfileData profileData) {
    return Positioned(
      top: 16,
      left: 20,
      right: 20,
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filled(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
            iconSize: 40,
            style: IconButton.styleFrom(
              backgroundColor: VoquadroColors.publicSpeakingSecondary,
              foregroundColor: Colors.white,
            ),
          ),
          IconButton.filled(
            onPressed: () => _openEditSheet(profileData),
            icon: const Icon(Icons.edit),
            iconSize: 40,
            style: IconButton.styleFrom(
              backgroundColor: VoquadroColors.publicSpeakingSecondary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveHeaderCard(
    BuildContext context,
    ProfileData profileData,
    ImageProvider avatarImage,
    Color titleColor,
    Color cardBg,
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
                // Username
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      profileData.username,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: titleColor,
                        height: 1.0,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),

                // Interactive Stats Row
                _isLoadingStats
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(3, (index) {
                          return _buildInteractiveStatSlot(
                            context,
                            index,
                            _selectedSlots[index],
                            () => _openAttributePicker(index, _allStats),
                          );
                        }),
                      ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Avatar Image
          Positioned(
            top: -56,
            left: 0,
            right: 0,
            child: Center(
              child: InkWell(
                onTap: () => _handleImagePickAndUpload(
                  profileData: profileData,
                  isAvatar: true,
                ),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveStatSlot(
    BuildContext context,
    int index,
    AttributeStatOption? data,
    VoidCallback onTap,
  ) {
    // Dynamic width calculation
    final double cardWidth = (MediaQuery.of(context).size.width - 92) / 3;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: 110,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: data == null
            ? Center(
                child: SvgPicture.asset(
                  'assets/profile_assets/plus.svg',
                  width: 32,
                  height: 32,
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.srcIn,
                  ),
                  placeholderBuilder: (context) =>
                      const Icon(Icons.add, color: Colors.grey, size: 32),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      data.assetPath,
                      width: 28,
                      height: 28,
                      placeholderBuilder: (context) =>
                          const Icon(Icons.broken_image, size: 28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.value,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // --- Logic for editing bio/images (Unchanged) ---
  void _openEditSheet(ProfileData profileData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF0E6F6),
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

  Future<void> _handleBioSave(String newBio) async {
    if (_user == null) return;
    if (mounted) Navigator.of(context).pop();

    try {
      await UserService.updateBio(_user!.id, newBio);
      _refreshProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
    }
  }

  Future<void> _handleImagePickAndUpload({
    required ProfileData profileData,
    required bool isAvatar,
  }) async {
    if (_user == null) return;
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

    if (mounted) Navigator.of(context).pop();

    setState(() {
      if (isAvatar) {
        _localAvatarImage = FileImage(imageFile);
      } else {
        _localBannerImage = FileImage(imageFile);
      }
    });

    try {
      await UserService.replaceProfileImage(
        userId: _user!.id,
        newImageFile: imageFile,
        imageType: imageType,
        oldImageUrl: oldImageUrl,
      );
      _refreshProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed: $e')));
      }
      _refreshProfile();
    }
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
            Text(
              'Bio:',
              style: TextStyle(
                color: titleColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.015),
                borderRadius: BorderRadius.circular(16),
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
