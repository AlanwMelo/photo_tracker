import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_tracker/screens/open_map.dart';

class MapAndPhotos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MapAndPhotos();
}

class _MapAndPhotos extends State<MapAndPhotos> {
  AppBar appBar = AppBar(
    title: Text('title'),
  );
  double screenUseableHeight = 0;
  double screenUseablewidth = 0;
  GlobalKey<NewMapTestState> openMapController = GlobalKey<NewMapTestState>();
  MapController openMapController22 = MapController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    /// Recupera o tamanho da tela desconsiderando a AppBar
    screenUseableHeight =
        MediaQuery.of(context).size.height - appBar.preferredSize.height;
    screenUseablewidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: appBar,
      body: _mapAndPhotosBody(screenUseableHeight, screenUseablewidth),
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
                          color: Colors.blue,
                          child: ElevatedButton(
                              onPressed: () {
                                _moveMap();
                              },
                              child: Text('Lista')),
                        ),
                        Expanded(
                          child: Container(
                              width: useAbleWidth,
                              color: Colors.black,
                              child: Center(child: Image.network("https://www.wallpapertip.com/wmimgs/165-1657683_primal-kyogre-wallpapers-wallpaper-cave-shiny-primal-kyogre.jpg"))),
                        ),
                        /*Expanded(
                          child: Container(
                              width: useAbleWidth,
                              color: Colors.red,
                              child: Center(child: Image.network("https://w0.peakpx.com/wallpaper/368/756/HD-wallpaper-kyogre-ishmam-legendary-pokemon.jpg", fit: BoxFit.contain,))),
                        ),*/
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

  _moveMap() {
    NewMapTestState mapController = openMapController.currentState!;

    mapController.animatedMapMove(LatLng(-22.910454, -47.062978), 13.0);
  }
}
