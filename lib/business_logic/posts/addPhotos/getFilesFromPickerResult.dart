import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:photo_tracker/business_logic/posts/addPhotos/addPhotosListItem.dart';

class GetFilesFromPickerResult {
  final FilePickerResult result;

  GetFilesFromPickerResult(this.result);

  getFilesPathAndNames() {
    List<AddPhotosListItem> list = [];
    List<File> files = result.paths.map((path) => File(path!)).toList();
    for (var element in files) {
      int nameHelper = element.path.lastIndexOf('/') + 1;
      list.add(AddPhotosListItem(
          name: element.path.substring(nameHelper),
          path: element.path,
          location: 'not processed',
          collaborator: 'user'));
    }
    return list;
  }
}
