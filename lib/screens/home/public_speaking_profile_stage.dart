import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/widgets/Profile/profile_edit_sheet.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/services/user_service.dart';

// --- Data Model for Profile Stats ---
class ProfileStatOption {
  final String id;
  final String label;
  final String value;
  final String iconPath;

  ProfileStatOption({
    required this.id,
    required this.label,
    required this.value,
    required this.iconPath,
  });
}

class PublicSpeakingProfileStage extends StatefulWidget {
  const PublicSpeakingProfileStage({super.key});

  @override
  State<PublicSpeakingProfileStage> createState() =>
      _PublicSpeakingProfileStageState();
}

class _PublicSpeakingProfileStageState
    extends State<PublicSpeakingProfileStage> {
  late Future<ProfileData> _profileDataFuture;
  final ImagePicker _picker = ImagePicker();

  ImageProvider? _localAvatarImage;
  ImageProvider? _localBannerImage;
  User? _user;

  // --- State for Interactive Slots ---
  // Initialize with 3 empty slots [null, null, null]
  final List<ProfileStatOption?> _selectedSlots = [null, null, null];

  // --- Overlay State ---
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;
  int? _activeSlotIndex; // Tracks which slot is currently being edited

  @override
  void initState() {
    super.initState();
    _user = context.read<AppFlowController>().currentUser;
    _profileDataFuture = _fetchProfileData();
  }

  @override
  void dispose() {
    if (_isMenuOpen) {
      _overlayEntry?.remove();
    }
    super.dispose();
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
    });
  }

  // --- Overlay Logic ---
  void _openAttributePicker(int slotIndex, ProfileData profileData) {
    if (_isMenuOpen) {
      _closeMenu();
      return;
    }

    setState(() {
      _activeSlotIndex = slotIndex;
      _isMenuOpen = true;
    });

    // Define available options dynamically based on profile data
    final List<ProfileStatOption> options = [
      ProfileStatOption(
        id: 'streak',
        label: 'Highest Streak',
        value: '${profileData.highestStreak}',
        // [CHANGE] Attribute Icons: Using the 'fire.svg' asset
        iconPath: 'assets/profile_assets/fire.svg',
      ),
    ];

    _overlayEntry = OverlayEntry(
      builder: (context) => _AttributePickerOverlay(
        navbarHeight: 90.0, // Adjust to your actual navbar height
        onClose: _closeMenu,
        availableOptions: options,
        onAttributeSelected: (option) {
          setState(() {
            if (_activeSlotIndex != null) {
              _selectedSlots[_activeSlotIndex!] = option;
            }
          });
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isMenuOpen = false;
      _activeSlotIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Styles copied from ProfileTemplate to maintain consistency
    final Color purpleDark = '49416D'.toColor();
    final Color purpleMid = '7962A5'.toColor();
    const Color cardBg = Color(0xFFF0E6F6);
    const Color pageBg = Color(0xFFF7F3FB);

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
                  // 1. Banner Background
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

                  // 2. Scrollable Content (Header Card + Bio)
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

                  // 3. Top Actions (Back / Edit)
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
    const double buttonSize = 60.0;
    const double topMargin = 16.0;
    return Positioned(
      top: topMargin,
      left: 20,
      right: 20,
      height: buttonSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton.filled(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back),
            iconSize: 40,
            style: IconButton.styleFrom(
              backgroundColor: "7962A5".toColor(),
              foregroundColor: Colors.white,
            ),
          ),
          IconButton.filled(
            onPressed: () => _openEditSheet(profileData),
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

  // --- STEP 4: The Interactive Header Card ---
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
            color: Colors.black.withOpacity(0.15),
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
                // Username & Level
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
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'lvl22', // Hardcoded level or use profileData.level
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),

                // --- INTERACTIVE STATS ROW (3 Customizable Slots) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(3, (index) {
                    return _buildInteractiveStatSlot(
                      context,
                      index,
                      _selectedSlots[index], // Pass the data for this slot
                      () => _openAttributePicker(
                        index,
                        profileData,
                      ), // Pass the tap handler
                    );
                  }),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // Avatar Image (Centered at top)
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
                        color: Colors.black.withOpacity(0.15),
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
    ProfileStatOption? data,
    VoidCallback onTap,
  ) {
    // Calculate width to fit 3 items: (Screen width - padding - spacing) / 3
    final double cardWidth =
        (MediaQuery.of(context).size.width - 40 - 32 - 20) / 3;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        height: cardWidth * 1.1,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.75),
          borderRadius: BorderRadius.circular(16),
          // Show dashed border if empty, solid or none if filled?
          // Using solid for consistency, maybe lighter opacity if empty.
          border: data == null
              ? Border.all(color: Colors.grey.withOpacity(0.3), width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: data == null
            ? _buildEmptySlotState()
            : _buildFilledSlotState(data),
      ),
    );
  }

  Widget _buildEmptySlotState() {
    return Center(
      child: SvgPicture.asset(
        // [CHANGE] Empty State Icon: Using 'plus.svg' when slot is empty
        'assets/profile_assets/plus.svg',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
      ),
    );
  }

  Widget _buildFilledSlotState(ProfileStatOption data) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          data.iconPath,
          width: 30,
          height: 30,
          // Removed colorFilter to allow the Fire SVG to show its natural colors
        ),
        const SizedBox(height: 8),
        Text(
          data.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: '6C53A1'.toColor(),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          data.value,
          style: TextStyle(
            color: '6C53A1'.toColor(),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // --- Logic for editing bio/images ---
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
        ).showSnackBar(SnackBar(content: Text('Failed to update bio: $e')));
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
        ).showSnackBar(SnackBar(content: Text('Failed to update image: $e')));
      }
      _refreshProfile();
    }
  }
}

// --- The Attribute Picker Overlay (Step 2 Implementation) ---
class _AttributePickerOverlay extends StatefulWidget {
  final double navbarHeight;
  final VoidCallback onClose;
  final List<ProfileStatOption> availableOptions;
  final Function(ProfileStatOption) onAttributeSelected;

  const _AttributePickerOverlay({
    required this.navbarHeight,
    required this.onClose,
    required this.availableOptions,
    required this.onAttributeSelected,
  });

  @override
  State<_AttributePickerOverlay> createState() =>
      _AttributePickerOverlayState();
}

class _AttributePickerOverlayState extends State<_AttributePickerOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  final Color _trayBackgroundColor = const Color(0xFF2C2C3E);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      // [CHANGE] Tray Animation: Starts from Offset(0, 1.0) so it slides from very bottom up
      begin: const Offset(0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _animateOut() async {
    await _controller.reverse();
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop
        Positioned.fill(
          bottom: widget.navbarHeight,
          child: GestureDetector(
            onTap: _animateOut,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
        ),
        // Tray
        Positioned(
          left: 0,
          right: 0,
          bottom: widget.navbarHeight - 10,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  height: 250,
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    color: _trayBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1)),
                      left: BorderSide(color: Colors.white.withOpacity(0.1)),
                      right: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          "Select Attribute",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                          itemCount: widget.availableOptions.length,
                          itemBuilder: (context, index) {
                            return _buildGridItem(
                              widget.availableOptions[index],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridItem(ProfileStatOption option) {
    return GestureDetector(
      onTap: () {
        widget.onAttributeSelected(option);
        _animateOut();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(option.iconPath, width: 32, height: 32),
            const SizedBox(height: 12),
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Helper Widget for Bio (Copied locally) ---
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
            color: Colors.black.withOpacity(0.12),
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
                color: Colors.white.withOpacity(0.015),
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
