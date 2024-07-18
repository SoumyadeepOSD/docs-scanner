import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/state_providers.dart';

class ImageFiltersButtons extends StatefulWidget {
  const ImageFiltersButtons({Key? key}) : super(key: key);

  @override
  State<ImageFiltersButtons> createState() => _ImageFiltersButtonsState();
}

class _ImageFiltersButtonsState extends State<ImageFiltersButtons> {
  List<String> customColorfiltersNames = [
    "Normal",
    "Board",
    "90's",
    "Gray",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G"
  ];
  @override
  Widget build(BuildContext context) {
    return Consumer<CameraImageProvider>(
      builder: (context, value, child) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: customColorfiltersNames.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(5),
                width: 130,
                child: ElevatedButton.icon(
                  onPressed: () {
                    value.setFilters(index);
                  },
                  icon: const Icon(Icons.format_color_fill_rounded),
                  label: Text(
                    customColorfiltersNames[index],
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (value.filterIndex == index) {
                          return Colors.blue[200]!; // Color when selected
                        }
                        return Colors.black; // Default color
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
