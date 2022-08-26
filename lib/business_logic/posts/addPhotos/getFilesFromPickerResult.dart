import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:photo_tracker/business_logic/posts/addPhotos/addPhotosListItem.dart';
import 'package:photo_tracker/data/imageCompressor.dart';

class GetFilesFromPickerResult {
  final FilePickerResult result;

  GetFilesFromPickerResult(this.result);

  getFilesPathAndNames({required String tempDir}) async {
    ImageCompressor imageCompressor = ImageCompressor();
    List<AddPhotosListItem> list = [];
    List<File> files = result.paths.map((path) => File(path!)).toList();
    for (var element in files) {
      int nameHelper = element.path.lastIndexOf('/') + 1;

      String newLocation = await imageCompressor.compress(
          tempDir: tempDir,
          fileName: element.path.substring(nameHelper),
          filePath: element.path);

      list.add(AddPhotosListItem(
          name: element.path.substring(nameHelper),
          path: newLocation,
          location: 'not processed',
          processing: false,
          collaborator: FirebaseAuth.instance.currentUser!.uid));
    }
    return list;
  }
}
