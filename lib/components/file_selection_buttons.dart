import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FileSelectionButton extends StatelessWidget {
  final VoidCallback pickImagesFromCamera;
  final VoidCallback pickImagesFromGalary;
  const FileSelectionButton(
      {super.key,
      required this.pickImagesFromCamera,
      required this.pickImagesFromGalary});

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, value, child) {
      return SizedBox(
        height: 100,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FloatingActionButton(
              heroTag: "btn1",
              child: const Icon(Icons.camera),
              onPressed: () {
                pickImagesFromCamera();
              },
            ),
            const SizedBox(
              height: 10.0,
            ),
            FloatingActionButton(
              heroTag: "btn2",
              child: const Icon(Icons.photo),
              onPressed: () {
                pickImagesFromGalary();
              },
            ),
          ],
        ),
      );
    });
  }
}
