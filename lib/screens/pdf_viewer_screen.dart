import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfPath;

  const PdfViewerScreen({Key? key, required this.pdfPath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pdfPinchController = PdfControllerPinch(
      document: PdfDocument.openFile(pdfPath),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(pdfPath.split('/').last),
      ),
      body: PdfViewPinch(
        controller: pdfPinchController,
        scrollDirection: Axis.vertical,
        builders: PdfViewPinchBuilders<DefaultBuilderOptions>(
          options: const DefaultBuilderOptions(),
          documentLoaderBuilder: (_) => const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
