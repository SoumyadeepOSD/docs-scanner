import 'dart:io';

import 'package:camera/camera.dart';
import 'package:docs_scanner/providers/camera_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen(
      {required this.controller, super.key, required this.removeImage});
  final CameraController controller;
  final Function removeImage;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<XFile> _imagePaths = [];
  bool isFlashTurnedOn = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<CameraImageProvider>(builder: (context, value, child) {
      return Scaffold(
          body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            child: CameraPreview(widget.controller),
          ),
          if (_imagePaths.isNotEmpty)
            Positioned(
              bottom: 100,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                height: 100,
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _imagePaths.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(5),
                          child: Image.file(
                            File(_imagePaths[index].path),
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
                                widget.removeImage(index);
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
                      onPressed: () {
                        setState(() {
                          isFlashTurnedOn = !isFlashTurnedOn;
                        });
                      },
                      child: Icon(
                          isFlashTurnedOn ? Icons.flash_on : Icons.flash_off),
                    ),
                    FloatingActionButton(
                      onPressed: () async {
                        if (widget.controller.value.isTakingPicture) {
                          return;
                        }
                        try {
                          await widget.controller.setFlashMode(isFlashTurnedOn
                              ? FlashMode.always
                              : FlashMode.off);
                          XFile picture = await widget.controller.takePicture();
                          setState(() {
                            _imagePaths.add(picture);
                          });
                        } on CameraException catch (e) {
                          debugPrint("Error occured while taking picture: $e");
                          return;
                        }
                      },
                      child: const Icon(Icons.camera_alt_outlined),
                    ),
                    FloatingActionButton(
                      backgroundColor: Colors.green,
                      onPressed: () {
                        value.setImages(_imagePaths);
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Done",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ))
        ],
      ));
    });
  }
}
