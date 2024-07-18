// ignore_for_file: prefer_is_empty, implementation_imports, depend_on_referenced_packages
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:docs_scanner/providers/state_providers.dart';
import 'package:docs_scanner/screens/croping_screen.dart';
import 'package:docs_scanner/screens/cameras_screen.dart';
import 'package:docs_scanner/components/blankfile.dart';
import 'package:camera/src/camera_controller.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/image_filters_names.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class CreatePdf extends StatefulWidget {
  const CreatePdf({super.key, required this.controller});
  final CameraController controller;

  @override
  State<CreatePdf> createState() => _CreatePdfState();
}

class _CreatePdfState extends State<CreatePdf> {
  var filterIndex = 0;
  List<XFile> allSelectedImages = [];

  // final List<CroppedFile> croppedImages = [];

  // *Pick images from camera
  void pickImagesFromCamera() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraScreen(
          controller: widget.controller,
          onImagesTaken: (images) {
            cropAndSaveImages(images);
          },
        ),
      ),
    );
  }

  // *Pick images from Galary
  void pickImagesFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      cropAndSaveImages(images);
    }
  }

// *Crop images
  Future<void> cropAndSaveImages(List<XFile> images) async {
    for (XFile image in images) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.deepPurpleAccent,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
        ],
      );
      if (croppedFile != null) {
        setState(() {
          allSelectedImages.add(XFile(croppedFile.path));
        });
      }
    }
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
            leading: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back_ios)),
            title: const Text(
              "Create PDF",
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
                          color: Colors.white,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 100,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        FloatingActionButton(
                                          elevation: 0.0,
                                          heroTag: "btn1",
                                          child: const Icon(Icons.camera),
                                          onPressed: () {
                                            pickImagesFromCamera();
                                          },
                                        ),
                                        const SizedBox(height: 10.0),
                                        const Text(
                                          "Capture images",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    Column(
                                      children: [
                                        FloatingActionButton(
                                          elevation: 0.0,
                                          heroTag: "btn2",
                                          child: const Icon(Icons.photo),
                                          onPressed: () async {
                                            pickImagesFromGallery();
                                          },
                                        ),
                                        const SizedBox(height: 10.0),
                                        const Text(
                                          "Choose from device",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // *Color filter
                              // allSelectedImages.length > 0
                              //     ? const ImageFiltersButtons()
                              //     : const SizedBox(),
                              // *Color filter
                            ],
                          ),
                        ),
                      ),
                      allSelectedImages.length == 0
                          ? const BlankFileComponent()
                          : Expanded(
                              child: GridView.builder(
                                gridDelegate:
                                    const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 200,
                                  mainAxisSpacing: 10,
                                  crossAxisSpacing: 10,
                                  childAspectRatio: 1,
                                ),
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
                                          // color: Colors.green,
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
                                                        const EdgeInsets.all(2),
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: Colors.white,
                                                      size: 20,
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
                                                  // *Captured images
                                                  child: Image.memory(
                                                    height: 100,
                                                    width: 200,
                                                    snapshot.data!,
                                                    fit: BoxFit.fitWidth,
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
                      allSelectedImages.length > 0
                          ? ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  fixedSize: const Size(200, 30)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CroppingScreen(
                                      allSelectedImages: allSelectedImages,
                                    ),
                                  ),
                                );
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Proceed next",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox(),
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
