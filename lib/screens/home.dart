// ignore_for_file: prefer_is_empty

import 'dart:io';
import 'package:camera/src/camera_controller.dart';
import 'package:docs_scanner/components/blankfile.dart';
import 'package:docs_scanner/components/file_selection_buttons.dart';
import 'package:docs_scanner/providers/camera_image_provider.dart';
import 'package:docs_scanner/screens/cameras_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.controller});
  final CameraController controller;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final ImagePicker picker = ImagePicker();
  late List<XFile>? _selectedImages = [];

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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _selectedImages!.length == 0
                        ? const BlankFileComponent()
                        : const SizedBox(),
                    FileSelectionButton(
                      pickImagesFromCamera: pickImagesFromCamera,
                      pickImagesFromGalary: pickImagesFromGalary,
                    ),
                    Expanded(
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
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: const EdgeInsets.all(5),
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
                                  child: Image.file(
                                    File(
                                      _selectedImages![index].path,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
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
