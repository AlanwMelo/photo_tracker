import 'package:latlong2/latlong.dart';

class ListItem{
  final LatLng latLng;
  final DateTime? timestamp;
  final String imgPath;

  ListItem(this.latLng, this.timestamp, this.imgPath);
}