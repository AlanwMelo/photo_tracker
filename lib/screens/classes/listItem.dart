import 'package:latlong2/latlong.dart';

class ListItem{
  final LatLng latLng;
  final DateTime? timestamp;
  final String imgPath;
  final bool locationError;
  final bool timeError;

  ListItem(this.latLng, this.timestamp, this.imgPath, this.locationError, this.timeError);
}