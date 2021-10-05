import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:exif/exif.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  CarouselController carouselController = CarouselController();
  late AutoScrollController scrollController;
  List<ListItem> fileList = [];
  int selectedImg = 0;
  Timer? moveMapDebounce;
  Duration debounceDuration = Duration(milliseconds: 500);

  @override
  void initState() {
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    super.initState();
  }

  @override
  void dispose() {
    moveMapDebounce!.cancel();
    super.dispose();
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
                          child: _carouselSlider(useAbleHeight, useAbleWidth),
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

  _moveMap(LatLng latLng, String fileName, {double? zoom}) {
    NewMapTestState mapController = openMapController.currentState!;
    openMapController.currentState!.selectFileName = fileName;
    if (zoom == null) {
      zoom = 17.0;
    }

    mapController.animatedMapMove(latLng, zoom);
  }

  imgList(double size) {
    /// Usar o valor de height para garantir os quadrado em qualquer tamanho de tela

    return Container(
      width: fileList.length == 0 ? 0 : MediaQuery.of(context).size.width - 55,
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
                _listAndCarouselSynchronizer(fileList[index], index);
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
                        child: Center(child: Text('${index+1}')),
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
      width: fileList.length == 0 ? MediaQuery.of(context).size.width : 55,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          primary: Colors.lightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero
          )

        ),
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
        child: Center(child: Icon(Icons.add_a_photo_outlined)),
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

        fileList.add(ListItem(
            LatLng(latitude * latitudeRef, longitude * longitudeRef),
            dateTime,
            element.absolute.path));

        ListItem thisItem = fileList.last;

        openMapController.currentState!.addMarker(
            LatLng(latitude * latitudeRef, longitude * longitudeRef),
            dateTime,
            element.absolute.path);

        fileList.sort((a, b) => a.timestamp!.compareTo(b.timestamp!));

        _listAndCarouselSynchronizer(
            thisItem, fileList.indexWhere((element) => element == thisItem));
      });
    });
  }

  _carouselSlider(double useAbleHeight, double useAbleWidth) {
    return Container(
      width: useAbleWidth,
      color: Colors.black,
      child: CarouselSlider(
        carouselController: carouselController,
        items: fileList.map((item) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: useAbleWidth,
                child: Image.file(File(item.imgPath), fit: BoxFit.contain),
              );
            },
          );
        }).toList(),
        options: CarouselOptions(
          enableInfiniteScroll: true,
          height: useAbleHeight,
          viewportFraction: 1,
          onPageChanged: (index, reason) {
            if (reason == CarouselPageChangedReason.manual) {
              _listAndCarouselSynchronizer(fileList[index], index);
            }
          },
        ),
      ),
    );
  }

  /// ###################### Debouncers ######################
  /// Inicia o timer do debouncer e, se a função não for chamada novamente em 1 segundo, move o mapa
  /// Se for chamada o timer é resetado
  _moveMapDebounce(ListItem listItem) {
    if (moveMapDebounce?.isActive ?? false) {
      moveMapDebounce!.cancel();
    }
    moveMapDebounce = Timer(debounceDuration, () {
      openMapController.currentState!.giveMarkerFocus(listItem);
      _moveMap(listItem.latLng, listItem.imgPath);
    });
  }

  /// Chamado quando o index muda, move o carrossel, a lista e o mapa para a mesma imagem
  _listAndCarouselSynchronizer(ListItem fileList, int index) {
    selectedImg = index;
    scrollController.scrollToIndex(index);
    carouselController.animateToPage(index);
    _moveMapDebounce(fileList);
    setState(() {});
  }
}
