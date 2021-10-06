import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:photo_tracker/db/dbManager.dart';

class CacheCleaner {
  cleanUnusedImgs() async {
    DBManager dbManager = DBManager();
    Directory appDir = await getApplicationDocumentsDirectory();
    String filesDir = '${appDir.path}/images/';
    List<String> orphanFiles = [];

    var map = await dbManager.getOrphanFileNames();

    for (var element in map) {
      int nameHelper = element['imgPath'].toString().lastIndexOf('/') + 1;
      orphanFiles.add(element['imgPath'].toString().substring(nameHelper));
    }

    List<FileSystemEntity> filesInDir = Directory(filesDir).listSync().toList();
    filesInDir.forEach((element) async {
      int nameHelper = element.path.lastIndexOf('/') + 1;
      String elementName = element.path.substring(nameHelper);
      if (orphanFiles.contains(elementName)) {
        await File('$filesDir$elementName').delete();
      }
    });
  }
}
