import 'package:flutter/material.dart';

class NextRankPage extends StatelessWidget {
  const NextRankPage({
    super.key,
    required this.cardBackground,
    required this.primaryPurple,
  });

  final Color cardBackground;
  final Color primaryPurple;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Vamos!',
          style: TextStyle(
            color: primaryPurple,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: cardBackground,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Overall Rank',
                      style: TextStyle(
                        color: primaryPurple,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: CircleAvatar(
                      radius: 100,
                      backgroundImage: AssetImage('assets/images/tempRank.jpg'),
                    ),
                  ),
                  Center(
                    child: Text(
                      '167 XP until the next rank!',
                      style: TextStyle(
                        color: primaryPurple,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
