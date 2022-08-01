import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/classes/filePicker.dart';
import 'package:photo_tracker/classes/loadPhotosToList.dart';
import 'package:photo_tracker/data/listItem.dart';
import 'package:photo_tracker/presentation/Widgets/appBar.dart';
import 'package:photo_tracker/presentation/Widgets/editPhotoListItem.dart';
import 'package:photo_tracker/presentation/Widgets/trackerSimpleButton.dart';

class AddPhotosScreen extends StatefulWidget {
  final Function(List<ListItem>) confirm;

  const AddPhotosScreen({Key? key, required this.confirm}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddPhotosScreen();
}

class _AddPhotosScreen extends State<AddPhotosScreen> {
  List<ListItem> imagesList = [];

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
              widget.confirm(imagesList);
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
    return Container(
      child: ListView.builder(
          itemCount: imagesList.length,
          itemBuilder: (context, index) {
            return Container(
                margin: EdgeInsets.only(top: 2),
                child: EditPhotoListItem(
                  imagePath: imagesList[index].imgPath, // path
                  imageName: 'img name', // name
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
          MyFilePicker(pickedFiles: (filePickerResult) async {
            if (filePickerResult != null) {
              List<ListItem> pickerImageList =
                  await LoadPhotosToList(filePickerResult).loadPhotos();
              for (ListItem element in pickerImageList) {
                imagesList.add(element);
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
