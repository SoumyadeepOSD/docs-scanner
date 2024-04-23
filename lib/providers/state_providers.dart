// ignore_for_file: non_constant_identifier_names
import "package:camera/camera.dart";
import "package:flutter/material.dart";

class CameraImageProvider extends ChangeNotifier {
  var filterIndex = 0;
  List<XFile> allSelectedCameraImages = [];

  void setGalaryImages(List<XFile> images) {
    allSelectedCameraImages = images;
    notifyListeners();
  }

  void setFilters(int index) {
    filterIndex = index;
    notifyListeners();
  }
}
