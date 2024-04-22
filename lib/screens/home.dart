// ignore_for_file: prefer_is_empty

import 'dart:io';
import 'dart:ui';
import 'package:camera/src/camera_controller.dart';
import 'package:docs_scanner/components/blankfile.dart';
import 'package:docs_scanner/components/file_selection_buttons.dart';
import 'package:docs_scanner/components/image_filters.dart';
import 'package:docs_scanner/providers/camera_image_provider.dart';
import 'package:docs_scanner/screens/cameras_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:image/image.dart' as img;
import '../constants/image_filters_names.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.controller});
  final CameraController controller;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ImagePicker picker = ImagePicker();
  late List<XFile>? _selectedImages = [];
  var filterIndex = 0;

  void pickImagesFromGalary() async {
    try {
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages!.addAll(images);
        });
      }
    } catch (err) {
      print(err);
    }
  }

  void pickImagesFromCamera() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          controller: widget.controller,
          removeImage: removeImage,
        ),
      ),
    );
  }

  void removeImage(int index) {
    setState(() {
      _selectedImages!.removeAt(index);
    });
  }

  Future<Uint8List> buildPdf(PdfPageFormat format) async {
    // Create the Pdf document
    final pw.Document pdf = pw.Document();
    final List<String> images =
        _selectedImages!.map((image) => image.path).toList();

    // Calculate the maximum height of the content on a single page
    final double maxHeight = format.availableHeight - 40; // Adjust as needed

    // Add pages with images
    for (int i = 0; i < images.length; i++) {
      final imageFile = File(images[i]);
      if (!imageFile.existsSync()) continue;
      final imageProvider = pw.MemoryImage(imageFile.readAsBytesSync());

      // Calculate the height of the image
      final img.Image? image = img.decodeImage(imageFile.readAsBytesSync());
      final double imageHeight =
          image!.height.toDouble() * format.width / image.width.toDouble();

      // Check if the image fits on the current page
      if (imageHeight > maxHeight) {
        // Add a new page
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(imageProvider),
              );
            },
          ),
        );
      } else {
        // Add the image to the current page
        pdf.addPage(
          pw.Page(
            pageFormat: format,
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(imageProvider),
              );
            },
          ),
        );
      }
    }

    // Build and return the final Pdf file data
    return await pdf.save();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraImageProvider>(
      builder: (context, value, child) {
        List<XFile> newImages = value.selectedImages!
            .where((image) => !_selectedImages!
                .map((selectedImage) => selectedImage.path)
                .contains(image.path))
            .toList();
        _selectedImages = [..._selectedImages!, ...newImages];
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              "Solid Scanner",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          body: Stack(children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 200,
                      width: MediaQuery.of(context).size.width,
                      child: Container(
                        child: Column(
                          children: [
                            FileSelectionButton(
                              pickImagesFromCamera: pickImagesFromCamera,
                              pickImagesFromGalary: pickImagesFromGalary,
                            ),
                            _selectedImages!.length > 0
                                ? const ImageFiltersButtons()
                                : const SizedBox(),
                            _selectedImages!.length > 0
                                ? ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.black)),
                                    onPressed: () {},
                                    child: const Text(
                                      "Proceed next",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                    _selectedImages!.length == 0
                        ? const BlankFileComponent()
                        : Expanded(
                            child: ListView.builder(
                              itemCount: _selectedImages!.length,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: _selectedImages!.length > 0
                                            ? GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    removeImage(index);
                                                  });
                                                },
                                                child: Container(
                                                  decoration:
                                                      const BoxDecoration(
                                                    color: Colors.red,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(5),
                                                  child: const Icon(
                                                    Icons.close,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.red),
                                        ),
                                        child: ColorFiltered(
                                          colorFilter: ColorFilter.matrix(
                                              Float64List.fromList(
                                            customColorfilters[
                                                value.filterIndex],
                                          )),
                                          child: Image.file(
                                            File(
                                              _selectedImages![index].path,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.blue[200],
                                        child: Center(
                                          child: Text(
                                            (index + 1).toString(),
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}
