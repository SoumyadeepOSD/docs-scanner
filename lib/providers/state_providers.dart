// ignore_for_file: non_constant_identifier_names
import "package:flutter/material.dart";
import "package:camera/camera.dart";

class CameraImageProvider extends ChangeNotifier {
  var filterIndex = 0;
  List<XFile> allSelectedCameraImages = [];
  late final CameraController controller;

  void setGalaryImages(List<XFile> images) {
    allSelectedCameraImages = images;
    notifyListeners();
  }

  void setFilters(int index) {
    filterIndex = index;
    notifyListeners();
  }

  void setController(CameraController controller) {
    this.controller = controller;
    notifyListeners();
  }
}
