import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/screens/home/user_journey/public_speak_journey_section.dart';
import 'package:voquadro/screens/home/settings/settings_stage.dart';
import 'package:voquadro/screens/home/public_speaking_profile_stage.dart';

// Imports for the menu actions
import 'package:voquadro/screens/gameplay/publicSpeaking/pages/mic_test_page.dart';
import 'package:voquadro/screens/gameplay/publicSpeaking/public_speaking_home_page.dart';

var logger = Logger();

class NavigationIcons extends StatefulWidget {
  const NavigationIcons({super.key});

  @override
  State<NavigationIcons> createState() => _NavigationIconsState();
}

class _NavigationIconsState extends State<NavigationIcons> {
  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  // Height of the bottom area to leave untouched (Navbar + Padding).
  // Adjust this if your actual navbar is taller/shorter.
  final double _navbarHeight = 90.0;

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

  @override
  void dispose() {
    if (_isMenuOpen) {
      _overlayEntry?.remove();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Home icon
        IconButton(
          onPressed: () {
            logger.d('Home icon pressed -> act as back');
            // Closing menu if open, then performing action
            if (_isMenuOpen) _closeMenu();
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
          icon: SvgPicture.asset(
            'assets/homepage_assets/house.svg',
            width: 50,
            height: 50,
          ),
          iconSize: 50,
        ),
        // FAQ icon
        IconButton(
          onPressed: () {
            logger.d('FAQ icon pressed!');
            if (_isMenuOpen) _closeMenu();
          },
          icon: SvgPicture.asset(
            'assets/homepage_assets/faq.svg',
            width: 50,
            height: 50,
          ),
          iconSize: 50,
        ),
        // Adventure mode icon
        IconButton(
          onPressed: () {
            logger.d('Adventure mode icon pressed!');
            if (_isMenuOpen) _closeMenu();
          },
          icon: SvgPicture.asset(
            'assets/homepage_assets/adventure_mode.svg',
            width: 50,
            height: 50,
          ),
          iconSize: 50,
        ),
        // User Journey icon
        IconButton(
          onPressed: () {
            logger.d('User Journey icon pressed!');
            if (_isMenuOpen) _closeMenu();
            _handleUserJourneyPress(context);
          },
          icon: SvgPicture.asset(
            'assets/homepage_assets/user_journal.svg',
            width: 50,
            height: 50,
          ),
          iconSize: 50,
        ),
        // Options Tray icon
        IconButton(
          onPressed: () {
            logger.d('Options Tray icon pressed!');
            _toggleMenu();
          },
          icon: SvgPicture.asset(
            'assets/homepage_assets/home_options.svg',
            width: 50,
            height: 50,
          ),
          iconSize: 50,
        ),
      ],
    );
  }

  void _handleUserJourneyPress(BuildContext context) {
    final appFlow = context.read<AppFlowController>();

    if (appFlow.currentMode == AppMode.publicSpeaking) {
      final user = appFlow.currentUser;

      if (user != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PublicSpeakJourneySection(
              username: user.username,
              currentXP: 69,
              maxXP: 200,
              currentLevel: 'Level 69',
              averageWPM: 0,
              averageFillers: 0,
              onBackPressed: () => Navigator.of(context).pop(),
              onProfilePressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PublicSpeakingProfileStage(),
                  ),
                );
              },
              onSettingsPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsStage(),
                  ),
                );
              },
            ),
          ),
        );
      }
    }
  }
}

/// The Overlay logic remains mostly the same, ensuring it doesn't cover the navbar.
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

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
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
        // The Scrim (Dimmer) - Stops ABOVE the navbar
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

        // The Menu Panel
        Positioned(
          left: 16,
          right: 16,
          bottom: widget.navbarHeight - 10,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C3E),
                    borderRadius: BorderRadius.circular(20),

                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuItem(
                        iconPath: 'assets/homepage_assets/profile.svg',
                        label: 'Profile',
                        onTap: () => widget.onNavigate(
                          const PublicSpeakingProfileStage(),
                        ),
                      ),
                      const Divider(height: 1, color: Colors.white12),
                      _buildMenuItem(
                        iconPath: 'assets/homepage_assets/mic_test.svg',
                        label: 'Mic Test',
                        onTap: () => widget.onNavigate(const MicTestPage()),
                      ),
                      const Divider(height: 1, color: Colors.white12),
                      _buildMenuItem(
                        iconPath: 'assets/homepage_assets/podium.svg',
                        label: 'Practice',
                        onTap: () =>
                            widget.onNavigate(const PublicSpeakingHomePage()),
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

  Widget _buildMenuItem({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
