import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
// [ADDED] Import PublicSpeakingController so we can change the tab state
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/screens/home/user_journey/public_speak_journey_section.dart';
import 'package:voquadro/screens/home/settings/settings_stage.dart';
import 'package:voquadro/screens/home/public_speaking_profile_stage.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/mic_test_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/public_speaking_home_page.dart';
import 'package:voquadro/src/hex_color.dart';

// [ADDED] Import the new UnderConstructionPage
import 'package:voquadro/screens/misc/under_construction.dart';

class NavigationIcons extends StatefulWidget {
  const NavigationIcons({super.key});

  @override
  State<NavigationIcons> createState() => _NavigationIconsState();
}

class _NavigationIconsState extends State<NavigationIcons> {
  static final Logger _logger = Logger();

  // Overlay management
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  /// Height of the bottom area to leave untouched (Navbar + Padding).
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
        onNavigate: (Widget page) {
          _closeMenu();
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => page));
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
    // 1. Close the "Options Tray" if it is open
    if (_isMenuOpen) _closeMenu();
    action();
  }

  void _handleHomePress() {
    _onIconPressed('Home icon pressed -> Master Reset', () {
      // 2. Close the "Burger Menu" (Drawer) if it is open
      // We check for both standard Drawer and EndDrawer just in case.
      final scaffoldState = Scaffold.maybeOf(context);
      if (scaffoldState != null) {
        if (scaffoldState.isDrawerOpen) {
          scaffoldState.closeDrawer();
        }
        if (scaffoldState.isEndDrawerOpen) {
          scaffoldState.closeEndDrawer();
        }
      }

      // 3. Pop any pushed screens (Dialogs, Modals, or Pages pushed on top of Hub)
      // This ensures we return to the "Root" of the main view (the Hub).
      Navigator.of(context).popUntil((route) => route.isFirst);

      // 4. Finally, switch the tab to Home
      context.read<PublicSpeakingController>().showHome();
    });
  }

  void _handleUserJourneyPress() {
    _logger.d('User Journey icon pressed!');
    if (_isMenuOpen) _closeMenu();

    context.read<PublicSpeakingController>().showJourney();
  }

  // [ADDED] Helper method to navigate to Under Construction Page
  void _navigateToUnderConstruction() {
    context.read<PublicSpeakingController>().showUnderConstruction();
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
            _navigateToUnderConstruction();
          }),
        ),
        _buildNavIcon(
          assetPath: 'assets/homepage_assets/adventure_mode.svg',
          onTap: () => _onIconPressed('Adventure mode icon pressed!', () {
            _navigateToUnderConstruction();
          }),
        ),
        _buildNavIcon(
          assetPath: 'assets/homepage_assets/user_journal.svg',
          onTap: _handleUserJourneyPress,
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

// ... (Rest of the file: _OptionsTrayOverlay class remains unchanged) ...
// Paste the rest of the _OptionsTrayOverlay class here if you are replacing the whole file
class _OptionsTrayOverlay extends StatefulWidget {
  final double navbarHeight;
  final VoidCallback onClose;
  final Function(Widget) onNavigate;

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

  // Use hex_color extension (removed 'const' as .toColor() is calculated)
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

    // Fade in
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
              child: Container(color: Colors.black.withOpacity(0.5)),
            ),
          ),
        ),

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
                  margin: const EdgeInsets.symmetric(horizontal: 0),
                  decoration: BoxDecoration(
                    color: _optionTrayMenuBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(10),
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOptionTrayMenuItem(
                        iconPath: 'assets/homepage_assets/profile.svg',
                        label: 'Profile',
                        onTap: () => widget.onNavigate(
                          const PublicSpeakingProfileStage(),
                        ),
                      ),
                      const Divider(height: 1, color: _dividerColor),
                      _buildOptionTrayMenuItem(
                        iconPath: 'assets/homepage_assets/mic_test.svg',
                        label: 'Mic Test',
                        onTap: () {},
                      ),
                      const Divider(height: 1, color: _dividerColor),
                      _buildOptionTrayMenuItem(
                        iconPath: 'assets/homepage_assets/podium.svg',
                        label: 'Practice',
                        onTap: () {},
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
