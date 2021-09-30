import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OpenMap extends StatefulWidget {
  final MapController mapController;
  final List<Marker> markerList;

  const OpenMap(
      {Key? key, required this.mapController, required this.markerList})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _NewMapTestState();
}

class _NewMapTestState extends State<OpenMap> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        options: MapOptions(
          controller: widget.mapController,
          center: new LatLng(51.5, -0.09),

          /// Alterar para mapbounds !!!!!!
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
            markers: [
              Marker(
                rotate: true,
                width: 80.0,
                height: 80.0,
                point: LatLng(51.5, -0.09),
                builder: (ctx) => Container(
                  child: FlutterLogo(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
