import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_tracker/data/checkAppImagesDir.dart';

class ImageCompressor {
  compress(Map map) async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String imagesDir = '${appDir.path}/compressed_images/${map['post']}/';
    await CheckAppImagesDir().checkDir(imagesDir);

    String newLocation = '$imagesDir${map['fileName']}';

    print(newLocation);

    await FlutterImageCompress.compressAndGetFile(
        map['fileToProcess'], newLocation,
        keepExif: true, quality: 50);

    return newLocation;
  }
}
