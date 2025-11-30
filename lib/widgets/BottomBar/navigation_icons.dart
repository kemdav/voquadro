import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/screens/home/user_journey/public_speak_journey_section.dart';
import 'package:voquadro/screens/home/settings/settings_stage.dart';
import 'package:voquadro/screens/home/public_speaking_profile_stage.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/mic_test_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/public_speaking_home_page.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/screens/misc/under_construction.dart';

class NavigationIcons extends StatefulWidget {
  const NavigationIcons({super.key});

  @override
  State<NavigationIcons> createState() => _NavigationIconsState();
}

class _NavigationIconsState extends State<NavigationIcons> {
  static final Logger _logger = Logger();

  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;
  final double _navbarHeight = 90.0;
  final double _iconSize = 50.0;

  @override
  void dispose() {
    if (_isMenuOpen) {
      _overlayEntry?.remove();
    }
    super.dispose();
  }

  void _toggleMenu() {
    if (_isMenuOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    _overlayEntry = OverlayEntry(
      builder: (context) => _OptionsTrayOverlay(
        navbarHeight: _navbarHeight,
        onClose: _closeMenu,
        onNavigate: (VoidCallback navAction) {
          _closeMenu();
          navAction();
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {
      _isMenuOpen = true;
    });
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    setState(() {
      _isMenuOpen = false;
    });
  }

  void _onIconPressed(String logMessage, VoidCallback action) {
    _logger.d(logMessage);
    if (_isMenuOpen) _closeMenu();
    action();
  }

  void _handleHomePress() {
    _onIconPressed('Home icon pressed -> Master Reset', () {
      final scaffoldState = Scaffold.maybeOf(context);
      if (scaffoldState != null) {
        if (scaffoldState.isDrawerOpen) scaffoldState.closeDrawer();
        if (scaffoldState.isEndDrawerOpen) scaffoldState.closeEndDrawer();
      }
      Navigator.of(context).popUntil((route) => route.isFirst);
      context.read<PublicSpeakingController>().showHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildNavIcon(
          assetPath: 'assets/homepage_assets/house.svg',
          onTap: _handleHomePress,
        ),
        _buildNavIcon(
          assetPath: 'assets/homepage_assets/faq.svg',
          onTap: () => _onIconPressed('FAQ icon pressed!', () {
            context.read<PublicSpeakingController>().showUnderConstruction();
          }),
        ),
        _buildNavIcon(
          assetPath: 'assets/homepage_assets/adventure_mode.svg',
          onTap: () => _onIconPressed('Adventure mode icon pressed!', () {
            context.read<PublicSpeakingController>().showUnderConstruction();
          }),
        ),
        _buildNavIcon(
          assetPath: 'assets/homepage_assets/user_journal.svg',
          onTap: () => _onIconPressed('Journal pressed', () {
            context.read<PublicSpeakingController>().showJourney();
          }),
        ),
        _buildNavIcon(
          assetPath: 'assets/homepage_assets/home_options.svg',
          onTap: () {
            _logger.d('Options Tray icon pressed!');
            _toggleMenu();
          },
        ),
      ],
    );
  }

  Widget _buildNavIcon({
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: SvgPicture.asset(assetPath, width: _iconSize, height: _iconSize),
      iconSize: _iconSize,
    );
  }
}

class _OptionsTrayOverlay extends StatefulWidget {
  final double navbarHeight;
  final VoidCallback onClose;
  final Function(VoidCallback) onNavigate;

  const _OptionsTrayOverlay({
    required this.navbarHeight,
    required this.onClose,
    required this.onNavigate,
  });

  @override
  State<_OptionsTrayOverlay> createState() => _OptionsTrayOverlayState();
}

class _OptionsTrayOverlayState extends State<_OptionsTrayOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  static final Color _optionTrayMenuBackgroundColor = "2C2C3E".toColor();
  static const Color _dividerColor = Colors.white12;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.09),
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
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          bottom: widget.navbarHeight,
          child: GestureDetector(
            onTap: _animateOut,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Container(
                color: Colors.black.withValues(alpha: 128), // 0.5 * 255 ≈ 128
              ),
            ),
          ),
        ),
        // We position this slightly overlapping the navbar to ensure connection
        Positioned(
          left: 0,
          right: 0,
          // navbarHeight (90) - 10 = 80. Matches visual height of navbar.
          bottom: widget.navbarHeight - 10,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    color: _optionTrayMenuBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    // [CHANGED] Use Border constructor to specify sides.
                    // Removed the bottom border to merge with the navbar.
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 26),
                      ), // 0.1 * 255 ≈ 26
                      left: BorderSide(
                        color: Colors.white.withValues(alpha: 26),
                      ),
                      right: BorderSide(
                        color: Colors.white.withValues(alpha: 26),
                      ),
                      // bottom: BorderSide.none,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOptionTrayMenuItem(
                        iconPath: 'assets/homepage_assets/profile.svg',
                        label: 'Profile',
                        onTap: () => widget.onNavigate(() {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PublicSpeakingProfileStage(),
                            ),
                          );
                        }),
                      ),
                      const Divider(height: 1, color: _dividerColor),
                      _buildOptionTrayMenuItem(
                        iconPath: 'assets/homepage_assets/mic_test.svg',
                        label: 'Mic Test',
                        onTap: () => widget.onNavigate(() {
                          context
                              .read<PublicSpeakingController>()
                              .showUnderConstruction();
                        }),
                      ),
                      const Divider(height: 1, color: _dividerColor),
                      _buildOptionTrayMenuItem(
                        iconPath: 'assets/homepage_assets/podium.svg',
                        label: 'Practice',
                        onTap: () => widget.onNavigate(() {
                          context
                              .read<PublicSpeakingController>()
                              .showUnderConstruction();
                        }),
                      ),
                      // Add a tiny colored spacer at the bottom to blend with navbar color if needed
                      // But since we removed the border, it should sit flush.
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

  Widget _buildOptionTrayMenuItem({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              width: 24,
              height: 24,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
