import 'package:file_picker/file_picker.dart';

class MyFilePicker {
  final Function(FilePickerResult?) pickedFiles;

  MyFilePicker({required this.pickedFiles});

  pickFiles({required bool allowMultiple}) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple, type: FileType.custom, allowedExtensions: ['jpg']);

    pickedFiles(result);
  }
}