import 'dart:io';
import 'package:camera/camera.dart';
import 'package:docs_scanner/providers/state_providers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen(
      {Key? key, required this.controller, required this.onImagesTaken})
      : super(key: key);

  final CameraController controller;
  final void Function(List<XFile> images) onImagesTaken;
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool isFlashTurnedOn = false;
  List<XFile>? selectedCameraImages = [];

  void _handleImagesTaken(List<XFile> images) {
    widget.onImagesTaken(images);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CameraImageProvider>(
      builder: (context, value, child) {
        return Scaffold(
          body: Stack(
            children: [
              SizedBox(
                height: double.infinity,
                child: CameraPreview(widget.controller),
              ),
              if (selectedCameraImages!.isNotEmpty)
                Positioned(
                  bottom: 100,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10.0),
                    height: 100,
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedCameraImages!.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(5),
                              child: Image.file(
                                File(selectedCameraImages![index].path),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedCameraImages?.removeAt(index);
                                  });
                                },
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20.0,
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      },
                    ),
                  ),
                ),
              Positioned(
                bottom: 20,
                child: Container(
                  color: Colors.redAccent,
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        key: const Key('flashButton'),
                        onPressed: () {
                          setState(() {
                            isFlashTurnedOn = !isFlashTurnedOn;
                          });
                        },
                        child: Icon(
                            isFlashTurnedOn ? Icons.flash_on : Icons.flash_off),
                      ),
                      FloatingActionButton(
                        key: const Key('cameraButton'),
                        onPressed: () async {
                          if (widget.controller.value.isTakingPicture) {
                            return;
                          }
                          try {
                            await widget.controller.setFlashMode(isFlashTurnedOn
                                ? FlashMode.always
                                : FlashMode.off);
                            XFile picture =
                                await widget.controller.takePicture();
                            setState(() {
                              selectedCameraImages?.add(picture);
                            });
                            _handleImagesTaken([picture]);
                          } on CameraException catch (e) {
                            debugPrint(
                                "Error occured while taking picture: $e");
                            return;
                          }
                        },
                        child: const Icon(Icons.camera_alt_outlined),
                      ),
                      FloatingActionButton(
                        key: const Key('doneButton'),
                        heroTag: "btn4",
                        backgroundColor: Colors.green,
                        onPressed: () {
                          value.setGalaryImages(selectedCameraImages!);
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          "Done",
                          style: TextStyle(color: Colors.white),
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
