import 'package:flutter/material.dart';
import 'package:voquadro/src/hex_color.dart';

class PublicSpeakingFeedbackModal extends StatefulWidget {
  final String sessionDate;
  final int paceWPM;
  final int fillerCount;
  final String qualitativeFeedback;

  const PublicSpeakingFeedbackModal({
    super.key,
    required this.sessionDate,
    required this.paceWPM,
    required this.fillerCount,
    required this.qualitativeFeedback,
  });

  @override
  State<PublicSpeakingFeedbackModal> createState() =>
      _PublicSpeakingFeedbackModalState();
}

class _PublicSpeakingFeedbackModalState
    extends State<PublicSpeakingFeedbackModal> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color purpleDark = '49416D'.toColor();

    return Dialog(
      backgroundColor: const Color(0xFFF0E6F6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: purpleDark.withValues(alpha: 26)),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Feedback',
                  style: TextStyle(
                    color: purpleDark,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Swipeable Content
            SizedBox(
              height: 400,
              child: PageView(
                controller: _pageController,
                onPageChanged: (int page) =>
                    setState(() => _currentPage = page),
                children: [
                  _buildStatsPage(purpleDark),
                  _buildFeedbackPage(purpleDark),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.sessionDate,
                  style: TextStyle(
                    color: purpleDark,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    _buildPageIndicator(0),
                    const SizedBox(width: 8),
                    _buildPageIndicator(1),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsPage(Color purpleDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCircle(
          title: 'Pace Control',
          value: widget.paceWPM.toString(),
          unit: 'WPM',
          purpleDark: purpleDark,
        ),
        _buildStatCircle(
          title: 'Filler Word Control',
          value: widget.fillerCount.toString(),
          unit: 'Fillers',
          purpleDark: purpleDark,
        ),
      ],
    );
  }

  Widget _buildStatCircle({
    required String title,
    required String value,
    required String unit,
    required Color purpleDark,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: purpleDark,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(color: purpleDark, shape: BoxShape.circle),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackPage(Color purpleDark) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          widget.qualitativeFeedback,
          style: TextStyle(
            color: purpleDark,
            fontSize: 18,
            height: 1.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int pageIndex) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _currentPage == pageIndex
            ? '49416D'.toColor()
            : Colors.transparent,
        border: Border.all(
          color: _currentPage == pageIndex
              ? Colors.transparent
              : Colors.grey.shade400,
          width: 2,
        ),
      ),
    );
  }
}
