// [FILE: kemdav/voquadro/voquadro-feature-animation-dolph-and-other-stuff/lib/widgets/BottomBar/navigation_icons.dart]

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/public-speaking-controller/public_speaking_controller.dart';
import 'package:voquadro/screens/home/public_speaking_profile_stage.dart';
import 'package:voquadro/services/sound_service.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/data/notifiers.dart';

class NavigationIcons extends StatefulWidget {
  const NavigationIcons({super.key});

  @override
  State<NavigationIcons> createState() => _NavigationIconsState();
}

class _NavigationIconsState extends State<NavigationIcons> {
  static final Logger _logger = Logger();

  OverlayEntry? _overlayEntry;
  bool _isMenuOpen = false;

  int _selectedIndex = 0;

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
    // [FIX] Capture the controller from the current context where it exists
    final publicSpeakingController = context.read<PublicSpeakingController>();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        // [FIX] Wrap the overlay in ChangeNotifierProvider.value
        // This passes the existing controller to the Overlay's widget tree
        return ChangeNotifierProvider.value(
          value: publicSpeakingController,
          child: _OptionsTrayOverlay(
            navbarHeight: _navbarHeight,
            onClose: _closeMenu,
            onNavigate: (VoidCallback navAction) {
              _closeMenu();
              navAction();
            },
          ),
        );
      },
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

  void _onIconPressed(int index, String logMessage, VoidCallback action) {
    _logger.d(logMessage);
    context.read<SoundService>().playSfx('assets/audio/navigation_sfx.mp3');
    if (_isMenuOpen) _closeMenu();

    if (index != 4) {
      setState(() {
        _selectedIndex = index;
      });
    }

    action();
  }

  void _handleHomePress() {
    _onIconPressed(0, 'Home icon pressed -> Master Reset', () {
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildNavIcon(
          index: 0,
          assetPath: 'assets/homepage_assets/house.svg',
          onTap: _handleHomePress,
        ),
        _buildNavIcon(
          index: 1,
          assetPath: 'assets/homepage_assets/faq.svg',
          onTap: () => _onIconPressed(1, 'FAQ icon pressed!', () {
            context.read<PublicSpeakingController>().showUnderConstruction();
          }),
        ),
        _buildNavIcon(
          index: 2,
          assetPath: 'assets/homepage_assets/adventure_mode.svg',
          onTap: () => _onIconPressed(2, 'Adventure mode icon pressed!', () {
            context.read<PublicSpeakingController>().showUnderConstruction();
          }),
        ),
        ValueListenableBuilder<bool>(
          valueListenable: hasNewFeedbackNotifier,
          builder: (context, hasNewFeedback, child) {
            return _buildNavIcon(
              index: 3,
              assetPath: 'assets/homepage_assets/user_journal.svg',
              showBadge: hasNewFeedback,
              onTap: () => _onIconPressed(3, 'Journal pressed', () {
                hasNewFeedbackNotifier.value = false;
                context.read<PublicSpeakingController>().showJourney();
              }),
            );
          },
        ),
        _buildNavIcon(
          index: 4,
          assetPath: 'assets/homepage_assets/home_options.svg',
          onTap: () {
            _logger.d('Options Tray icon pressed!');
            context.read<SoundService>().playSfx(
              'assets/audio/navigation_sfx.mp3',
            );
            _toggleMenu();
          },
        ),
      ],
    );
  }

  Widget _buildNavIcon({
    required int index,
    required String assetPath,
    required VoidCallback onTap,
    bool showBadge = false,
  }) {
    final isSelected = _selectedIndex == index && index != 4;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SvgPicture.asset(
                  assetPath,
                  width: _iconSize,
                  height: _iconSize,
                ),
                if (showBadge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
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
          bottom: 0,
          child: GestureDetector(
            onTap: _animateOut,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: widget.navbarHeight,
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
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildOptionTrayMenuItem(
                        iconPath: 'assets/homepage_assets/profile.svg',
                        label: 'Profile',
                        onTap: () => widget.onNavigate(() {
                          context.read<SoundService>().playSfx(
                            'assets/audio/navigation_sfx.mp3',
                          );
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const PublicSpeakingProfileStage(),
                            ),
                          );
                        }),
                      ),
                      const Divider(height: 1, color: _dividerColor),
                      // [NOTE] Mic Test button IS kept here
                      _buildOptionTrayMenuItem(
                        iconPath: 'assets/homepage_assets/mic_test.svg',
                        label: 'Mic Test',
                        onTap: () => widget.onNavigate(() {
                          context.read<SoundService>().playSfx(
                            'assets/audio/navigation_sfx.mp3',
                          );
                          // This call will now work because of the Provider fix above
                          context
                              .read<PublicSpeakingController>()
                              .startMicTestOnly();
                        }),
                      ),
                      const Divider(height: 1, color: _dividerColor),
                      _buildOptionTrayMenuItem(
                        iconPath: 'assets/homepage_assets/podium.svg',
                        label: 'Practice',
                        onTap: () => widget.onNavigate(() {
                          context.read<SoundService>().playSfx(
                            'assets/audio/navigation_sfx.mp3',
                          );
                          context
                              .read<PublicSpeakingController>()
                              .showUnderConstruction();
                        }),
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
