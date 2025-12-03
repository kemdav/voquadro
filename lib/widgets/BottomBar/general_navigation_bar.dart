import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/widgets/BottomBar/navigation_icons.dart';

class GeneralNavigationBar extends StatelessWidget {
  const GeneralNavigationBar({
    super.key,
    this.actions,
    this.navBarVisualHeight = 220.0,
    this.totalHitTestHeight = 180.0,
    this.showIcons = true,
  });

  final Widget? actions;
  final double navBarVisualHeight;
  final double totalHitTestHeight;
  final bool showIcons;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: totalHitTestHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Purple background bar (fixed at bottom) - only show if navBarVisualHeight > 0
          if (navBarVisualHeight > 0)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: navBarVisualHeight,
                decoration: BoxDecoration(color: "49416D".toColor()),
              ),
            ),
          // Navigation icons (centered inside purple bar at bottom) - only show if navBarVisualHeight > 0
          if (navBarVisualHeight > 0 && showIcons)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: navBarVisualHeight,
              child: Center(child: const NavigationIcons()),
            ),
          // Actions widget (positioned above the purple navigation bar, or at bottom if no nav bar)
          if (actions != null)
            Positioned(
              bottom: navBarVisualHeight > 0 ? navBarVisualHeight + 20 : 20,
              left: 20,
              right: 20,
              child: actions!,
            ),
        ],
      ),
    );
  }
}
