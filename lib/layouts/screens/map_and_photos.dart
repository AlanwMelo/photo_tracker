import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_tracker/classes/alertDialog.dart';
import 'package:photo_tracker/classes/createListItemFromQueryResult.dart';
import 'package:photo_tracker/classes/listItem.dart';
import 'package:photo_tracker/classes/loadPhotosToList.dart';
import 'package:photo_tracker/classes/routeAnimations/pageRouterSlideUp.dart';
import 'package:photo_tracker/db/dbManager.dart';
import 'package:photo_tracker/layouts/Widgets/appBar.dart';
import 'package:photo_tracker/layouts/screens/comments.dart';
import 'package:photo_tracker/layouts/screens/open_map.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class MapAndPhotos extends StatefulWidget {
  final String mapboxKey;
  final String listName;
  final bool goToComments;
  final Function(bool) answer;

  const MapAndPhotos(
      {Key? key,
      required this.listName,
      required this.answer,
      required this.mapboxKey,
      this.goToComments = false})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapAndPhotos();
}

class _MapAndPhotos extends State<MapAndPhotos> {
  double screenUsableHeight = 0;
  double screenUsableWidth = 0;
  GlobalKey<NewMapTestState> openMapController = GlobalKey<NewMapTestState>();
  CarouselController carouselController = CarouselController();
  late AutoScrollController scrollController;
  List<ListItem> fileList = [];
  int selectedImg = 0;
  Timer? moveMapDebounce;
  Duration debounceDuration = Duration(milliseconds: 1000);
  DBManager dbManager = DBManager();

  @override
  void initState() {
    scrollController = AutoScrollController(
        viewportBoundaryGetter: () =>
            Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
        axis: Axis.vertical);
    _loadList(widget.listName);
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      if (widget.goToComments) {
        await Future.delayed(Duration(seconds: 1));
        _openComments();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    if (moveMapDebounce?.isActive ?? false) {
      moveMapDebounce!.cancel();
    }
    widget.answer(true);
    super.dispose();
  }

  @override
  build(BuildContext context) {
    /// Recupera o tamanho da tela desconsiderando a AppBar
    screenUsableHeight = MediaQuery.of(context).size.height;
    screenUsableWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: TrackerAppBar(
        title: 'Holambra',
        mainScreen: false,
        location: 'Holambra - SP',
      ),
      body: _mapAndPhotosBody(screenUsableHeight, screenUsableWidth),
    );
  }

  // ##### Layout - Inicio #####
  _mapAndPhotosBody(double useAbleHeight, double useAbleWidth) {
    double mapHeight = useAbleHeight * 0.5;
    return Container(
      height: useAbleHeight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /// Container do Mapa
          Container(
            color: Colors.white,
            height: mapHeight,
            width: useAbleWidth,
            child: _openMap(),
          ),

          /// Container da lista e imagens
          Expanded(
            child: Container(
              width: useAbleWidth,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 100,
                    child: _imgList((useAbleHeight - mapHeight) * 0.2),
                  ),
                  Expanded(
                    child: fileList.length != 0
                        ? _carouselSlider(useAbleHeight, useAbleWidth)

                        /// Retirar
                        : Container(
                            width: useAbleWidth,
                            color: Colors.black87,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: Icon(
                                    Icons.image_search_outlined,
                                    color: Colors.white70,
                                    size: 80,
                                  ),
                                )
                              ],
                            ),
                          ),
                  )
                ],
              ),
            ),
          ),

          Container(
            color: Colors.lightBlue.withOpacity(0.35),
            height: 45,
            child: Row(
              children: [
                Container(
                    margin: EdgeInsets.only(left: 15), child: Icon(Icons.edit)),
                Expanded(child: Container()),
                Container(
                    margin: EdgeInsets.only(right: 15),
                    child: GestureDetector(
                      child: Icon(Icons.notes_rounded),
                      onTap: () => _openComments(),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _openMap() {
    return OpenMap(
      key: openMapController,
      markerList: [],
      mapBoxKey: widget.mapboxKey,
      markerSelected: (var marker) {
        _listAndCarouselSynchronizer(
            marker,
            fileList
                .indexWhere((element) => element.imgPath == marker.imgPath));
      },
    );
  }

  _imgList(double size) {
    /// Usar o valor de height para garantir os quadrado em qualquer tamanho de tela

    return Container(
      color: Colors.blueGrey.withOpacity(0.5),
      width: fileList.length == 0 ? 0 : MediaQuery.of(context).size.width - 55,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: fileList.length,
        controller: scrollController,
        itemBuilder: (BuildContext context, int index) {
          _imgContainerColor() {
            Color containerColor = Colors.lightBlueAccent;
            if (fileList[index].locationError) {
              containerColor = Colors.deepOrangeAccent;
            } else if (fileList[index].timeError) {
              containerColor = Colors.orangeAccent;
            }
            if (selectedImg == index) {
              containerColor = Colors.lightGreen;
            }

            return containerColor;
          }

          return AutoScrollTag(
            key: ValueKey(index),
            controller: scrollController,
            index: index,
            child: GestureDetector(
              onTap: () {
                _listAndCarouselSynchronizer(fileList[index], index);
              },
              onLongPress: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return MyAlertDialog(
                          alertTitle: 'Remover',
                          alertText: 'Deseja mesmo remover esta imagem?',
                          alertButton1Text: 'Sim',
                          alertButton2Text: 'Não',
                          answer: (answer) {
                            if (answer == 1) {
                              if (!fileList[index].locationError) {
                                openMapController.currentState!
                                    .rmvMarker(fileList[index]);
                              }
                              dbManager
                                  .deleteImageItem(fileList[index].imgPath);
                              fileList.removeAt(index);
                              setState(() {});
                            }
                          });
                    });
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 1),
                decoration: BoxDecoration(
                  color: _imgContainerColor().withOpacity(0.7),
                  border: Border(
                    bottom: BorderSide(width: 4, color: _imgContainerColor()),
                    top: BorderSide(width: 4, color: _imgContainerColor()),
                    left: BorderSide(width: 4, color: _imgContainerColor()),
                    right: BorderSide(width: 4, color: _imgContainerColor()),
                  ),
                ),
                height: size,
                child: Column(
                  children: [
                    Container(
                      height: size * 0.7,
                      width: size,
                      child: Image.file(File(fileList[index].imgPath),
                          fit: BoxFit.cover),
                    ),
                    Expanded(
                      child: Container(
                        width: size,
                        color: Colors.white30,
                        child: Center(
                            child: Text('${index + 1}',
                                style: TextStyle(
                                    color: Colors.black45,
                                    fontStyle: FontStyle.italic,
                                    fontWeight: FontWeight.bold))),
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

  _addMoreButton(double height) {
    return Container(
      width: fileList.length == 0 ? MediaQuery.of(context).size.width : 55,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Colors.lightBlue,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero)),
        onPressed: () async {
          FilePickerResult? result = await FilePicker.platform.pickFiles(
              allowMultiple: true,
              type: FileType.custom,
              allowedExtensions: ['jpg']);

          if (result != null) {
            List<ListItem> loadToListItems =
                await LoadPhotosToList(result).loadPhotos();

            for (var element in loadToListItems) {
              dbManager.createNewImageItem(
                  widget.listName,
                  element.imgPath,
                  element.latLng.latitude,
                  element.latLng.longitude,
                  double.parse(
                      element.timestamp.millisecondsSinceEpoch.toString()),
                  element.locationError,
                  element.timeError);
              _addItemToList(element);
            }
            _getIndexOfFirsLocation(loadToListItems);
          } else {
            // User canceled the picker
          }
        },
        child: Center(child: Icon(Icons.add_a_photo_outlined)),
      ),
    );
  }

  _carouselSlider(double useAbleHeight, double useAbleWidth) {
    return Container(
      child: CarouselSlider(
        carouselController: carouselController,
        items: fileList.map((item) {
          return Builder(
            builder: (BuildContext context) {
              return Stack(
                children: [
                  Container(
                      height: useAbleHeight,
                      width: useAbleWidth,
                      color: Colors.blueGrey,
                      child: Image.file(File(item.imgPath), fit: BoxFit.cover)),
                  ClipRRect(
                    // Clip it cleanly.
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: Colors.grey.withOpacity(0.1),
                        alignment: Alignment.center,
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      child:
                          Image.file(File(item.imgPath), fit: BoxFit.contain),
                    ),
                  ),
                ],
              );
            },
          );
        }).toList(),
        options: CarouselOptions(
          enableInfiniteScroll: false,
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

  _moveMap(LatLng latLng, String fileName, {double? zoom}) {
    NewMapTestState mapController = openMapController.currentState!;
    openMapController.currentState!.selectFileName = fileName;
    if (zoom == null) {
      zoom = 17.0;
    }

    mapController.animatedMapMove(latLng, zoom);
  }

  // ##### Layout - Fim #####

  // #### Funções - Inicio ####
  _loadList(String listName) async {
    ListItem listItem;
    var result = await dbManager.getListItems(listName);
    for (var element in result) {
      listItem = await CreateListItemFromQueryResult().create(element);
      _addMarkerToMap(listItem);
      fileList.add(listItem);
    }
    _getIndexOfFirsLocation(fileList);
  }

  /// ###################### Debouncer ######################
  /// Inicia o timer do debouncer e, se a função não for chamada novamente em 1 segundo, move o mapa
  /// Se for chamada o timer é resetado
  _moveMapDebounce(ListItem listItem) {
    if (moveMapDebounce?.isActive ?? false) {
      moveMapDebounce!.cancel();
    }
    moveMapDebounce = Timer(debounceDuration, () {
      if (!listItem.locationError) {
        openMapController.currentState!.giveMarkerFocus(listItem);
        _moveMap(listItem.latLng, listItem.imgPath);
      } else {}
    });
  }

  /// Chamado quando o index muda, move o carrossel, a lista e o mapa para a mesma imagem
  _listAndCarouselSynchronizer(ListItem fileList, int index) async {
    setState(() {});
    selectedImg = index;
    await carouselController.onReady;
    scrollController.scrollToIndex(index);
    carouselController.animateToPage(index);
    _moveMapDebounce(fileList);
  }

  _addMarkerToMap(ListItem element) {
    if (!element.locationError) {
      openMapController.currentState!
          .addMarker(element.latLng, element.timestamp, element.imgPath);
    }
  }

  _addItemToList(ListItem element) {
    fileList.add(element);
    _addMarkerToMap(element);
  }

  _getIndexOfFirsLocation(List<ListItem> filesList) {
    /// Encontra o primerio item da lista carregada com localização e direciona o synchronizer para ele
    /// se nenhum item com localição for encontrado aponta para o zero
    ListItem? firstItem;
    int itemIndex = 0;

    if (filesList.any((element) => element.locationError == true)) {
      Fluttertoast.showToast(
          msg:
              "Uma ou mais imagens desta lista não contém a informação de localização.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    for (var item in filesList) {
      if (!item.locationError) {
        firstItem = item;
      } else {
        itemIndex = itemIndex + 1;
      }
    }

    if (firstItem == null) {
      firstItem = filesList[0];
      itemIndex = 0;
    }

    fileList.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    int mainListIndex = fileList.indexWhere(
        (element) => element.imgPath == filesList[itemIndex].imgPath);
    _listAndCarouselSynchronizer(filesList[itemIndex], mainListIndex);
  }

  _openComments() {
    Navigator.of(context).push(routeSlideUp(CommentsScreen(
      location: 'Holambra - SP',
      title: 'Holambra',
      closeButton: (_) => Navigator.of(context).pop(),
    )));
  }

// #### Funções - Fim ####
}
