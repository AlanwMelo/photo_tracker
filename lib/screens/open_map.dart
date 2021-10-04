import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:photo_tracker/screens/plugins/scale_layer_plugin_option.dart';
import 'package:speech_balloon/speech_balloon.dart';

import 'classes/listItem.dart';

class OpenMap extends StatefulWidget {
  final List<Marker> markerList;

  const OpenMap({Key? key, required this.markerList}) : super(key: key);

  @override
  State<StatefulWidget> createState() => NewMapTestState();
}

class NewMapTestState extends State<OpenMap> with TickerProviderStateMixin {
  late final MapController mapController;
  List<ListItem> markerList = [];
  var markers;
  String selectFileName = '';

  addMarker(LatLng latLng, DateTime? timestamp, String imgPath) {
    setState(() {
      markerList.add(ListItem(latLng, timestamp, imgPath));
    });
  }

  @override
  void initState() {
    super.initState();
    mapController = MapController();
  }

  /// Animação retirada de https://github.com/fleaflet/flutter_map
  void animatedMapMove(LatLng destLocation, double destZoom) {
    // Create some tweens. These serve to split up the transition from one location to another.
    // In our case, we want to split the transition be<tween> our current map center and the destination.
    final _latTween = Tween<double>(
        begin: mapController.center.latitude, end: destLocation.latitude);
    final _lngTween = Tween<double>(
        begin: mapController.center.longitude, end: destLocation.longitude);
    final _zoomTween = Tween<double>(begin: mapController.zoom, end: destZoom);

    // Create a animation controller that has a duration and a TickerProvider.
    var controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    // The animation determines what path the animation will take. You can try different Curves values, although I found
    // fastOutSlowIn to be my favorite.
    Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
          LatLng(_latTween.evaluate(animation), _lngTween.evaluate(animation)),
          _zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    /// Cria os marcadores no mapa, precisa ficar na build
    markers = markerList.map((marker) {
      return Marker(
        rotate: true,
        height: 200,
        width: 200,
        point: marker.latLng,
        builder: (ctx) => Container(
          child: SpeechBalloon(
            nipLocation: NipLocation.bottom,
            color: Colors.white70,
            borderColor: selectFileName == marker.imgPath
                ? Colors.lightGreen
                : Colors.lightBlue,
            borderWidth: 4,
            child: _markerContainer(marker),
          ),
        ),
      );
    }).toList();

    ///
    return Scaffold(
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          plugins: [
            ScaleLayerPlugin(),
          ],
          center: LatLng(-22.830448, -46.86940797222222),
          // Alterar para mapbounds !!!!!!
          zoom: 13.0,
          debugMultiFingerGestureWinner: true,
          enableMultiFingerGestureRace: true,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate:
                'https://api.mapbox.com/styles/v1/alanwillian/ck20ujxl3cuqj1cnzfnsckw1n/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoiYWxhbndpbGxpYW4iLCJhIjoiY2t1NzdmemNpNWg3cDJ2cDNidzByMDBoaCJ9.MPIAwrrnDmfwY2ihEWYhQQ',
          ),
          MarkerLayerOptions(
            // Definir a prioridade através da ordem em que eles estarão nessa lista, as primeira imagens da lista são os markers superiores
            markers: markers,
          ),
        ],
        nonRotatedLayers: [
          ScaleLayerPluginOption(
            lineColor: Colors.blue,
            lineWidth: 2,
            textStyle: TextStyle(color: Colors.blue, fontSize: 12),
            padding: EdgeInsets.all(10),
          ),
        ],
      ),
    );
  }

  _markerContainer(ListItem marker) {
    return GestureDetector(
      onTap: () {
        selectFileName = marker.imgPath;
        setState(() {});
      },
      child: Container(
        child: Image.file(File(marker.imgPath), fit: BoxFit.contain),
      ),
    );
  }
}
