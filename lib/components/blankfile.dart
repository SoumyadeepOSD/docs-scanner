import 'package:flutter/material.dart';

class BlankFileComponent extends StatelessWidget {
  const BlankFileComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Column(
        children: [
          Icon(
            Icons.file_copy_outlined,
            size: 50,
            color: Colors.black54,
          ),
          SizedBox(
            height: 10,
          ),
          Text("Press + icon to select images"),
        ],
      ),
    );
  }
}
