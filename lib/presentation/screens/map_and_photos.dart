import 'dart:async';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_tracker/business_logic/processingFilesStream.dart';
import 'package:photo_tracker/data/listItem.dart';
import 'package:photo_tracker/data/firebase/createListItemFromQueryResult.dart';
import 'package:photo_tracker/data/routeAnimations/pageRouterSlideUp.dart';
import 'package:photo_tracker/db/dbManager.dart';
import 'package:photo_tracker/presentation/Widgets/appBar.dart';
import 'package:photo_tracker/presentation/screens/comments.dart';
import 'package:photo_tracker/presentation/screens/newPost/new_post.dart';
import 'package:photo_tracker/presentation/screens/open_map.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class MapAndPhotos extends StatefulWidget {
  final String mapboxKey;
  final String postID;
  final String postTitle;
  final String ownerID;
  final bool goToComments;
  final Function(bool) answer;

  const MapAndPhotos(
      {Key? key,
      required this.postID,
      required this.answer,
      required this.mapboxKey,
      this.goToComments = false,
      required this.postTitle,
      required this.ownerID})
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
    _loadList(widget.postID);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
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
        title: widget.postTitle,
        mainScreen: false,
        location: 'Vai ter uma localização',
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
                GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => NewPost(
                                processingFilesStream: ProcessingFilesStream(),
                                postID: widget.postID))),
                    child:
                        widget.ownerID == FirebaseAuth.instance.currentUser?.uid
                            ? Container(
                                height: 40, width: 40, child: Icon(Icons.edit))
                            : Container()),
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
                      child: Image.network(fileList[index].imgPath,
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
                      child: Image.network(item.imgPath, fit: BoxFit.cover)),
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
                      child: Image.network(item.imgPath, fit: BoxFit.contain),
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
    fileList =
        await CreateListItemFromQueryResult().createFromFirebase(listName);
    for (var element in fileList) {
      _addMarkerToMap(element);
    }
    setState(() {});

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
      location: 'Vai ter uma localização',
      title: widget.postTitle,
      closeButton: (_) => Navigator.of(context).pop(),
    )));
  }

// #### Funções - Fim ####
}
