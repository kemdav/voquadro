import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/screens/home/settings/settings_stage.dart';
import 'package:voquadro/services/sound_service.dart';
import 'package:voquadro/src/helper-class/progression_conversion_helper.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/widgets/Widget/confirmation_dialog_template.dart';

class DefaultActions extends StatefulWidget {
  const DefaultActions({
    super.key,
    this.onBackPressed,
    this.onProfilePressed,
    this.onSettingsPressed,
  });

  final VoidCallback? onBackPressed;
  final VoidCallback? onProfilePressed;
  final VoidCallback? onSettingsPressed;

  @override
  State<DefaultActions> createState() => _DefaultActionsState();
}

class _DefaultActionsState extends State<DefaultActions> {
  static final Logger _logger = Logger();

  final GlobalKey _burgerKey = GlobalKey();
  OverlayEntry? _burgerMenuOverlayEntry;

  static const double _fabSize = 60.0;
  static const double _visibleBarHeight = 80.0;

  static final Color _fabColor = "7962A5".toColor();

  @override
  void dispose() {
    _removeBurgerMenu();
    super.dispose();
  }

  void _toggleBurgerMenu() {
    if (_burgerMenuOverlayEntry != null) {
      _removeBurgerMenu();
    } else {
      _showBurgerMenu();
    }
  }

  void _removeBurgerMenu() {
    _burgerMenuOverlayEntry?.remove();
    _burgerMenuOverlayEntry = null;
  }

  void _showBurgerMenu() {
    final renderBox =
        _burgerKey.currentContext?.findRenderObject() as RenderBox?;
    final overlayState = Overlay.of(context);

    if (renderBox == null) return;

    final size = renderBox.size;
    final pos = renderBox.localToGlobal(Offset.zero);

    const double menuWidth = 140;

    double left = pos.dx + size.width - menuWidth - 24;

    if (left < 8) left = 8;

    final double top = pos.dy + size.height + 8;

    _burgerMenuOverlayEntry = OverlayEntry(
      builder: (context) => _BurgerMenuOverlay(
        top: top,
        left: left,
        width: menuWidth,
        onClose: _removeBurgerMenu,
        onLogout: _handleLogout,
        onSettings: _handleSettings,
      ),
    );

    overlayState.insert(_burgerMenuOverlayEntry!);
  }

  void _handleSettings() {
    context.read<SoundService>().playSfx('assets/audio/button_click.mp3');
    _removeBurgerMenu();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsStage()));
  }

  void _handleLogout() {
    context.read<SoundService>().playSfx('assets/audio/button_click.mp3');
    _removeBurgerMenu();
    showDialog(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        onConfirm: () async {
          final appFlow = context.read<AppFlowController>();
          final navigator = Navigator.of(ctx);

          // Close the dialog
          if (navigator.canPop()) {
            navigator.pop();
          }

          // Small delay to allow navigation to settle
          await Future.delayed(const Duration(milliseconds: 200));

          // Perform logout
          await appFlow.logout();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appFlow = context.watch<AppFlowController>();
    final user = appFlow.currentUser;

    // Default values if user is not loaded
    int currentLevel = 1;
    int currentXp = 0;
    int requiredXp = 100;
    String currentRank = "Novice";

    if (user != null) {
      final levelInfo = ProgressionConversionHelper.getLevelProgressInfo(
        user.publicSpeakingEXP,
      );
      currentLevel = levelInfo.level;
      currentXp = levelInfo.currentLevelExp;
      requiredXp = levelInfo.expToNextLevel;
      currentRank = levelInfo.rank;
    }

    return Positioned(
      top: _visibleBarHeight - (_fabSize / 2),
      left: 20,
      right: 5,
      height: _fabSize + 10, // Increased height slightly for the new card
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center, // Centered vertically
        children: [
          // --- NEW LEVEL BAR SECTION ---
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 4.0),
              child: _LevelProgressBar(
                currentLevel: currentLevel,
                currentXp: currentXp,
                requiredXp: requiredXp,
                rankName: currentRank,
              ),
            ),
          ),

          // -----------------------------
          SizedBox(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              key: _burgerKey,
              heroTag: 'burger_icon_fab',
              shape: const CircleBorder(),
              onPressed: () {
                _logger.d('Burger menu pressed');
                context.read<SoundService>().playSfx(
                  'assets/audio/button_click.mp3',
                );
                _toggleBurgerMenu();
              },
              backgroundColor: _fabColor,
              elevation: 3.0,
              child: SvgPicture.asset(
                'assets/homepage_assets/burger.svg',
                width: 27,
                height: 27,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- NEW WIDGET: Level Progress Bar ---
class _LevelProgressBar extends StatelessWidget {
  final int currentLevel;
  final int currentXp;
  final int requiredXp;
  final String rankName;

  const _LevelProgressBar({
    required this.currentLevel,
    required this.currentXp,
    required this.requiredXp,
    required this.rankName,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate percentage (clamp to 0.0 - 1.0 to prevent errors)
    final double progress = (currentXp / requiredXp).clamp(0.0, 1.0);

    // Using your app's color palette
    final Color textColor = "49416D".toColor();
    final Color barColor = "7962A5".toColor();

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 230), // 0.9 * 255 ≈ 230
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 26), // 0.1 * 255 ≈ 26
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank Emblem
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: barColor.withValues(alpha: 26), // Light purple bg
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/rank_emblem_assets/${rankName.toLowerCase()}.png',
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.shield, size: 30, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Info Column
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Rank Name & Level
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      rankName,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: textColor,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      'Lvl $currentLevel',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: barColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Progress Bar
                Stack(
                  children: [
                    // Background track
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: textColor.withValues(alpha: 26),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    // Fill
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // XP Text (Optional, kept small)
                Padding(
                  padding: const EdgeInsets.only(top: 2.0),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$currentXp / $requiredXp XP',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: textColor.withValues(alpha: 128),
                        fontSize: 9,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ... (The _BurgerMenuOverlay and _TrianglePainter classes remain exactly the same as your original code) ...

class _BurgerMenuOverlay extends StatefulWidget {
  final double top;
  final double left;
  final double width;
  final VoidCallback onClose;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _BurgerMenuOverlay({
    required this.top,
    required this.left,
    required this.width,
    required this.onClose,
    required this.onSettings,
    required this.onLogout,
  });

  @override
  State<_BurgerMenuOverlay> createState() => _BurgerMenuOverlayState();
}

class _BurgerMenuOverlayState extends State<_BurgerMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Using hex_color extension
  static final Color _menuBgColor = "49416D".toColor();
  static final Color _borderColor = "6C53A1".toColor();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Slide: Starts slightly above (-0.1) and slides down to 0
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    // Fade: Starts invisible (0.0) and fades to visible (1.0)
    _fadeAnimation = Tween<double>(
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

  // Handles the exit animation before removing the overlay
  Future<void> _handleClose() async {
    await _controller.reverse();
    widget.onClose();
  }

  Future<void> _handleSelection(VoidCallback action) async {
    await _controller.reverse();
    action();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleClose,
      child: Stack(
        children: [
          Positioned(
            left: widget.left,
            top: widget.top,
            width: widget.width,
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Triangle Pointer
                      Align(
                        alignment: Alignment.topRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 1.0),
                          child: CustomPaint(
                            size: const Size(30, 20),
                            painter: _TrianglePainter(color: _menuBgColor),
                          ),
                        ),
                      ),

                      // 2. Menu Content Box
                      // Offset vertically to overlap slightly or sit flush with triangle
                      Transform.translate(
                        offset: const Offset(
                          0,
                          -1,
                        ), // pull up slightly to connect
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: _menuBgColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(14),
                              topRight: Radius.zero,
                              bottomLeft: Radius.circular(14),
                              bottomRight: Radius.circular(14),
                            ),
                            border: Border.all(
                              color: _borderColor.withValues(
                                alpha: 31,
                              ), // 0.12 * 255 ≈ 31
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildMenuItem(
                                label: 'Settings',
                                asset: 'assets/homepage_assets/settings.svg',
                                onTap: () =>
                                    _handleSelection(widget.onSettings),
                              ),
                              _buildDivider(),
                              _buildMenuItem(
                                label: 'Log out',
                                asset: 'assets/homepage_assets/exit_door.svg',
                                onTap: () => _handleSelection(widget.onLogout),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(
    height: 1,
    color: _borderColor.withValues(alpha: 64),
  ); // 0.25 * 255 ≈ 64

  Widget _buildMenuItem({
    required String label,
    required String asset,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
        child: Row(
          children: [
            SvgPicture.asset(
              asset,
              width: 22,
              height: 22,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  const _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePainter oldDelegate) =>
      color != oldDelegate.color;
}
