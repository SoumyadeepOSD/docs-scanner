// ignore_for_file: use_build_context_synchronously

import 'package:docs_scanner/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toastification/toastification.dart';

class PdfResultScreen extends StatefulWidget {
  final File pdfFile;

  const PdfResultScreen({super.key, required this.pdfFile});

  @override
  State<PdfResultScreen> createState() => _PdfResultScreenState();
}

class _PdfResultScreenState extends State<PdfResultScreen> {
  void showToast(String message, ToastificationType type) {
    toastification.show(
      title: Text(message),
      type: type,
      animationDuration: const Duration(milliseconds: 1000),
      autoCloseDuration: const Duration(seconds: 5),
      style: ToastificationStyle.fillColored,
    );
  }

  Future<void> _downloadPdf() async {
    Directory? directory;
    try {
      // Request storage permission
      PermissionStatus status =
          await Permission.manageExternalStorage.request();
      if (status.isDenied) {
        openAppSettings();
        return;
      }

      // Define the path for the SolidScanner directory
      String newPath = '/storage/emulated/0/Documents/SolidScanner';
      final solidScannerDir = Directory(newPath);

      // Create the directory if it doesn't exist
      if (!await solidScannerDir.exists()) {
        await solidScannerDir.create(recursive: true);
      }

      // Define the download path
      String fileName = widget.pdfFile.path.split('/').last;
      String downloadPath = '${solidScannerDir.path}/$fileName';

      // Check if the file already exists
      File newFile = File(downloadPath);
      if (await newFile.exists()) {
        // File already exists, append a number to the file name
        int counter = 1;
        String baseName = fileName.split('.').first;
        String extension = fileName.split('.').last;
        while (await newFile.exists()) {
          downloadPath =
              '${solidScannerDir.path}/$baseName($counter).$extension';
          newFile = File(downloadPath);
          counter++;
        }
      }

      // Copy the file to the download path
      final copiedFile = await widget.pdfFile.copy(downloadPath);

      // Show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF Downloaded to ${copiedFile.path}')),
      );
      showToast("PDF downloaded successfully", ToastificationType.success);
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to download PDF: $e')),
      );
      print('Failed to download PDF: $e');
      showToast('Failed to download PDF: $e', ToastificationType.error);
    }
  }

  Future<void> _sharePdf() async {
    try {
      // Share the PDF file
      await Share.shareXFiles([XFile(widget.pdfFile.path)],
          text: 'Check out this PDF!');
    } catch (e) {
      // Show an error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Generated"),
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              "/home",
              (route) => false,
            );
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Center(
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          width: MediaQuery.of(context).size.width * 0.8,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.red,
              style: BorderStyle.solid,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.picture_as_pdf,
                color: Colors.red,
                size: 100,
              ),
              const SizedBox(
                height: 20.0,
              ),
              Text(
                widget.pdfFile.path.split('/').last,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(
                      Ionicons.download_outline,
                      color: Colors.cyan,
                    ),
                    label: const Text(
                      "Download",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: _downloadPdf,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(
                      Ionicons.share_outline,
                      color: Colors.cyan,
                    ),
                    label: const Text(
                      "Share",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: _sharePdf,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
