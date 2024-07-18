// ignore_for_file: must_be_immutable, use_build_context_synchronously

import 'dart:io';
import 'dart:typed_data';
import 'package:docs_scanner/screens/pdf_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:animated_progress/animated_progress.dart';
import 'package:toastification/toastification.dart';

class CroppingScreen extends StatefulWidget {
  CroppingScreen({super.key, required this.allSelectedImages});
  List<XFile> allSelectedImages = [];

  @override
  State<CroppingScreen> createState() => _CroppingScreenState();
}

class _CroppingScreenState extends State<CroppingScreen> {
  final ValueNotifier<double> _progressNotifier = ValueNotifier<double>(0);
  int selectedFilterIndex = 0;
  List<Uint8List> filteredImageBytes = [];
  List<Uint8List> originalImageBytes = [];
  bool isApplyingFilter = false;
  bool isPdfGenerating = false;
  File? pdfFile;
  bool isPageNumberAdded = false;
  bool isBorderedAdded = false;
  bool isOpenSheet = false;

  bool isNameChange = false;
  bool noNameChange = false;

  String? modifiedName;
  Color pickerColor = const Color(0xFFC0EDFA);
  Color currentColor = const Color(0xFFFFFFFF);

  TextEditingController pdfNameController = TextEditingController();
  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
    });
  }

  List<img.Image Function(img.Image)> filterFunctions = [
    (image) => img.copyResize(image, width: image.width), // Normal
    (image) => img.grayscale(image), // Grayscale
    (image) => img.sepia(image), // Sepia
    (image) => img.invert(image), // Invert
    (image) => img.adjustColor(image, gamma: 1.5), // Adjust color
    (image) => img.monochrome(image), // Monoschrome
    (image) => img.vignette(image), // Vintage
    (image) => img.contrast(image, contrast: 150), // Contrast
    (image) => img.gaussianBlur(image, radius: 10), // Gaussian Blur
    (image) => img.gamma(image, gamma: 1.5), // Gamma
    (image) => img.edgeGlow(image), // EdgeGlow
    (image) => img.emboss(image), // Emboss
    (image) => img
        .convolution(image, filter: [1, 1, 1, 1, 1, 1, 1, 1, 1]), // Convolution
    (image) => img.billboard(image), // Billboard
    (image) => img.sketch(image), // Sketch
  ];
  @override
  void initState() {
    super.initState();
    loadInitialImages();
  }

  Future<void> loadInitialImages() async {
    originalImageBytes =
        await Future.wait(widget.allSelectedImages.map((image) async {
      final bytes = await image.readAsBytes();
      return bytes; // Store original bytes initially
    }));
    filteredImageBytes = List.from(
        originalImageBytes); // Initialize filtered images with original
    setState(() {});
  }

  Future<Uint8List> applyColorFilter(
      Uint8List imageBytes, int filterIndex) async {
    img.Image image = img.decodeImage(imageBytes)!;
    image = filterFunctions[filterIndex](image);
    return Uint8List.fromList(img.encodeJpg(image));
  }

  PdfColor flutterColorToPdfColor(Color color) {
    return PdfColor.fromInt(color.value);
  }

  void showToast(String message) {
    toastification.show(
      title: Text(message),
      type: ToastificationType.error,
      animationDuration: const Duration(milliseconds: 1000),
      autoCloseDuration: const Duration(seconds: 5),
      style: ToastificationStyle.fillColored,
    );
  }

  void createNameChangePopup() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Enter new name",
          style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: pdfNameController,
        ),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                isNameChange = false;
                pdfNameController.clear();
              });
            },
          ),
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              setState(() {
                modifiedName = pdfNameController.text;
              });
              Navigator.of(context).pop();
              if (pdfNameController.text.isEmpty) {
                setState(() {
                  isNameChange = false;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> createPdf() async {
    setState(() {
      _progressNotifier.value = 0;
    });

    final pdf = pw.Document();
    final totalImages = widget.allSelectedImages.length;

    for (var i = 0; i < totalImages; i++) {
      final filteredBytes =
          await applyColorFilter(filteredImageBytes[i], selectedFilterIndex);
      final image = pw.MemoryImage(filteredBytes);
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(20), // Add margin here
          build: (pw.Context context) {
            return pw.Column(
              children: [
                pw.Expanded(
                  child: pw.Container(
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(
                          color: isBorderedAdded
                              ? PdfColor.fromInt(pickerColor.value)
                              : PdfColors.white,
                          width: 2),
                      color: PdfColor.fromInt(pickerColor.value),
                    ),
                    padding: const pw.EdgeInsets.all(10),
                    child: pw.Center(child: pw.Image(image)),
                  ),
                ),
                pw.SizedBox(height: 10),
                if (isPageNumberAdded)
                  pw.Text(
                    'Page ${i + 1}', // Add page number here
                    style: const pw.TextStyle(fontSize: 12),
                  )
              ],
            );
          },
        ),
      );

      // Update progress
      _progressNotifier.value = (i + 1) / totalImages;
    }

    // Generate the filename with current date and time
    final now = DateTime.now();
    final formattedDate =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final formattedTime =
        '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final filename = modifiedName == null
        ? 'document_${formattedTime}_$formattedDate.pdf'
        : '$modifiedName.pdf';

    final outputDir = await getApplicationDocumentsDirectory();
    final outputFile = File('${outputDir.path}/$filename');
    await outputFile.writeAsBytes(await pdf.save());

    setState(() {
      pdfFile = outputFile; // Save the generated PDF file
      isPdfGenerating = false;
      _progressNotifier.value = 0.0;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfResultScreen(pdfFile: pdfFile!),
      ),
    );
  }

  void applyFilter(int index) async {
    setState(() {
      selectedFilterIndex = index;
      _progressNotifier.value = 0; // Reset progress
      isApplyingFilter = true; // Show progress indicator
    });

    // Apply filter to all images
    filteredImageBytes = await Future.wait(
      originalImageBytes.map((imageBytes) async {
        await Future.delayed(
            const Duration(milliseconds: 100)); // Allow UI to update
        return await applyColorFilter(imageBytes, selectedFilterIndex);
      }),
    );

    setState(() {
      isApplyingFilter = false; // Hide progress indicator
    }); // Update the UI
  }

  void openBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow full height
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height, // Full height
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              const Text(
                "Pick Page Color",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: changeColor,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Select",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void onCreatePdfButtonPressed() {
    setState(() {
      isPdfGenerating = true;
    });
    createPdf();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Filters",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(0),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 0
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Normal',
                        style: TextStyle(
                            color: selectedFilterIndex == 0
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(1),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 1
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Grayscale',
                        style: TextStyle(
                            color: selectedFilterIndex == 1
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(2),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 2
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Sepia',
                        style: TextStyle(
                            color: selectedFilterIndex == 2
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(3),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 3
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Invert',
                        style: TextStyle(
                            color: selectedFilterIndex == 3
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(4),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 4
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Adjust Color',
                        style: TextStyle(
                            color: selectedFilterIndex == 4
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(5),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 5
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Monoschrome',
                        style: TextStyle(
                            color: selectedFilterIndex == 5
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(6),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 6
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Vinatage',
                        style: TextStyle(
                            color: selectedFilterIndex == 6
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(7),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 7
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Contrast',
                        style: TextStyle(
                            color: selectedFilterIndex == 7
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(8),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 8
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Guassian Blue',
                        style: TextStyle(
                            color: selectedFilterIndex == 8
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(9),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 9
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Gamma',
                        style: TextStyle(
                            color: selectedFilterIndex == 9
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(10),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 10
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'EdgeGlow',
                        style: TextStyle(
                            color: selectedFilterIndex == 10
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(11),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 11
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Emboss',
                        style: TextStyle(
                            color: selectedFilterIndex == 11
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(12),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 12
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Convolutional',
                        style: TextStyle(
                            color: selectedFilterIndex == 12
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(13),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 13
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Billboard',
                        style: TextStyle(
                            color: selectedFilterIndex == 13
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      onPressed: () => applyFilter(14),
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        backgroundColor: selectedFilterIndex == 14
                            ? Colors.black
                            : Colors.blue.shade100,
                      ),
                      child: Text(
                        'Sketch',
                        style: TextStyle(
                            color: selectedFilterIndex == 14
                                ? Colors.white
                                : Colors.black),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30.0,
              ),
              // Container(),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      child: Row(
                        children: [
                          const Text("Add page number(s): "),
                          Checkbox(
                            checkColor: Colors.blue,
                            fillColor: MaterialStateProperty.all(Colors.white),
                            value: isPageNumberAdded,
                            onChanged: (bool? value) {
                              setState(() {
                                isPageNumberAdded = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),

                    // *Add border
                    Expanded(
                      child: Row(
                        children: [
                          const Text("Add border(s): "),
                          Row(
                            children: [
                              Checkbox(
                                checkColor: Colors.blue,
                                fillColor:
                                    MaterialStateProperty.all(Colors.white),
                                value: isBorderedAdded,
                                onChanged: (bool? value) {
                                  setState(() {
                                    isBorderedAdded = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () {
                              openBottomSheet();
                              setState(() {
                                isOpenSheet = !isOpenSheet;
                              });
                            },
                            icon: const Icon(
                              Icons.color_lens,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: filteredImageBytes.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black, width: 2.0),
                      ),
                      child: Image.memory(filteredImageBytes[index],
                          fit: BoxFit.cover),
                    );
                  },
                ),
              ),
            ],
          ),
          isApplyingFilter
              ? Container(
                  color: Colors.black45,
                  child: Center(
                      child: Column(
                    children: [
                      SizedBox(
                          height: MediaQuery.of(context).size.height * 0.3),
                      const AnimatedCircularProgress(
                        valueColor: Colors.green,
                        valueWidth: 5,
                        isSpining: true,
                      ),
                      const Text(
                        'Applying filter...',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ],
                  )),
                )
              : const SizedBox(),
          Positioned(
            bottom: 80,
            left: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Add custom pdf name?",
                  // style: TextStyle(fontSize: 18),
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                const Text(
                  "Yes",
                  style: TextStyle(fontSize: 18),
                ),
                Checkbox(
                  checkColor: Colors.white,
                  activeColor: Colors.blue,
                  value: isNameChange,
                  onChanged: (bool? trueChange) {
                    setState(() {
                      isNameChange = trueChange!;
                      if (isNameChange) {
                        noNameChange = false;
                      }
                      createNameChangePopup();
                    });
                  },
                ),
                const Text(
                  "No",
                  style: TextStyle(fontSize: 18),
                ),
                Checkbox(
                  checkColor: Colors.white,
                  activeColor: Colors.blue,
                  value: noNameChange,
                  onChanged: (bool? noChange) {
                    setState(() {
                      pdfNameController.clear();
                      noNameChange = noChange!;
                      if (noNameChange) {
                        isNameChange = false;
                      }
                    });
                  },
                )
              ],
            ),
          ),
          // *Button section
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isNameChange || noNameChange
                    ? Colors.black
                    : Colors.black38,
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              onPressed: isPdfGenerating
                  ? null
                  : () {
                      // Disable button if generating
                      if (isNameChange || noNameChange) {
                        onCreatePdfButtonPressed();
                      } else {
                        showToast("Please fill the above check box");
                      }
                    },
              child: isPdfGenerating // Conditional loading text
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Generating PDF...",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ],
                    )
                  : Text(
                      "Create PDF (${widget.allSelectedImages.length} pages)",
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
