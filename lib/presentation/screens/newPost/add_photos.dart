import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/src/file_picker_result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/business_logic/addPhotos/addPhotosListItem.dart';
import 'package:photo_tracker/business_logic/addPhotos/getFilesFromPickerResult.dart';
import 'package:photo_tracker/business_logic/processingFilesStream.dart';
import 'package:photo_tracker/classes/filePicker.dart';
import 'package:photo_tracker/data/listItem.dart';
import 'package:photo_tracker/presentation/Widgets/appBar.dart';
import 'package:photo_tracker/presentation/Widgets/editPhotoListItem.dart';
import 'package:photo_tracker/presentation/Widgets/trackerSimpleButton.dart';

class AddPhotosScreen extends StatefulWidget {
  final Function(List<ListItem>) confirm;
  final ProcessingFilesStream processingFilesStream;
  final String postID;

  const AddPhotosScreen(
      {Key? key,
      required this.confirm,
      required this.processingFilesStream,
      required this.postID})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddPhotosScreen();
}

class _AddPhotosScreen extends State<AddPhotosScreen> {
  List<ListItem> uploadList = [];
  List<AddPhotosListItem> imagesList = [];

  @override
  void initState() {
    widget.processingFilesStream.stream.listen((event) {
      String location = 'error';
      if (event.toString().contains('location')) {
        if (event['location'] != 'error') {
          GeoPoint geoPoint = event['location'];
          location = '${geoPoint.latitude.toStringAsFixed(8)}, ${geoPoint.longitude.toStringAsFixed(8)}';
        }
        var x =
            imagesList.indexWhere((element) => element.name == event['file']);
        imagesList[x] = AddPhotosListItem(
            name: imagesList[x].name,
            path: imagesList[x].path,
            location: location,
            collaborator: imagesList[x].collaborator);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TrackerAppBar(
        mainScreen: false,
        implyLeading: false,
        title: '    Add Photos',
        appBarAction: TrackerSimpleButton(
            text: 'Confirm',
            pressed: (_) {
              widget.confirm(uploadList);
              Navigator.of(context).pop();
            }),
      ),
      body: _body(),
    );
  }

  _body() {
    return Container(
      color: Colors.blueGrey.withOpacity(0.15),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: _listView()),
          _bottomBar(),
        ],
      ),
    );
  }

  _listView() {
    return StreamBuilder(
      stream: widget.processingFilesStream.stream,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        return Container(
          child: ListView.builder(
              itemCount: imagesList.length,
              itemBuilder: (context, index) {
                return Container(
                    margin: EdgeInsets.only(top: 2),
                    child: EditPhotoListItem(
                      imagePath: imagesList[index].path,
                      imageName: imagesList[index].name,
                      location: imagesList[index].location,
                      collaborator: imagesList[index].collaborator,
                      processing: snapshot.data['processingFile'] ==
                              imagesList[index].name
                          ? true
                          : false, // name
                    ));
              }),
        );
      },
    );
  }

  _bottomBar() {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () {
          MyFilePicker(pickedFiles: (filePickerResult) async {
            if (filePickerResult != null) {
              _addImagerToList(filePickerResult);
            }
          }).pickFiles();
        },
        child: Text('Add More'),
      ),
    );
  }

  _addImagerToList(FilePickerResult filePickerResult) async {
    List<AddPhotosListItem> result =
        await GetFilesFromPickerResult(filePickerResult).getFilesPathAndNames();
    for (var element in result) {
      if (!imagesList.any((e) => e.name == element.name)) {
        imagesList.add(element);

        Map<String, dynamic> fileToProcess = {
          "fileToProcess": element.path,
          "fileName": element.name,
          "post": widget.postID,
        };
        widget.processingFilesStream.addToQueue(fileToProcess);
      }
    }
    setState(() {});
  }
}
