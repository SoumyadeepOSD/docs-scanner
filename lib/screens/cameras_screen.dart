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
  var _zoomLevel = 0.0;

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
                    height: 130,
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
                              left: 0,
                              child: Chip(
                                label: Text(
                                  (index + 1).toString(),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
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
                            await widget.controller.setZoomLevel(_zoomLevel);
                            XFile picture =
                                await widget.controller.takePicture();
                            setState(() {
                              selectedCameraImages?.add(picture);
                            });
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
                          widget.controller.setFlashMode(FlashMode.off);
                          value.setGalaryImages(selectedCameraImages!);
                          _handleImagesTaken(
                              selectedCameraImages!); // Call the onImagesTaken callback
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
              Positioned(
                bottom: 100,
                left: 175,
                child: Text(
                  _zoomLevel.toStringAsFixed(2),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Slider(
                  value: _zoomLevel,
                  onChanged: (newZoomLevel) {
                    setState(
                      () {
                        _zoomLevel = newZoomLevel;
                        widget.controller.setZoomLevel(newZoomLevel);
                      },
                    );
                  },
                  min: 0.0,
                  max: 8.0,
                  label: _zoomLevel.toString(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
