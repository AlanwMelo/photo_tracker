import 'package:latlong2/latlong.dart';
import 'package:photo_tracker/classes/listItem.dart';

class CreateListItemFromQueryResult{

  create(var element){
    ListItem listItem = ListItem(
        LatLng(double.parse(element['latitude'].toString()),
            double.parse(element['longitude'].toString())),
        DateTime.fromMillisecondsSinceEpoch(
            double.parse(element['timestamp'].toString()).ceil()),
        element['imgPath'].toString(),
        bool.fromEnvironment(element['locationError']),
        bool.fromEnvironment(element['timeError']));

    return listItem;
  }
}