import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

//idk what to do with this pa
class PDFViewerPage extends StatelessWidget {
  final String title;
  final String pdfAssetPath;

  const PDFViewerPage({
    super.key,
    required this.title,
    required this.pdfAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: const Color(0xFF7962A5),
        foregroundColor: Colors.white,
      ),
      body: PDFView(
        filePath: pdfAssetPath,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: true,
        pageFling: true,
      ),
    );
  }
}
