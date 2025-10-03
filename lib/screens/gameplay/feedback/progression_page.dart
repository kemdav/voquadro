import 'package:flutter/material.dart';

class ProgressionPage extends StatelessWidget {
  const ProgressionPage({
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
          'YIPEEE',
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
                  ProgressBarsWithLabelWidget(
                    primaryPurple: primaryPurple,
                    progressLabel: 'Practice lvl',
                    fontSize: 10,
                    value: 0.25,
                    progressBarHeight: 20,
                  ),
                  SizedBox(height: 10),
                  ProgressBarsWithLabelWidget(
                    primaryPurple: primaryPurple,
                    progressLabel: 'Mastery lvl',
                    fontSize: 10,
                    value: 0.5,
                    progressBarHeight: 20,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ProgressBarsWithLabelWidget(
                          primaryPurple: primaryPurple,
                          progressLabel: 'Pace Control',
                          fontSize: 10,
                          value: 0.8,
                          progressBarHeight: 10,
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ProgressBarsWithLabelWidget(
                          primaryPurple: primaryPurple,
                          progressLabel: 'Filler Word Control',
                          fontSize: 10,
                          value: 0.2,
                          progressBarHeight: 10,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  ProgressBarsWithLabelWidget(
                    primaryPurple: primaryPurple,
                    progressLabel: 'Public Speaking lvl',
                    fontSize: 10,
                    value: 0.6,
                    progressBarHeight: 20,
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/tempRank.jpg'),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Speaker Level',
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

class ProgressBarsWithLabelWidget extends StatelessWidget {
  const ProgressBarsWithLabelWidget({
    super.key,
    required this.primaryPurple,
    required this.progressLabel,
    required this.fontSize,
    required this.value,
    required this.progressBarHeight,
  });

  final Color primaryPurple;
  final String progressLabel;
  final double fontSize;
  final double value;
  final double progressBarHeight;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          progressLabel,
          style: TextStyle(
            color: primaryPurple,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        LinearProgressIndicator(value: value, minHeight: progressBarHeight),
      ],
    );
  }
}
