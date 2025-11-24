import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logger/logger.dart';
import 'package:voquadro/src/hex_color.dart';

var logger = Logger();

class DefaultActions extends StatelessWidget {
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
          // Only show the right-side burger FAB in the top area; left is intentionally empty.
          const Expanded(child: SizedBox()),

          // Burger button on the right inside a circular FAB for easy editing later.
          SizedBox(
            width: 70,
            height: 70,
            child: FloatingActionButton(
              heroTag: 'burger_icon_fab',
              shape: const CircleBorder(),
              onPressed: () {
                // no-op for now
              },
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
