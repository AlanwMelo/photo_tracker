import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photo_tracker/screens/classes/listItem.dart';
import 'package:photo_tracker/screens/classes/loadPhotosToList.dart';

class NewListDialog extends StatefulWidget {
  final String alertTitle;
  final Function(int) answer;

  NewListDialog({required this.alertTitle, required this.answer});

  @override
  State<StatefulWidget> createState() => _NewListDialogState();
}

class _NewListDialogState extends State<NewListDialog> {
  TextEditingController listNameController = TextEditingController();
  List<ListItem> listOfItems = [];

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
        controller: listNameController,
        decoration: InputDecoration(
            border: UnderlineInputBorder(), labelText: 'Nome da lista'),
      ),
      actions: [
        Center(
            child: Column(
              children: [
                listOfItems.length == 0 ? _btProsseguir() : _btConcluir(),
              ],
            )),
      ],
    );
  }

  _btProsseguir() {
    return Container(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(shape: _myButtonStyle()),
        onPressed: listNameController.text
            .trim()
            .length >= 3
            ? () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              type: FileType.custom,
              allowedExtensions: ['jpg']);

          if (result != null) {
            listOfItems = await LoadPhotosToList(result).loadPhotos();
            setState(() {});
            ;
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
        onPressed: () {
          widget.answer(1);
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
}
