import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:voquadro/hubs/controllers/app_flow_controller.dart';
import 'package:voquadro/screens/home/settings/settings_stage.dart';
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
  OverlayEntry? _overlayEntry;

  static const double _fabSize = 60.0;
  static const double _visibleBarHeight = 80.0;
  static const Color _fabColor = Color(0xFF7962A5);

  @override
  void dispose() {
    _removeMenu();
    super.dispose();
  }

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
    final overlayState = Overlay.of(context);

    if (renderBox == null) return;

    final size = renderBox.size;
    final pos = renderBox.localToGlobal(Offset.zero);

    const double menuWidth = 140;

    double left = pos.dx + size.width - menuWidth - 24;
    if (left < 8) left = 8;
    final double top = pos.dy + size.height + 8;

    _overlayEntry = OverlayEntry(
      builder: (context) => _MenuOverlay(
        top: top,
        left: left,
        width: menuWidth,
        onClose: _removeMenu,
        onLogout: _handleLogout,
        onSettings: _handleSettings,
      ),
    );

    overlayState.insert(_overlayEntry!);
  }

  void _handleSettings() {
    _removeMenu();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsStage()));
  }

  Future<void> _handleLogout() async {
    _removeMenu();
    showDialog(
      context: context,
      builder: (ctx) => ConfirmationDialog(
        onConfirm: () {
          context.read<AppFlowController>().logout();

          Navigator.of(ctx).pop();

          Navigator.of(context).popUntil((r) => r.isFirst);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: _visibleBarHeight - (_fabSize / 2),
      left: 20,
      right: 5,
      height: _fabSize,
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
              onPressed: () {
                _logger.d('Burger menu pressed');
                _toggleMenu();
              },
              backgroundColor: _fabColor,
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

class _MenuOverlay extends StatelessWidget {
  final double top;
  final double left;
  final double width;
  final VoidCallback onClose;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const _MenuOverlay({
    required this.top,
    required this.left,
    required this.width,
    required this.onClose,
    required this.onSettings,
    required this.onLogout,
  });

  // Colors
  static const Color _menuBgColor = Color(0xFF49416D);
  static const Color _borderColor = Color(0xFF6C53A1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onClose,
      child: Stack(
        children: [
          Positioned(
            left: left,
            top: top,
            width: width,
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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

                  Transform.translate(
                    offset: const Offset(0, -1),
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
                          color: _borderColor.withOpacity(0.12),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildMenuItem(
                            label: 'Settings',
                            asset: 'assets/homepage_assets/settings.svg',
                            onTap: onSettings,
                          ),
                          _buildDivider(),
                          _buildMenuItem(
                            label: 'Log out',
                            asset: 'assets/homepage_assets/exit_door.svg',
                            onTap: onLogout,
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
    );
  }

  Widget _buildDivider() =>
      Container(height: 1, color: _borderColor.withOpacity(0.25));

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
