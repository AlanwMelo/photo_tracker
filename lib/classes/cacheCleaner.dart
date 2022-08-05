import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:photo_tracker/data/checkAppImagesDir.dart';

class CacheCleaner {
  cleanUnusedImgs() async {
    print('Limpa TUTO!!!!');
    Directory appDir = await getApplicationDocumentsDirectory();
    String filesDir = '${appDir.path}/posts_images/';

    CheckAppImagesDir().checkDir(filesDir);

    List<FileSystemEntity> filesInDir = Directory(filesDir).listSync().toList();
    filesInDir.forEach((element) async {
      element.delete();
    });
  }
}
