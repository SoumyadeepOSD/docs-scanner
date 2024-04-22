import 'package:flutter/material.dart';

class FileSelectionButton extends StatelessWidget {
  final VoidCallback pickImagesFromCamera;
  final VoidCallback pickImagesFromGalary;
  const FileSelectionButton(
      {super.key,
      required this.pickImagesFromCamera,
      required this.pickImagesFromGalary});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            child: const Icon(Icons.camera),
            onPressed: () {
              pickImagesFromCamera();
            },
          ),
          const SizedBox(
            height: 10.0,
          ),
          FloatingActionButton(
            child: const Icon(Icons.photo),
            onPressed: () {
              pickImagesFromGalary();
            },
          ),
        ],
      ),
    );
  }
}
