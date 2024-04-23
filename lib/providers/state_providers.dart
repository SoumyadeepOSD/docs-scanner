// ignore_for_file: non_constant_identifier_names

import "package:camera/camera.dart";
import "package:flutter/material.dart";

class CameraImageProvider extends ChangeNotifier {
  // list of images taken by camera
  late List<XFile>? selectedCameraImages = [];
  // list of images selected from gallery
  late List<XFile>? selectedGalaryImages = [];
  // list of overall selected images
  late List<XFile>? selectedImages = [];
  var filterIndex = 0;

  // setter for camera images
  void setCameraImages(XFile images) {
    selectedCameraImages!.add(images);
    notifyListeners();
  }

  // setter for gallery images
  void setGalaryImages(XFile images) {
    selectedGalaryImages!.add(images);
    notifyListeners();
  }

  // setter for overall images
  void setImages() {
    selectedImages!.addAll(selectedCameraImages!);
    selectedImages!.addAll(selectedGalaryImages!);
    notifyListeners();
  }

  // remove images from camera
  void removeCameraImages(int index) {
    selectedCameraImages!.removeAt(index);
    notifyListeners();
  }

  // remove images from gallery
  void removeGalaryImages(int index) {
    selectedGalaryImages!.removeAt(index);
    notifyListeners();
  }

  // remove images from overall
  void removeImages(int index) {
    selectedImages!.removeAt(index);
    notifyListeners();
  }

  // setter for filters
  void setFilters(int index) {
    filterIndex = index;
    notifyListeners();
  }
}
