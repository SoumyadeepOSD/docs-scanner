// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:docs_scanner/screens/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ionicons/ionicons.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdfx/pdfx.dart';

import 'pdf_viewer_screen.dart';

late List<CameraDescription> _cameras;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late CameraController controller;
  bool _isCameraInitialized = false;
  late StreamController<List<File>> _streamController;

  @override
  void initState() {
    super.initState();
    _streamController = StreamController<List<File>>();
    _startMonitoringDirectory();
  }

  @override
  void dispose() {
    controller.dispose();
    _streamController.close();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      controller = CameraController(_cameras[0], ResolutionPreset.max);
      await controller.initialize();
      if (!mounted) {
        return;
      }
      setState(() {
        _isCameraInitialized = true;
      });
      await _startMonitoringDirectory();
    } catch (e) {
      // Handle camera initialization error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to initialize camera: $e')),
      );
    }
  }

  Future<void> _startMonitoringDirectory() async {
    // Request storage permission
    PermissionStatus status = await Permission.manageExternalStorage.request();
    if (status.isDenied) {
      // Show a dialog to prompt the user to enable permissions from settings
      openAppSettings();
      return;
    }

    // Define the path for the SolidScanner directory
    String newPath = '/storage/emulated/0/Documents/SolidScanner';
    final solidScannerDir = Directory(newPath);

    // Ensure the directory exists or create it if it doesn't
    if (!await solidScannerDir.exists()) {
      await solidScannerDir.create(recursive: true);
    }

    // Stream the contents of the directory
    solidScannerDir.watch().listen((event) async {
      final files = solidScannerDir
          .listSync()
          .where((item) => item is File && item.path.endsWith('.pdf'))
          .cast<File>()
          .toList();
      _streamController.add(files);
    });

    // Initial fetch of files
    final initialFiles = solidScannerDir
        .listSync()
        .where((item) => item is File && item.path.endsWith('.pdf'))
        .cast<File>()
        .toList();
    _streamController.add(initialFiles);
  }

  void _openPdf(File file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(pdfPath: file.path),
      ),
    );
  }

  void _deletePDF(File file) async {
    try {
      await file.delete();
      final solidScannerDir =
          Directory('/storage/emulated/0/Documents/SolidScanner');
      final files = solidScannerDir
          .listSync()
          .where((item) => item is File && item.path.endsWith('.pdf'))
          .cast<File>()
          .toList();
      _streamController.add(files);
    } catch (e) {
      SnackBar(
        content: Text('Failed to delete PDF: $e'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget customIcon(String text, IconData icon, Color color, Function onTap) {
      return GestureDetector(
        onTap: () => onTap(),
        child: SizedBox(
          height: 80,
          width: 80,
          child: Column(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: color,
                ),
                child: Icon(icon, size: 20),
              ),
              Text(
                text,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Future<void> _renamePdf(File file) async {
      TextEditingController _textFieldController = TextEditingController();

      // Show a dialog to get the new name from the user
      String? newName = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Rename PDF'),
            content: TextField(
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Enter new PDF name"),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              ElevatedButton(
                child: const Text('Rename'),
                onPressed: () {
                  Navigator.pop(context, _textFieldController.text);
                },
              ),
            ],
          );
        },
      );

      if (newName != null && newName.isNotEmpty) {
        try {
          String newPath =
              file.path.replaceAll(RegExp(r'[^/]+$'), newName + '.pdf');
          File newFile = await file.rename(newPath);

          setState(() {
            file = newFile;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('PDF Renamed to ${newFile.path.split('/').last}')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to rename PDF: $e')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10.0),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Solid Scanner",
                  style: GoogleFonts.roboto(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const Icon(
                  Icons.qr_code_scanner,
                  color: Colors.grey,
                  size: 30,
                ),
                const Icon(
                  Icons.search,
                  size: 30,
                  color: Colors.grey,
                ),
                const Icon(
                  Icons.menu,
                  size: 30,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(
              height: 50.0,
            ),
            // *First row Features
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customIcon(
                  "Create PDF",
                  Icons.picture_as_pdf,
                  Colors.green.shade100,
                  () {
                    if (_isCameraInitialized) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreatePdf(
                            controller: controller,
                          ),
                        ),
                      );
                    } else {}
                  },
                ),
                customIcon("Merge PDF", Icons.format_align_left_sharp,
                    Colors.orange.shade100, () {}),
                customIcon(
                    "Split PDF", Icons.splitscreen, Colors.red.shade100, () {}),
                customIcon(
                    "Signature", Ionicons.pencil, Colors.blue.shade100, () {}),
              ],
            ),
            // *Second row Features
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customIcon("OCR", Ionicons.scan_circle_outline,
                    Colors.amber.shade100, () {}),
                customIcon("Password", Ionicons.lock_closed_outline,
                    Colors.deepPurple.shade100, () {}),
                customIcon("Drawing", Ionicons.color_palette_outline,
                    Colors.pink.shade100, () {}),
                customIcon("Conversion", Ionicons.trail_sign_outline,
                    Colors.cyan.shade100, () {}),
              ],
            ),
            // *Divider
            const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
            const SizedBox(
              height: 30.0,
            ),
            // *Recent Files
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Recent Files",
                  style: GoogleFonts.roboto(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_sharp,
                  size: 30,
                  color: Colors.blueAccent.shade700,
                ),
              ],
            ),
            // *Recent Files in series
            Expanded(
              child: StreamBuilder<List<File>>(
                stream: _streamController.stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No PDF files found.'));
                  } else {
                    final pdfFiles = snapshot.data!;
                    return ListView.builder(
                      itemCount: pdfFiles.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey.shade700,
                            ),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.picture_as_pdf,
                              color: Colors.red,
                            ),
                            title: Text(
                              pdfFiles[index].path.split('/').last,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Ionicons.pencil,
                                      color: Colors.black,
                                    ),
                                    onPressed: () {
                                      _renamePdf(pdfFiles[index]);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outlined,
                                      color: Colors.red,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) =>
                                            AlertDialog(
                                          title: const Text('Delete PDF'),
                                          content: const Text(
                                              'Are you sure you want to delete this PDF?'),
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Delete'),
                                              onPressed: () {
                                                _deletePDF(pdfFiles[index]);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              // Handle PDF file tap (e.g., open the PDF)

                              _openPdf(pdfFiles[index]);
                            },
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
