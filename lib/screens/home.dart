// ignore_for_file: prefer_is_empty, implementation_imports, depend_on_referenced_packages
import 'package:docs_scanner/components/image_filters_component.dart';
import 'package:docs_scanner/providers/state_providers.dart';
import 'package:docs_scanner/screens/cameras_screen.dart';
import 'package:docs_scanner/components/blankfile.dart';
import 'package:camera/src/camera_controller.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/image_filters_names.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'dart:io';

class Home extends StatefulWidget {
  const Home({super.key, required this.controller});
  final CameraController controller;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var filterIndex = 0;
  List<XFile> allSelectedImages = [];

  void pickImagesFromCamera() async {
    List<XFile> newImages = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          controller: widget.controller,
          onImagesTaken: (images) {
            setState(() {
              allSelectedImages.addAll(images);
            });
          },
        ),
      ),
    );
    if (newImages.isNotEmpty) {
      setState(() {
        allSelectedImages.addAll(newImages);
      });
    }
  }

  void pickImagesFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        allSelectedImages.addAll(images);
      });
    }
  }

  Future<Uint8List> buildPdf(PdfPageFormat format, value) async {
    // Create the Pdf document
    final pw.Document pdf = pw.Document();
    final List<String> images =
        value.selectedImages.map((image) => image.path).toList();

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

  void deleteImage(int index, value) {
    setState(() {
      if (index < allSelectedImages.length) {
        allSelectedImages.removeAt(index);
      } else {
        value.allSelectedCameraImages
            .removeAt(index - allSelectedImages.length);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraImageProvider>(
      builder: (context, value, child) {
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
          body: Stack(
            children: [
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
                              SizedBox(
                                height: 100,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    FloatingActionButton(
                                      heroTag: "btn1",
                                      child: const Icon(Icons.camera),
                                      onPressed: () {
                                        pickImagesFromCamera();
                                      },
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    FloatingActionButton(
                                      heroTag: "btn2",
                                      child: const Icon(Icons.photo),
                                      onPressed: () async {
                                        pickImagesFromGallery();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              allSelectedImages.length > 0
                                  ? const ImageFiltersButtons()
                                  : const SizedBox(),
                              allSelectedImages.length > 0
                                  ? ElevatedButton(
                                      style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.black),
                                      ),
                                      onPressed: () {},
                                      child: const Text(
                                        "Proceed next",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                      ),
                      allSelectedImages.length == 0
                          ? const BlankFileComponent()
                          : Expanded(
                              child: ListView.builder(
                                itemCount: allSelectedImages.length,
                                itemBuilder: (context, index) {
                                  return FutureBuilder(
                                    future:
                                        allSelectedImages[index].readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.done &&
                                          snapshot.hasData) {
                                        return Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            children: [
                                              Positioned(
                                                top: 5,
                                                right: 5,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    deleteImage(index, value);
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
                                                ),
                                              ),
                                              Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.red),
                                                ),
                                                child: ColorFiltered(
                                                  colorFilter:
                                                      ColorFilter.matrix(
                                                    Float64List.fromList(
                                                      customColorfilters[
                                                          value.filterIndex],
                                                    ),
                                                  ),
                                                  child: Image.memory(
                                                    snapshot.data!,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                color: Colors.blue[200],
                                                child: Center(
                                                  child: Text(
                                                    (index + 1).toString(),
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      } else if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                            child: CircularProgressIndicator());
                                      } else {
                                        return const SizedBox();
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
