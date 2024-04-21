// ignore_for_file: non_constant_identifier_names

import "package:camera/camera.dart";
import "package:flutter/material.dart";

class CameraImageProvider extends ChangeNotifier {
  late List<XFile>? selectedImages = [];

  void setImages(List<XFile> images) {
    selectedImages = images;
    notifyListeners();
  }
}
