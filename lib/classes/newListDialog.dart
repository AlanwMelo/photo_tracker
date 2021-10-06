import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/classes/listItem.dart';
import 'package:photo_tracker/classes/loadPhotosToList.dart';
import 'package:photo_tracker/db/dbManager.dart';

class NewListDialog extends StatefulWidget {
  final String alertTitle;
  final Function(bool) answer;

  NewListDialog({required this.alertTitle, required this.answer});

  @override
  State<StatefulWidget> createState() => _NewListDialogState();
}

class _NewListDialogState extends State<NewListDialog> {
  TextEditingController listNameController = TextEditingController();
  bool textEditingKey = true;
  bool loadingFiles = false;
  bool writingToDB = false;
  List<ListItem> listOfItems = [];
  DBManager dbManager = DBManager();

  @override
  void dispose() {
    listNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    listNameController.addListener(() {
      setState(() {});
    });

    return AlertDialog(
      title: Text(widget.alertTitle),
      content: TextFormField(
        enabled: textEditingKey,
        controller: listNameController,
        decoration: InputDecoration(
            border: UnderlineInputBorder(), labelText: 'Nome da lista'),
      ),
      actions: [
        Center(
            child: Column(
          children: [
            listOfItems.length == 0
                ? loadingFiles
                    ? _progressIndicator()
                    : _btProsseguir()
                : writingToDB
                    ? _progressIndicator()
                    : _btConcluir(),
          ],
        )),
      ],
    );
  }

  _btProsseguir() {
    return Container(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(shape: _myButtonStyle()),
        onPressed: listNameController.text.trim().length >= 3
            ? () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                    allowCompression: true,
                    allowMultiple: true,
                    type: FileType.custom,
                    allowedExtensions: ['jpg']);

                if (result != null) {
                  textEditingKey = !textEditingKey;
                  loadingFiles = !loadingFiles;
                  setState(() {});
                  listOfItems = await LoadPhotosToList(result).loadPhotos();
                  loadingFiles = !loadingFiles;
                  setState(() {});
                } else {}
              }
            : null,
        child: Text('Prosseguir'),
      ),
    );
  }

  _btConcluir() {
    return Container(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(shape: _myButtonStyle()),
        onPressed: () async {
          writingToDB = !writingToDB;
          setState(() {});
          dbManager.createNewList(listNameController.text,
              DateTime.now().millisecondsSinceEpoch.toString());
          for (var item in listOfItems) {
            dbManager.createNewImageItem(
                listNameController.text,
                item.imgPath,
                item.latLng.latitude,
                item.latLng.longitude,
                double.parse(item.timestamp.millisecondsSinceEpoch.toString()),
                item.locationError,
                item.timeError);
          }

          widget.answer(true);
          Navigator.of(context).pop();
        },
        child: listOfItems.length != 1
            ? Text('Criar lista com ${listOfItems.length} imagens')
            : Text('Criar lista com ${listOfItems.length} imagem'),
      ),
    );
  }

  _myButtonStyle() {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0));
  }

  _progressIndicator() {
    return Container(
        height: 20,
        width: 20,
        margin: EdgeInsets.only(bottom: 8),
        child: CircularProgressIndicator());
  }
}
