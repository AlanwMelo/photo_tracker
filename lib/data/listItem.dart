import 'package:latlong2/latlong.dart';

class ListItem {
  final LatLng latLng;
  final DateTime timestamp;
  final String imgPath;
  final bool locationError;
  final bool timeError;

  ListItem(
      {required this.latLng,
      required this.timestamp,
      required this.imgPath,
      required this.locationError,
      required this.timeError});
}
