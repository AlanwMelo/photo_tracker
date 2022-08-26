import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_tracker/data/checkAppImagesDir.dart';

class ImageCompressor {
  compress({required String fileName, required String tempDir, required String filePath}) async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String imagesDir = '${appDir.path}/compressed_images/$tempDir/';
    await CheckAppImagesDir().checkDir(imagesDir);

    String newLocation = '$imagesDir$fileName';

    await FlutterImageCompress.compressAndGetFile(
        filePath, newLocation,
        keepExif: true, quality: 50);

    return newLocation;
  }
}
