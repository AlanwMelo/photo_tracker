import 'dart:io';
import 'package:exif/exif.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_tracker/data/checkAppImagesDir.dart';
import 'package:photo_tracker/data/listItem.dart';

class LoadPhotosToList {
  final FilePickerResult result;

  LoadPhotosToList(this.result);

  List<ListItem> listOfItems = [];

  loadPhotos() async {
    print('result Start');
    listOfItems.clear();
    List<File> files = result.paths.map((path) => File(path!)).toList();
    Directory appDir = await getApplicationDocumentsDirectory();
    String imagesDir = '${appDir.path}/images/';
    await CheckAppImagesDir().checkDir(imagesDir);

    for (var element in files) {
      int nameHelper = element.path.lastIndexOf('/') + 1;
      String newLocation = '$imagesDir${element.path.substring(nameHelper)}';

      ///Realiza a conversao da localização do padrao DMM para double, salva o Timestamp e localização das fotos
      Future<Map<String, IfdTag>> data =
          readExifFromBytes(await element.readAsBytes());
      double latitude = 0;
      double latitudeRef = 1;
      double longitude = 0;
      double longitudeRef = 1;
      bool locationError = false;
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(0);
      bool dateTimeError = false;

      await data.then((data) async {
        if (!data.containsKey('GPS GPSLatitude') ||
            !data.containsKey('GPS GPSLongitude') ||
            !data.containsKey('GPS GPSLatitudeRef') ||
            !data.containsKey('GPS GPSLongitudeRef')) {
          locationError = !locationError;
        }
        if (!data.containsKey('Image DateTime')) {
          dateTimeError = !dateTimeError;
        }

        for (var value in data.entries) {
          if (value.key == 'GPS GPSLatitude') {
            try {
              latitude = await getDoublePositionForLatLngFromExif(value
                  .value.printable
                  .replaceAll('[', '')
                  .replaceAll(']', '')
                  .split(','));
            } catch (e) {
              locationError = true;
            }
          }
          if (value.key == 'GPS GPSLongitude') {
            try {
              longitude = await getDoublePositionForLatLngFromExif(value
                  .value.printable
                  .replaceAll('[', '')
                  .replaceAll(']', '')
                  .split(','));
            } catch (e) {
              locationError = true;
            }
          }
          if (value.key == 'GPS GPSLatitudeRef' &&
              value.value.toString().toLowerCase().contains('s')) {
            latitudeRef = -1;
          }
          if (value.key == 'GPS GPSLongitudeRef' &&
              value.value.toString().toLowerCase().contains('w')) {
            longitudeRef = -1;
          }
          if (value.key == 'Image DateTime') {
            int year = int.parse(value.value.printable.substring(0, 4));
            int month = int.parse(value.value.printable.substring(5, 7));
            int day = int.parse(value.value.printable.substring(8, 11));
            int hour = int.parse(value.value.printable.substring(11, 13));
            int minute = int.parse(value.value.printable.substring(14, 16));
            int second = int.parse(value.value.printable.substring(17, 19));

            dateTime = DateTime(year, month, day, hour, minute, second);
          }
        }
      });

      listOfItems.add(ListItem(
          latLng: LatLng(latitude * latitudeRef, longitude * longitudeRef),
          timestamp: dateTime,
          imgPath: newLocation,
          locationError: locationError,
          timeError: locationError));

      await FlutterImageCompress.compressAndGetFile(element.path, newLocation,
          quality: 25);
    }

    await FilePicker.platform.clearTemporaryFiles();
    print('result done');
    return listOfItems;
  }

  getDoublePositionForLatLngFromExif(List latLngList) {
    String degrees = latLngList[0];
    String minutes = latLngList[1];
    String milliseconds = latLngList[2];

    int auxMilliseconds = milliseconds.indexOf('/');
    String auxMilliseconds1 = milliseconds.substring(0, auxMilliseconds);
    String auxMilliseconds2 = milliseconds.substring(auxMilliseconds + 1);

    double latLngInDouble = double.parse(degrees) +
        (double.parse(minutes) / 60) +
        ((double.parse(auxMilliseconds1) / double.parse(auxMilliseconds2)) /
            3600);

    return latLngInDouble;
  }
}
