import 'dart:io';

import 'package:exif/exif.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_tracker/screens/classes/listItem.dart';
import 'package:photo_tracker/screens/open_map.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class MapAndPhotos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapAndPhotos();
}

class _MapAndPhotos extends State<MapAndPhotos> {
  AppBar appBar = AppBar(
    title: Text('title'),
  );
  double screenUsableHeight = 0;
  double screenUsableWidth = 0;
  GlobalKey<NewMapTestState> openMapController = GlobalKey<NewMapTestState>();
  late AutoScrollController scrollController;
  MapController openMapController22 = MapController();
  List<ListItem> fileList = [];
  int selectedImg = 0;

  @override
  void initState() {
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Recupera o tamanho da tela desconsiderando a AppBar
    screenUsableHeight =
        MediaQuery.of(context).size.height - appBar.preferredSize.height;
    screenUsableWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: appBar,
      body: _mapAndPhotosBody(screenUsableHeight, screenUsableWidth),
    );
  }

  _mapAndPhotosBody(double useAbleHeight, double useAbleWidth) {
    return StreamBuilder(
        stream: null,
        builder: (context, snapshot) {
          double mapHeight = useAbleHeight * 0.5;

          return Container(
            height: useAbleHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  color: Colors.white,
                  height: mapHeight,
                  width: useAbleWidth,
                  child: _openMap(),
                ),
                Expanded(
                  child: Container(
                    width: useAbleWidth,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          width: useAbleWidth,
                          height: (useAbleHeight - mapHeight) * 0.2,
                          color: Colors.blue.withOpacity(0.3),
                          child: Row(
                            children: [
                              imgList((useAbleHeight - mapHeight) * 0.2),
                              addMoreButton((useAbleHeight - mapHeight) * 0.2),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Container(
                              width: useAbleWidth,
                              color: Colors.black,
                              child: Center(
                                  child: Image.file(
                                      File(
                                          '/data/user/0/com.example.photo_tracker/cache/file_picker/IMG_20210815_093346.jpg'),
                                      fit: BoxFit.contain))),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }

  _openMap() {
    return OpenMap(key: openMapController, markerList: []);
  }

  _moveMap(LatLng latLng, {double? zoom}) {
    NewMapTestState mapController = openMapController.currentState!;
    if (zoom == null) {
      zoom = 17.0;
    }

    mapController.animatedMapMove(latLng, zoom);
  }

  imgList(double size) {
    /// Usar o valor de height para garantir os quadrado em qualquer tamanho de tela

    return Container(
      width: fileList.length == 0 ? 0 : MediaQuery.of(context).size.width - 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: fileList.length,
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) {
          return AutoScrollTag(
            key: ValueKey(index),
            controller: scrollController,
            index: index,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedImg = index;
                });
                scrollController.scrollToIndex(index);
              },
              child: Container(
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(2),
                color: selectedImg == index
                    ? Colors.lightGreen
                    : Colors.lightBlueAccent,
                width: size,
                child: Column(
                  children: [
                    Container(
                      height: size * 0.7,
                      child: Image.file(File(fileList[index].imgPath)),
                    ),
                    Expanded(
                      child: Container(
                        width: size,
                        color: Colors.white30,
                        child: Center(child: Text('$index')),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  addMoreButton(double height) {
    return Container(
      decoration: BoxDecoration(
          border: Border(left: BorderSide(color: Colors.black, width: 1))),
      width: fileList.length == 0 ? MediaQuery.of(context).size.width : 45,
      height: height,
      child: TextButton(
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              type: FileType.custom,
              allowedExtensions: ['jpg']);

          if (result != null) {
            _loadPhotosToList(result);
          } else {
            // User canceled the picker
          }
          //_moveMap();
        },
        child: Icon(Icons.add_a_photo_outlined),
      ),
    );
  }

  getDoublePositionForLatLngFromExif(List latLngList) {
    Ratio degrees = latLngList[0];
    Ratio minutes = latLngList[1];
    Ratio milliseconds = latLngList[2];

    double latLngInDouble = degrees.toDouble() +
        (minutes.toDouble() / 60) +
        (milliseconds.toDouble() / 3600);

    return latLngInDouble;
  }

  _loadPhotosToList(FilePickerResult result) {
    List<File> files = result.paths.map((path) => File(path!)).toList();
    files.forEach((element) async {
      ///Realiza a conversao da localização do padrao DMM para double, salva o Timestamp e localização das fotos
      Future<Map<String, IfdTag>> data =
          readExifFromBytes(await element.readAsBytes());
      await data.then((data) {
        double latitude = 0;
        double latitudeRef = 1;
        double longitude = 0;
        double longitudeRef = 1;
        bool locationError = false;
        DateTime? dateTime;
        bool dateTimeError = false;

        if (!data.containsKey('GPS GPSLatitude') ||
            !data.containsKey('GPS GPSLongitude') ||
            !data.containsKey('GPS GPSLatitudeRef') ||
            !data.containsKey('GPS GPSLongitudeRef')) {
          locationError = !locationError;
        }
        if (!data.containsKey('Image DateTime')) {
          dateTimeError = !dateTimeError;
        }

        print(locationError);

        data.forEach((key, value) {
          //print('$key : $value');
          if (key == 'GPS GPSLatitude') {
            latitude =
                getDoublePositionForLatLngFromExif(value.values.toList());
          }
          if (key == 'GPS GPSLongitude') {
            longitude =
                getDoublePositionForLatLngFromExif(value.values.toList());
          }
          if (key == 'GPS GPSLatitudeRef' &&
              value.toString().toLowerCase().contains('s')) {
            latitudeRef = -1;
          }
          if (key == 'GPS GPSLongitudeRef' &&
              value.toString().toLowerCase().contains('w')) {
            longitudeRef = -1;
          }
          if (key == 'Image DateTime') {
            int year = int.parse(value.printable.substring(0, 4));
            int month = int.parse(value.printable.substring(5, 7));
            int day = int.parse(value.printable.substring(8, 11));
            int hour = int.parse(value.printable.substring(11, 13));
            int minute = int.parse(value.printable.substring(14, 16));
            int second = int.parse(value.printable.substring(17, 19));

            dateTime = DateTime(year, month, day, hour, minute, second);
          }
        });

        _moveMap(LatLng(latitude * latitudeRef, longitude * longitudeRef));

        fileList.add(ListItem(
            LatLng(latitude * latitudeRef, longitude * longitudeRef),
            dateTime,
            element.absolute.path));

        openMapController.currentState!.addMarker(
            LatLng(latitude * latitudeRef, longitude * longitudeRef),
            dateTime,
            element.absolute.path);

        setState(() {});
      });
    });
  }
}
