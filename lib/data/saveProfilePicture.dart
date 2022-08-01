import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:path_provider/path_provider.dart';
import 'package:photo_tracker/data/checkAppImagesDir.dart';

class SaveProfilePicture {
  final String? imgUrl;

  SaveProfilePicture(this.imgUrl);

  savePicture() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String profileDir = '${appDir.path}/profileDir/';
    CheckAppImagesDir().checkDir(profileDir);

    var response = await http.get(Uri.parse(imgUrl!));

    File file = new File('${profileDir}profilePic.png');

    await file.writeAsBytes(response.bodyBytes);

    return file.path;
  }
}
