import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:voquadro/src/hex_color.dart';
import 'package:voquadro/views/pages/gameplay/public_speaking/public_speaking_gameplay_page.dart';

var logger = Logger();


class ModeSelectionActions extends StatelessWidget {
  const ModeSelectionActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start, 
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 70,
                      width: 250,
                      child: FloatingActionButton(
                        heroTag: 'tart_speaking_fab',
                        shape: const StadiumBorder(),
                        onPressed: () {
                          logger.d('FAB 1 pressed!');

                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                            return PublicSpeakingGameplayPage();
                          },));
                        },
                        backgroundColor: "00A9A5".toColor(),
                        elevation: 3.0,
                        child: const Text(
                          'Start Speaking!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      height: 50,
                      width: 200,
                      child: FloatingActionButton(
                        heroTag: 'secondary_action_fab',
                        shape: const StadiumBorder(),
                        onPressed: () {
                          logger.d('FAB 2 pressed!');
                        },
                        backgroundColor: "125B5A".toColor(),
                        elevation: 3.0,
                        child: const Text(
                          'Switch Mode',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    IconButton.filled(
                      onPressed: () {
                        logger.d('Book icon pressed!');
                      },
                      icon: const Icon(Icons.book),
                      iconSize: 50,
                      style: IconButton.styleFrom(
                        backgroundColor: "7962A5".toColor(),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    IconButton.filled(
                      onPressed: () {
                        logger.d('Analytics icon pressed!');
                      },
                      icon: const Icon(Icons.analytics),
                      iconSize: 50,
                      style: IconButton.styleFrom(
                        backgroundColor: "7962A5".toColor(),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            );
  }
}