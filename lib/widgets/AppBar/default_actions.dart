import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/screens/home/settings/settings_stage.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/widgets/Widget/confirmation_dialog_template.dart';

var logger = Logger();

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
  final GlobalKey _burgerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeMenu();
    } else {
      _showMenu();
    }
  }

  void _removeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showMenu() {
    final renderBox =
        _burgerKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    if (renderBox == null || overlay == null) return;

    final size = renderBox.size;
    final pos = renderBox.localToGlobal(Offset.zero);
    const double menuWidth = 140;
    const double menuHeight = 140;
    // Align right edge of menu to right edge of button, then nudge left a bit
    double left = pos.dx + size.width - menuWidth - 24; // shift left by 24px
    if (left < 8) left = 8;
    final double top = pos.dy + size.height + 8; // below the button

    _overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _removeMenu,
        child: Stack(
          children: [
            // Menu positioned below the burger button
            Positioned(
              left: left,
              top: top,
              width: menuWidth,
              child: Material(
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // small pointer triangle shifted left so it sits on the bubble edge
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 1.0),
                        child: CustomPaint(
                          size: const Size(30, 20),
                          painter: _TrianglePainter(color: "49416D".toColor()),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: "49416D".toColor(),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(14),
                            topRight: Radius.zero,
                            bottomLeft: Radius.circular(14),
                            bottomRight: Radius.circular(14),
                          ),
                          border: Border.all(
                            color: "6C53A1".toColor().withOpacity(0.12),
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _menuItem(
                              label: 'Settings',
                              asset: 'assets/homepage_assets/settings.svg',
                              onTap: () {
                                _removeMenu();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const SettingsStage(),
                                  ),
                                );
                              },
                            ),
                            _divider(),
                            _menuItem(
                              label: 'Log out',
                              asset: 'assets/homepage_assets/exit_door.svg',
                              onTap: () async {
                                _removeMenu();
                                showDialog(
                                  context: context,
                                  builder: (ctx) => ConfirmationDialog(
                                    onConfirm: () {
                                      context
                                          .read<AppFlowController>()
                                          .logout();
                                      Navigator.of(ctx).pop();
                                      Navigator.of(
                                        context,
                                      ).popUntil((r) => r.isFirst);
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  Widget _divider() =>
      Container(height: 1, color: "6C53A1".toColor().withOpacity(0.25));

  Widget _menuItem({
    required String label,
    required String asset,
    VoidCallback? onTap,
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

  @override
  void dispose() {
    _removeMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double buttonSize = 60.0;
    const double visibleBarHeight = 80;

    return Positioned(
      top: visibleBarHeight - (buttonSize / 2),
      left: 20,
      right: 5,
      height: buttonSize,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Expanded(child: SizedBox()),
          SizedBox(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              key: _burgerKey,
              heroTag: 'burger_icon_fab',
              shape: const CircleBorder(),
              onPressed: _toggleMenu,
              backgroundColor: "7962A5".toColor(),
              elevation: 3.0,
              child: SvgPicture.asset(
                'assets/homepage_assets/burger.svg',
                width: 30,
                height: 30,
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

// small triangle painter for menu pointer
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter({required this.color});

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
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
