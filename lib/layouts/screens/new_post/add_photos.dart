import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/classes/filePicker.dart';
import 'package:photo_tracker/layouts/Widgets/appBar.dart';
import 'package:photo_tracker/layouts/Widgets/trackerSimpleButton.dart';
import 'package:photo_tracker/layouts/Widgets/editPhotoListItem.dart';

class AddPhotosScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AddPhotosScreen();
}

class _AddPhotosScreen extends State<AddPhotosScreen> {
  List<dynamic> imagesList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TrackerAppBar(
        mainScreen: false,
        title: 'Add Photos',
        appBarAction: TrackerSimpleButton(text: 'Confirm', pressed: (_) {}),
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
    return Container(
      child: ListView.builder(
          itemCount: imagesList.length,
          itemBuilder: (context, index) {
            return Container(
                margin: EdgeInsets.only(top: 2),
                child: EditPhotoListItem(
                  imagePath: imagesList[index][0], // path
                  imageName: imagesList[index][1], // name
                ));
          }),
    );
  }

  _bottomBar() {
    return Container(
      height: 45,
      width: MediaQuery.of(context).size.width,
      child: ElevatedButton(
        onPressed: () {
          MyFilePicker(pickedFiles: (filePickerResult) {
            if (filePickerResult != null) {
              for (var file in filePickerResult.files.toList()) {
                imagesList.add([file.path, file.name]);
                setState(() {});
              }
            }
          }).pickFiles();
        },
        child: Text('Add More'),
      ),
    );
  }
}
