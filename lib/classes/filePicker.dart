import 'package:file_picker/file_picker.dart';

class MyFilePicker {
  final Function(FilePickerResult?) pickedFiles;

  MyFilePicker({required this.pickedFiles});

  pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true, type: FileType.custom, allowedExtensions: ['jpg']);

    pickedFiles(result);
  }
}