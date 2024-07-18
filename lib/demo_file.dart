import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DemoFile extends StatefulWidget {
  const DemoFile({super.key});

  @override
  State<DemoFile> createState() => _DemoFileState();
}

class _DemoFileState extends State<DemoFile> {
  @override
  Widget build(BuildContext context) {
    Future<void> listFilesInDirectory(String path) async {
      try {
        final directory = Directory(path);
        List<FileSystemEntity> files = directory.listSync();

        if (files.isEmpty) {
          print('No files found in $path');
        } else {
          print('Files in $path:');
          for (FileSystemEntity file in files) {
            if (file is File) {
              print('File: ${file.path}');
            } else if (file is Directory) {
              print('Directory: ${file.path}');
            }
          }
        }
      } catch (e) {
        print(e);
      }
    }

    Future<void> addFileToDirectory(
        String path, String fileName, String content) async {
      try {
        final file = File('$path/$fileName');
        await file.writeAsString(content);
        print('File added: ${file.path}');
      } catch (e) {
        print(e);
      }
    }

    Future<void> checkPermission() async {
      var status = await Permission.manageExternalStorage.request();

      try {
        if (status.isGranted) {
          // Define the desired path manually
          String newPath = '/storage/emulated/0/Documents/SolidScanner';

          // Check if the directory exists
          bool directoryExists = await Directory(newPath).exists();

          if (!directoryExists) {
            // Create the directory
            await Directory(newPath).create(recursive: true);
            print('Directory created: $newPath');
          }

          // List files in the directory
          await listFilesInDirectory(newPath);

          // Optionally, add a file to the directory
          await addFileToDirectory(
              newPath, 'example.txt', 'This is an example file.');
        } else {
          print('Storage permission not granted');
        }
      } catch (e) {
        print(e);
      }
    }

    return Scaffold(
      body: Container(
        child: Center(
          child: ElevatedButton(
            onPressed: () {
              checkPermission();
            },
            child: const Text("Press"),
          ),
        ),
      ),
    );
  }
}
