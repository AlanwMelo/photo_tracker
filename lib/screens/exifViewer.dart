import 'dart:io';

import 'package:exif/exif.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ExifViewer extends StatefulWidget {
  final FilePickerResult? result;

  const ExifViewer({Key? key, required this.result}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ExifViewerState();
}

class ExifViewerState extends State<ExifViewer> {
  List<String> exifData = [];

  @override
  void initState() {
    _loadExif(widget.result);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
              itemCount: exifData.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Text(exifData[index]),
                );
              }),
        ),
      ),
    );
  }

  _loadExif(FilePickerResult? result) async {
    List<File> files = result!.paths.map((path) => File(path!)).toList();
    Future<Map<String, IfdTag>> data =
        readExifFromBytes(await files[0].readAsBytes());
    await data.then((data) {
      data.forEach((key, value) {
        exifData.add('$key: $value');
        setState(() {});
      });
    });
  }
}
